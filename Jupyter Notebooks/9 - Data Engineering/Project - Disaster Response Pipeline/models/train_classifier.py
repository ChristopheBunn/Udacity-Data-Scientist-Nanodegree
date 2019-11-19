import sys
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

def load_data(database_filepath):
    '''
    Load the contents of a DB table into a DataFrame.
    
    Input:
    - database_filepath: the path to the database
    
    Output:
    - X (pandas Series): the Messages (features used to predict the Categories)
    - y (pandas DataFrame): the Categories (this is a multi-categorical problem: 1 per column)
    - Category names (pandas Index)
    '''
    engine = create_engine('sqlite:///{}'.format(database_filepath))
    df = pd.read_sql_table('Bunn_DisasterResponse', con=engine)
    
    X = df['message']
    y = df.drop(['id', 'message', 'original', 'genre'], axis=1)
    
    return X, y, y.columns


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

class StartingVerbExtractor(BaseEstimator, TransformerMixin):
    '''
    Custom Transformer for detecting phrases that start with a verb or retweets.
    It will be used to add features other than TF-IDF.
    '''

    def starting_verb(self, text):

        # tokenize into sentences
        sentence_list = nltk.sent_tokenize(text)

        for sentence in sentence_list:

            # tokenize into words and tag Part of Speech
            pos_tags = nltk.pos_tag(tokenize(sentence))

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

def build_model():
    '''
    Builds a Pipeline model for Natural Language Processing using:
     - Features: TF-IDF and Starting Verb Extractor
     - Classifier: Multi-output Random Forest Classifier with the best parameters
                   identified using Grid Search Cross Validation
    
    Output:
    - the resulting Pipeline model
    '''
    classifier = RandomForestClassifier(criterion='gini', max_depth=None, max_leaf_nodes=None,
                                        min_samples_leaf=1, min_samples_split=2, n_estimators=50)

    pipeline = Pipeline([
                ('features', FeatureUnion([
                    ('tfidf', TfidfVectorizer(tokenizer=tokenize)),
                    ('starting_verb', StartingVerbExtractor())
                ])),
                ('clf', MultiOutputClassifier(classifier, n_jobs=-1))
               ])
    return pipeline


def evaluate_model(model, X_test, Y_test, category_names):
    '''
    Make predictions and print out the model's Precision, Recall, and F1 Score.
    
    Input:
     - model: the model that has been previously fit on training data
     - X_test (Series): the test Messages
     - Y_test (DataFrame): the test Categories
     - category_names: the Category names
    '''
    y_pred = model.predict(X_test)
    y_pred_df = pd.DataFrame(y_pred, columns=category_names)
    
    for column in category_names:
        print('\n---- {} ----\n{}\n'.format(column, classification_report(Y_test[column], y_pred_df[column])))


def save_model(model, model_filepath):
    '''
    Serialize a Python object into a pickle file.
    In the context of this Jupyter Notebook, the object is an ML model.
    
    Input:
    - py_object: Python object to be serialized
    - filepath: path and name of the file that will contain the serialized Python object
    '''
    pickle.dump(model, open(model_filepath, "wb" ))


def main():
    if len(sys.argv) == 3:
        database_filepath, model_filepath = sys.argv[1:]
        print('Loading data...\n    DATABASE: {}'.format(database_filepath))
        X, Y, category_names = load_data(database_filepath)
        X_train, X_test, Y_train, Y_test = train_test_split(X, Y, test_size=0.2)
        
        print('Building model...')
        model = build_model()
        
        print('Training model...')
        model.fit(X_train, Y_train)
        
        print('Evaluating model...')
        evaluate_model(model, X_test, Y_test, category_names)

        print('Saving model...\n    MODEL: {}'.format(model_filepath))
        save_model(model, model_filepath)

        print('Trained model saved!')

    else:
        print('Please provide the filepath of the disaster messages database '\
              'as the first argument and the filepath of the pickle file to '\
              'save the model to as the second argument. \n\nExample: python '\
              'train_classifier.py ../data/DisasterResponse.db classifier.pkl')


if __name__ == '__main__':
    main()