import pandas as pd
from sklearn.base import BaseEstimator, TransformerMixin
import nltk
nltk.download(['punkt', 'wordnet', 'stopwords', 'averaged_perceptron_tagger'])
from nltk.corpus import stopwords
from nltk.stem.wordnet import WordNetLemmatizer
from nltk.tokenize import word_tokenize, sent_tokenize

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
            pos_tags = nltk.pos_tag(nltk.word_tokenize(sentence))

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