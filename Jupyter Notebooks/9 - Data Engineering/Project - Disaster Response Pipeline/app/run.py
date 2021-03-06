import json
import plotly
import pandas as pd

from nltk.stem import WordNetLemmatizer
from nltk.tokenize import word_tokenize

from flask import Flask
from flask import render_template, request, jsonify
from plotly.graph_objs import Bar
from sklearn.externals import joblib
from sqlalchemy import create_engine

import sys
sys.path.append("/home/workspace/models")
from starting_verb_extractor import StartingVerbExtractor


app = Flask(__name__)

def tokenize(text):
    tokens = word_tokenize(text)
    lemmatizer = WordNetLemmatizer()

    clean_tokens = []
    for tok in tokens:
        clean_tok = lemmatizer.lemmatize(tok).lower().strip()
        clean_tokens.append(clean_tok)

    return clean_tokens

# load data
engine = create_engine('sqlite:///../data/DisasterResponse.db')
df = pd.read_sql_table('Bunn_DisasterResponse', engine)

# load model
model = joblib.load("../models/classifier.pkl")


# index webpage displays cool visuals and receives user input text for model
@app.route('/')
@app.route('/index')
def index():
    
    # Extract data needed for visuals.
    # Add to the "genre" status whether the message is "related" to Disaster Response.
    genre_counts = df.groupby('genre').count()['message']
    genre_names = list(genre_counts.index)
    genre_related_counts = df[df['related'] == 1].groupby('genre').count()['message']
    genre_unrelated_counts = df[df['related'] == 0].groupby('genre').count()['message']
    
    # Category counts data (keep only 0/1 numeric features, i.e., categories):
    category_percent = df.drop(['id', 'message', 'original', 'genre'], axis=1).sum()/len(df)*100
    category_percent = category_percent.sort_values(ascending=False)
    category_labels = list(category_percent.index)
    
    # Create visuals
    # - Incorporate the "related" feature to the existing "genre" plot.
    # - Add a plot with percentage of "categories"
    graphs = [
        {
            'data': [
                Bar(
                    x=genre_names,
                    y=genre_related_counts,
                    name = 'Related'
                ),
                Bar(
                    x=genre_names,
                    y=genre_unrelated_counts,
                    name = 'Unrelated'
                )
            ],

            'layout': {
                'title': 'Distribution of Message Genres (related and unrelated to Disaster Response)',
                'yaxis': {
                    'title': "Count"
                },
                'xaxis': {
                    'title': "Genre & Related"
                },
                'barmode': 'group'
            }
        },
        {
            'data': [
                Bar(
                    x=category_labels,
                    y=category_percent
                )
            ],

            'layout': {
                'title': 'Categories (% total messages)',
                'yaxis': {
                    'title': "%"
                },
                'xaxis': {
                    'title': "Categories",
                    'tickangle': -30
                }
            }
        }
    ]
    
    # encode plotly graphs in JSON
    ids = ["graph-{}".format(i) for i, _ in enumerate(graphs)]
    graphJSON = json.dumps(graphs, cls=plotly.utils.PlotlyJSONEncoder)
    
    # render web page with plotly graphs
    return render_template('master.html', ids=ids, graphJSON=graphJSON)


# web page that handles user query and displays model results
@app.route('/go')
def go():
    # save user input in query
    query = request.args.get('query', '') 

    # use model to predict classification for query
    classification_labels = model.predict([query])[0]
    classification_results = dict(zip(df.columns[4:], classification_labels))

    # This will render the go.html Please see that file. 
    return render_template(
        'go.html',
        query=query,
        classification_result=classification_results
    )


def main():
    app.run(host='0.0.0.0', port=3001, debug=True)


if __name__ == '__main__':
    main()