import torch
import torch.nn as nn
import torch.optim as optim
import torch.utils.data as data

from collections import OrderedDict

from torchvision import datasets, transforms, models

import argparse

# -----------------------------
# Define command line Arguments
# -----------------------------
parser = argparse.ArgumentParser()
parser.add_argument('--arch', type=str, help='Model architecture')
parser.add_argument('--checkpoint', type=str, help='File for saving trained model checkpoint')
parser.add_argument('--data_dir', type=str, help='Path to data set')
parser.add_argument('--dropout', type=int, help='Dropout rate (between 0 and 1)')
parser.add_argument('--epochs', type=int, help='Number of epochs')
parser.add_argument('--gpu', action='store_true', help='Use GPU if available')
parser.add_argument('--h1_units', type=int, help='Number of hidden units for layer 1')
parser.add_argument('--h2_units', type=int, help='Number of hidden units for layer 2')
parser.add_argument('--learning_rate', type=float, help='Learning rate')

args, _ = parser.parse_known_args()
print('args: {}'.format(args))

# ------------------------
# Load and configure Model
# ------------------------
def load_model(arch='vgg16_bn', num_outputs=102, num_h1=512, num_h2=256, dropout=0.2):
    # Load pre-trained Model
    if arch=='vgg16_bn':
        buNN = models.vgg16_bn(pretrained=True)
        num_inputs = 25088
    elif arch=='alexnet':
        buNN = models.alexnet(pretrained=True)
        num_inputs = 9216
    else:
        raise ValueError('NN architecture only accepts vgg16_bn and alexnet, not ', arch)
        
    # Replace Classifier with one specific to the Flowers data set
    for param in buNN.parameters():
        param.requires_grad = False    # turn off gradients for the classifier
    
    buNN_classifier = nn.Sequential(OrderedDict([
        ('dropout', nn.Dropout(p=dropout)),
        ('inputs', nn.Linear(num_inputs, num_h1)),
        ('ReLU1', nn.ReLU()),
        ('hidden1', nn.Linear(num_h1, num_h2)),
        ('ReLU2', nn.ReLU()),
        ('hidden2', nn.Linear(num_h2, num_outputs)),
        ('outputs', nn.LogSoftmax(dim=1))]))

    buNN.classifier = buNN_classifier
    #print(buNN)

    return buNN

# ----------------------------------------
# Process the Image data sets for training
# ----------------------------------------
def process_images(images_directory):
    if args.data_dir:
        # Define transforms for training, validation, and testing data sets
        image_transforms = {
            'train': transforms.Compose([
                transforms.RandomRotation(45),
                transforms.RandomResizedCrop(224),
                transforms.RandomHorizontalFlip(),
                transforms.ToTensor(),
                transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
             ]),
            'valid': transforms.Compose([
                transforms.Resize(256),
                transforms.CenterCrop(224),
                transforms.ToTensor(),
                transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
             ]),
            'test': transforms.Compose([
                transforms.Resize(256),
                transforms.CenterCrop(224),
                transforms.ToTensor(),
                transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
             ])
        }

        # Load the data sets using ImageFolder
        image_datasets = {
            x: datasets.ImageFolder(args.data_dir + '/' + x, transform=image_transforms[x]) for x in list(image_transforms.keys())
        }

        return image_datasets

