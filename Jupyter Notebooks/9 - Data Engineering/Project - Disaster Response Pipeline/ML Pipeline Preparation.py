#!/usr/bin/env python
# coding: utf-8

# # ML Pipeline Preparation
# Follow the instructions below to help you create your ML pipeline.
# ### 1. Import libraries and load data from database.
# - Import Python libraries
# - Load dataset from database with [`read_sql_table`](https://pandas.pydata.org/pandas-docs/stable/generated/pandas.read_sql_table.html)
# - Define feature and target variables X and y

# In[48]:


# import libraries
import numpy as np
import pandas as pd
from sqlalchemy import create_engine

import re
import nltk
nltk.download(['punkt', 'wordnet', 'stopwords', 'averaged_perceptron_tagger'])
from nltk.corpus import stopwords
from nltk.stem.wordnet import WordNetLemmatizer
from nltk.tokenize import word_tokenize

from sklearn.pipeline import Pipeline, FeatureUnion
from sklearn.multioutput import MultiOutputClassifier
from sklearn.feature_extraction.text import CountVectorizer, TfidfTransformer, TfidfVectorizer
from sklearn.ensemble import RandomForestClassifier # generates error: , GradientBoostingClassifier
from sklearn.svm import SVC
from sklearn.model_selection import train_test_split
from sklearn.metrics import confusion_matrix, classification_report
from sklearn.model_selection import GridSearchCV
from sklearn.base import BaseEstimator, TransformerMixin

import pickle


# In[2]:


def load_db_data(db_path, db_table):
    '''
    Load the contents of a DB table into a DataFrame.
    
    Input:
    - db_path: the path to the database
    - db_table: the name of the database table containing the data to load
    
    Output:
    - a DataFrame with each column being a field of the DB table
                   and each row being a record
    '''
    engine = create_engine(db_path)
    df = pd.read_sql_table(db_table, con=engine)
    
    return df


# In[3]:


# Load the Disaster Response SQLite table
df = load_db_data('sqlite:///Bunn_DisasterResponse.db', 'Bunn_DisasterResponse')


# In[20]:


# Take a peek at the contents of the DataFrame
df.head()


# In[4]:


# The features in X are just the text contained in column 'message'
# The targets in y are the last 36 columns; we drop:
# - 'id': useless
# - 'message': the features in X
# - 'original': not always in english
# - 
X = df['message']
y = df.drop(['id', 'message', 'original', 'genre'], axis=1)
# X = df.iloc[:,1:2]    # Cleaner but less explicit than above...
# y = df.iloc[:,4:]
print('\n-- Labels --\n{}\n\n'.format(df.columns.values))
print('\n-- X --\n{}\n\n'.format(X[:2]))
print('\n-- y --\n{}\n\n'.format(y[:2]))


# ### 2. Write a tokenization function to process your text data

# In[5]:


def tokenize(text):
    '''
    Normalizes, removes punctuation, lemmatizes, and
    removes stop words and trailing spaces from the input text.
    
    Input - text string
    Output - list of the resulting words/tokens
    '''
    # normalize case and remove punctuation
    text = re.sub(r"[^a-zA-Z0-9]", " ", text.lower())
    
    # tokenize text
    tokens = word_tokenize(text)
    
    # lemmatize and remove stop words
    lemmatizer = WordNetLemmatizer()
    stop_words = stopwords.words("english")
    tokens = [lemmatizer.lemmatize(word).strip() for word in tokens if word not in stop_words]
    
    return tokens


# ### 3. Build a machine learning pipeline
# This machine pipeline should take in the `message` column as input and output classification results on the other 36 categories in the dataset. You may find the [MultiOutputClassifier](http://scikit-learn.org/stable/modules/generated/sklearn.multioutput.MultiOutputClassifier.html) helpful for predicting multiple target variables.

# In[6]:


