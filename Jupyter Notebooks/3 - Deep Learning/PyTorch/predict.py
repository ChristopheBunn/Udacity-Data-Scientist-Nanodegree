import torch
import torchvision.transforms as transforms
from torchvision import datasets, transforms, models
import numpy as np

from PIL import Image
from train import load_model

import json
import argparse

# Define command line arguments
parser = argparse.ArgumentParser()
parser.add_argument('--image', type=str, help='Image to predict')
parser.add_argument('--checkpoint', type=str, help='Model checkpoint to use when predicting')
parser.add_argument('--k', type=int, help='Return top K predictions')
parser.add_argument('--labels', type=str, help='JSON file containing label names')
parser.add_argument('--gpu', action='store_true', help='Use GPU if available')

args, _ = parser.parse_known_args()

# -------------------------------------
# Rebuild the Model from the Checkpoint
# -------------------------------------
def checkpoint_to_model(checkpoint_file, gpu):
    # Below 'cuda:0' is hardcoded because I couldn't find a way to extract it from the torch.device object!...
    checkpoint = torch.load(checkpoint_file, map_location=('cuda:0' if torch.cuda.is_available() else 'cpu'))
    arch = checkpoint['arch']
    
    if arch=='vgg16_bn':
        model = models.vgg16_bn(pretrained=True)
    elif arch=='alexnet':
        model = models.alexnet(pretrained=True)
    else:
        raise ValueError('NN architecture only accepts vgg16_bn and alexnet, not ', arch)
        
    model.classifier = checkpoint['classifier']
    model.class_to_idx = checkpoint['class_to_idx']
    model.load_state_dict(checkpoint['state'])
    
    return model

# -------------------------------------------------
# Process an Image to match those used for training
# -------------------------------------------------
def process_image(image_file):
    pil_image = Image.open(image_file)    # load the PIL image from the file
    
    # Scale, crop, and normalize
    image_transforms = transforms.Compose([transforms.Resize(256),
                                           transforms.CenterCrop(224),
                                           transforms.ToTensor(),
                                           transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])])
    
    image_tensor = image_transforms(pil_image)
    
    return image_tensor

# ------------------------------------------------
# Predict the Image's Class using a pre-trained NN
# ------------------------------------------------
def predict(image, checkpoint, k=5, labels='', gpu=False):
    
    # Read command line arguments
    if args.image:
        image = args.image     
    else:
        raise ValueError('Please pass Image File using --image')
    if args.checkpoint:
        checkpoint = args.checkpoint   
    else:
        raise ValueError('Please pass Model Checkpoint using --checkpoint')
    if args.k:
        k = args.k
    if args.labels:
        labels = args.labels
    if args.gpu:
        gpu = args.gpu
        
    print('Image: {}\tCheckpoint: {}\tK: {}\tLabels: {}\tGPU: {}'.format(image, checkpoint, k, labels, gpu))
    
    # Load the model from the checkpoint; use GPU if selected and available
    device = torch.device('cuda' if (gpu and torch.cuda.is_available()) else 'cpu')
    buNN = checkpoint_to_model(checkpoint, gpu)
    buNN.to(device)
    buNN.eval()
    
    # Process the Image before estimating its Class
    image_torch = process_image(image)
    image_torch = image_torch.to(device)
    image_torch = image_torch.unsqueeze_(0)
    image_torch = image_torch.float()
    image_torch.to(device)
    
    # Run the Model in inference/estimation mode
    with torch.no_grad():
        logps = buNN.forward(image_torch)
        
    # Calculate the top Probabilities and Classes
    ps = torch.exp(logps)
    probabilities, indices = ps.topk(k)
    probabilities = probabilities.tolist()[0]
    indices = indices.tolist()[0]
    #print("probabilities: {}\nindices: {}".format(probabilities, indices))
    idx_to_class = {v : k for k,v in buNN.class_to_idx.items()}
    #print("idx_to_class: {}".format(idx_to_class))
    classes = [idx_to_class[c] for c in indices]
    #print("classes: {}".format(classes))

    if labels:
        with open(labels, 'r') as f:
            class_to_name = json.load(f)
        #print("class_to_name: ", class_to_name)

        classes = [class_to_name[x] for x in classes]

    # Print only when invoked by command line 
    if args.image:
        print('Top {} Predictions and their Probabilities: {}'.format(k, list(zip(classes, probabilities))))
    
    return probabilities, classes

# -----------------------------------
# Execute predict() from command line
# -----------------------------------
if args.image and args.checkpoint:
    predict(args.image, args.checkpoint)