# -----------
# Train Model
# -----------
def train_model(arch='vgg16_bn', checkpoint='', dropout=0.2, epochs=10, gpu=False, h1_units=512, h2_units=256, learning_rate=0.001):
    # Read command line arguments
    if args.arch:
        arch = args.arch
    if args.checkpoint:
        checkpoint = args.checkpoint
    if args.dropout:
        dropout = args.dropout
    if args.epochs:
        epochs = args.epochs
    if args.gpu:
        gpu = args.gpu
    if args.h1_units:
        h1_units = args.h1_units
    if args.h2_units:
        h2_units = args.h2_units
    if args.learning_rate:
        learning_rate = args.learning_rate
        
    print('Architecture: {}\tCheckpoint: {}\tDropout: {}\t{} Epochs\tGPU: {}\t{} H1 units\t{} H2 units\tLearning Rate: {}'.format(
        arch, checkpoint, dropout, epochs, gpu, h1_units, h2_units, learning_rate))
    
    # Create the training, validation, and testing data loaders from the image data sets
    if args.data_dir:
        image_datasets = process_images(args.data_dir)
    else:
        raise ValueError('Please pass Data Directory using --data_dir')
    dataloaders = {
        x: data.DataLoader(image_datasets[x], batch_size=64, shuffle=True) for x in list(image_datasets.keys())
    }
 
    # Calculate dataset sizes.
    dataset_sizes = {
        x: len(dataloaders[x]) for x in list(image_datasets.keys())
    }

    # Load the model     
    num_labels = len(image_datasets['train'].classes)
    buNN = load_model(arch=arch, num_outputs=num_labels, num_h1=h1_units, num_h2=h2_units, dropout=dropout)

    # Use GPU if selected and available
    device = torch.device('cuda' if (gpu and torch.cuda.is_available()) else 'cpu')
    buNN.to(device)

    # Define loss and optimizer
    criterion = nn.NLLLoss()
    optimizer = optim.Adam(buNN.classifier.parameters(), lr=0.001)
    
    # -----------------------------------
    # Train, validate, and test the model
    # -----------------------------------
    steps = 0    # training steps for each batch
    running_loss = 0
    print_every = 20
    
    # TRAIN
    for epoch in range(epochs):
        for train_images, train_labels in dataloaders['train']:
            steps += 1
            train_images, train_labels = train_images.to(device), train_labels.to(device)    # move data tensor batches to device
            optimizer.zero_grad()    # reinitialize the classifier's gradients
            logps = buNN.forward(train_images)    # same as writing buNN(train_images)
            loss = criterion(logps, train_labels)
            loss.backward()
            optimizer.step()
            running_loss += loss.item()

            # VALIDATE
            # Every "print_every" training loops, test our accuracy and loss on the validation data set
            if steps % print_every == 0:
                buNN.eval()    # put the model in inference/evaluation/prediction mode and turn off dropout
                valid_loss = 0
                accuracy = 0

                with torch.no_grad():    # no need to calculate gradients when making predictions
                    for valid_images, valid_labels in dataloaders['valid']:
                        valid_images, valid_labels = valid_images.to(device), valid_labels.to(device)    # move validation data to device
                        logps = buNN.forward(valid_images)
                        loss = criterion(logps, valid_labels)
                        valid_loss += loss.item()

                        # Calculate accuracy
                        ps = torch.exp(logps)    # apply exp() because model returns log softmax
                        top_ps, top_class = ps.topk(1, dim=1)
                        equality = (top_class == valid_labels.view(*top_class.shape))
                        accuracy += torch.mean(equality.type(torch.FloatTensor))    # sum accuracy for each batch

                print(f'Epoch {epoch+1}/{epochs}\t'
                      f'Train Loss = {running_loss/print_every:.3f}\t'
                      f'Validation Loss = {valid_loss/dataset_sizes["valid"]:.3f}\t'
                      f'Validation Accuracy = {accuracy/dataset_sizes["valid"]:.3f}')

                running_loss = 0
                buNN.train()    # put the model back into training mode before the next training loop
    print("End of Training")
    
    # TEST
    buNN.eval()    # put the model in inference/evaluation/prediction mode and turn off dropout
    test_loss = 0
    accuracy = 0

    with torch.no_grad():    # no need to calculate gradients when making predictions
        for test_images, test_labels in dataloaders['test']:
            test_images, test_labels = test_images.to(device), test_labels.to(device)    # move test data to device
            logps = buNN.forward(test_images)
            loss = criterion(logps, test_labels)
            test_loss += loss.item()

            # Calculate accuracy
            ps = torch.exp(logps)    # apply exp() because model returns log softmax
            top_ps, top_class = ps.topk(1, dim=1)
            equality = (top_class == test_labels.view(*top_class.shape))
            accuracy += torch.mean(equality.type(torch.FloatTensor))    # sum accuracy for each batch

    buNN.train()    # put the model back into training mode

    print(f'Test Loss = {test_loss/dataset_sizes["test"]:.3f}.. '
          f'Test Accuracy = {accuracy/dataset_sizes["test"]:.3f}')
    
    # If requested, save the checkpoint
    if checkpoint:
        checkpoint_data = {
            'class_to_idx': image_datasets['train'].class_to_idx,
            'arch': arch,
            'state': buNN.state_dict(),
            'classifier': buNN.classifier,
            'optimizer': optimizer.state_dict(),
            'epochs': epochs
        }

        torch.save(checkpoint_data, checkpoint)
    
    # Return the model
    return buNN

# ---------------------------------------
# Execute train_model() from command line
# ---------------------------------------
if args.data_dir:
    train_model()

# Testing load_model()
'''if args.arch:
    load_model(arch=args.arch)
else:
    load_model()'''