def build_model1(verbose):
    '''
    Builds a simple Pipeline model for Natural Language Processing
    
    Input:
    - verbose: level of verbosity while running (0 is non, the higher the more messages)
    
    Output:
    - the resulting Pipeline model
    '''
    rfc = RandomForestClassifier(verbose=verbose)

    pipeline = Pipeline([
#                    ('vect', CountVectorizer(tokenizer=tokenize)),
#                    ('tfidf', TfidfTransformer()),
                    ('tfidf', TfidfVectorizer(tokenizer=tokenize)),
                    ('clf', MultiOutputClassifier(rfc, n_jobs=-1)),
               ])
    return pipeline


# In[7]:


model1 = build_model1(0)


# ### 4. Train pipeline
# - Split data into train and test sets
# - Train pipeline

# In[8]:


X_train, X_test, y_train, y_test = train_test_split(X, y, random_state=68)
print('X_train:\n{}\n\ny_train:\n{}\n\nX_test:\n{}\n\ny_test:\n{}\n'.format(
    X_train[:2], y_train[:2], X_test[:2], y_test[:2]))


# In[9]:


# Train the model
model1.fit(X_train, y_train)


# ### 5. Test your model
# Report the f1 score, precision and recall for each output category of the dataset. You can do this by iterating through the columns and calling sklearn's `classification_report` on each.

# In[10]:


def simple_model_test(model, phrases, targets, num_tests):
    '''
    Prints the list of targets resulting from applying
    the NLP model to a few sample phrases.
    
    Input:
    - model: the model to be tested
    - phrases: a DataFrame of sample text
    - the number of tests we want to perform
    '''
    
    max = min(phrases.shape[0], num_tests)
    
    for i in range(0, max):
        test = model.predict([phrases.iloc[i]])
        print('Test #{}:\n{}\n{}\n'.format(i, phrases.iloc[i],
                                           targets.columns.values[(test.flatten() == 1)], '\n'))


# In[11]:


simple_model_test(model1, X_test, y_test, 5)


# In[12]:


y_pred1 = model1.predict(X_test)
y_pred1_df = pd.DataFrame(y_pred1, columns=y.columns)


# In[13]:


print('y_pred1 (type = {}):\n\n{}\n\n'.format(type(y_pred1), y_pred1[:2]))
print('y_pred1_df (type = {}):\n\n{}\n\n'.format(type(y_pred1_df), y_pred1_df[:2]))


# In[14]:


# As seen above, y_pred needs to be converted to a DataFrame, to match y_test's structure

for column in y.columns:
    print('\n---- {} ----\n{}\n'.format(column, classification_report(y_test[column], y_pred1_df[column])))


# ### 6. Improve your model
# Use grid search to find better parameters. 

# In[15]:


# List the current model's parameters
model1.get_params()


# In[16]:


# When passing a tokenizer to CountVectorizer(), it overrides the string tokenization step,
# as long as analyzer = ‘word’ (default), so I don’t bother with the ‘vect_*’ parameters
# during the grid search and concentrate only on 'tfidf_*' and 'clf_*'.

parameters = {
#    'tfidf__use_idf': [True, False],
    'clf__estimator__criterion': ['entropy', 'gini'],
    'clf__estimator__max_depth': [None, 10],
    'clf__estimator__max_leaf_nodes': [None, 5],
    'clf__estimator__min_samples_leaf': [1, 4],
    'clf__estimator__min_samples_split': [2, 4],
    'clf__estimator__n_estimators':  [10, 50],
}

model2 = GridSearchCV(model1, param_grid=parameters, verbose=1)


# In[17]:


# Train the model
model2.fit(X_train, y_train)


# ### 7. Test your model
# Show the accuracy, precision, and recall of the tuned model.  
# 
# Since this project focuses on code quality, process, and  pipelines, there is no minimum performance metric needed to pass. However, make sure to fine tune your models for accuracy, precision and recall to make your project stand out - especially for your portfolio!

# In[18]:


# Display the model's best parameters, according to the grid search above
model2.best_params_


# In[25]:


