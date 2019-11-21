# Disaster Response Web App

## Introduction
In the context of the **[Udacity Data Scientist Nanodegree](https://classroom.udacity.com/nanodegrees/nd025/)**, the present repository contains the components of a Web application which categorizes emergency messages during a disaster. The resulting categories assigned to each message can then be used to warn the relevant aid organizations. The training & testing data was provided by **[Figure Eight](https://www.figure-eight.com/data-for-everyone/)**.

## Component Files and Data Structure
The application code was originally elaborated within the 2 Jupyter Notebooks **ETL Pipeline Preparation.ipynb** and **ML Pipeline Preparation.ipynb**.
* **app**
  * **run.py**: retrieves the clean data from a previously created SQLite database (*cf* **process_data.py**), loads a previously trained model from a pickle file (*cf* **train_classifier.py**) and executes it on a user-entered phrase, relative to some kind of disaster (my example: "*Help! My house is burning despite the pouring rain; we have no electricity and fear a shortage of food!*").
  * **templates**
    * **go.html** and **master.html** display a Web page with a form for submitting the text message, a plot with the distribution of the data used to train and test the model, and a table with the resulting categories matching the messsage.
* **data**
  * **disaster_categories.csv** and **disaster_messages.csv**: the original uncleaned data in CSV format.
  * **DisasterResponse.db**: the cleaned up data in an SQLite database table.
  * **process_data.py**: reads in the data from the 2 CSV files above, cleans it, and stores it into the newly created database above.
* **models**
  * **train_classifier.py**: reads the cleaned data from **DisasterRecovery.db** and trains a classifier whose parameters were originally fine-tuned in **ML Pipeline Preparation.ipynb** *via* Grid Search Cross Validation.
  * **starting_verb_extractor.py**: defines class StartingVerbExtractor which is used by **train_classifier.py** in a classification Pipeline.
  * **classifier.pkl**: the classification model created within **train_classifier.py** and saved as a pickle file.

## Running the Application

### Prerequisites
This application is written in HTML and in Python 3; the latter requires the following libraries: flask, nltk, numpy, pandas, pickle, plotly, re, sklearn, sqlalchemy, and sys.

### Instructions:
1. Run the following commands in the project's root directory to set up your database and model.

    - To run ETL pipeline that cleans data and stores in database
        `python data/process_data.py data/disaster_messages.csv data/disaster_categories.csv data/DisasterResponse.db`
    - To run ML pipeline that trains classifier and saves
        `python models/train_classifier.py data/DisasterResponse.db models/classifier.pkl`

2. Run the following command in the app's directory to run your web app.
    `python run.py`

3. Go to http://0.0.0.0:3001/

## Screenshots of the running Disaster Recovery application

***Initial Page - Before Category Prediction***
![Before](https://github.com/ChristopheBunn/Udacity-Data-Scientist-Nanodegree/blob/master/Jupyter%20Notebooks/9%20-%20Data%20Engineering/Project%20-%20Disaster%20Response%20Pipeline/images/Web_app_1.png)

***Final Page - Category Prediction***
![After](https://github.com/ChristopheBunn/Udacity-Data-Scientist-Nanodegree/blob/master/Jupyter%20Notebooks/9%20-%20Data%20Engineering/Project%20-%20Disaster%20Response%20Pipeline/images/Web_app_2.png)