# Predict on the test data and display the metrics
y_pred2 = model2.predict(X_test)
y_pred2_df = pd.DataFrame(y_pred2, columns=y.columns)
for column in y.columns:
    print('\n---- {} ----\n{}\n'.format(column, classification_report(y_test[column], y_pred2_df[column])))


# ### 8. Try improving your model further. Here are a few ideas:
# * try other machine learning algorithms
# * add other features besides the TF-IDF

# In[44]:


class StartingVerbExtractor(BaseEstimator, TransformerMixin):
    '''
    Custom Transformer for detecting phrases that start with a verb or retweets
    '''

    def starting_verb(self, text):

        # tokenize into sentences
        sentence_list = nltk.sent_tokenize(text)

        for sentence in sentence_list:

            # tokenize into words and tag Part of Speech
            pos_tags = nltk.pos_tag(tokenize(sentence))
            #print('pos_tags = {}\n'.format(pos_tags))

            if (len(pos_tags) != 0):
                # get the 1st word and PoS tag
                first_word, first_tag = pos_tags[0]

                # return True if the 1st word is a verb or indicates a retweet
                if first_tag in ['VB', 'VBP'] or first_word == 'RT':
                    return True

        return False

    def fit(self, X, y=None):
        return self

    def transform(self, X):
        X_tagged = pd.Series(X).apply(self.starting_verb)
        return pd.DataFrame(X_tagged)


# In[45]:


def build_model3(classifier):
    '''
    Builds a slightly more complex Pipeline model for Natural Language Processing
    
    Input:
    - classifier: the learning algorithm (build_model1() used RandomForestClassifier exclusively)
    
    Output:
    - the resulting Pipeline model
    '''

    pipeline = Pipeline([
                ('features', FeatureUnion([
                    ('tfidf', TfidfVectorizer(tokenizer=tokenize)),
                    ('starting_verb', StartingVerbExtractor())
                ])),
                ('clf', MultiOutputClassifier(classifier, n_jobs=-1))
               ])
    return pipeline


# In[50]:


# Build and creat a 3rd model, based on the multi-feature Pipeline above
# Try with different types of classifiers

# RandomForestClassifier
classifier = RandomForestClassifier(criterion='gini', max_depth=None, max_leaf_nodes=None,
                                    min_samples_leaf=1, min_samples_split=2, n_estimators=50)
model3 = build_model3(classifier)
model3.fit(X_train, y_train)
y_pred3 = model3.predict(X_test)
y_pred3_df = pd.DataFrame(y_pred3, columns=y.columns)
print("\n===== RandomForestClassifier =====\n")

for column in y.columns:
    print('\n---- {} ----\n{}\n'.format(column, classification_report(y_test[column], y_pred3_df[column])))

# SVC (Support Vector Machine Classifier)
'''classifier = SVC()
model4 = build_model3(classifier)
model4.fit(X_train, y_train)
y_pred4 = model4.predict(X_test)
y_pred4_df = pd.DataFrame(y_pred4, columns=y.columns)
print("\n===== SVC =====\n")

for column in y.columns:
    print('\n---- {} ----\n{}\n'.format(column, classification_report(y_test[column], y_pred4_df[column])))'''


# ### 9. Export your model as a pickle file

# In[51]:


def serialize_object(py_object, filepath):
    '''
    Serialize a Python object into a pickle file.
    In the context of this Jupyter Notebook, the object is an ML model.
    
    Input:
    - py_object: Python object to be serialized
    - filepath: path and name of the file that will contain the serialized Python object
    '''
    pickle.dump(py_object, open(filepath, "wb" ))


# In[52]:


# Export/serialize the model to a Pickle file
model_pickle_file = "ML_pipeline_classifier.p"
serialize_object(model3, model_pickle_file)


# ### 10. Use this notebook to complete `train.py`
# Use the template file attached in the Resources folder to write a script that runs the steps above to create a database and export a model based on a new dataset specified by the user.

# In[ ]:




