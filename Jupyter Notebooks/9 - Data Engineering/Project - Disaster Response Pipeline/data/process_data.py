import sys
import pandas as pd
from sqlalchemy import create_engine


def load_data(messages_filepath, categories_filepath):
    '''
    Read Message and Category data from their respective CSV files
    and merge into a single DataFrame for further processing.
    
    Input:
     - messages_filepath: path to the Messages CSV file
     - categories_filepath: path to the Categories CSV file
     
    Output:
     - the merged Message + Category data as a DataFrame
    '''
    messages = pd.read_csv(messages_filepath)
    categories = pd.read_csv(categories_filepath)
    
    return messages.merge(categories, how='left', on=['id'])


def clean_data(df):
    '''
    From the Disaster Relief DataFrame:
     - split the Categories feature/column into as many features as there are categories;
     - convert the values for these features to numeric 0 or 1;
     - remove duplicate rows.
     
    Input:
     - df: Disaster Relief DataFrame, containing Message and Category data
     
    Output:
     - the cleaned up Disaster Relief DataFrame
    '''
    # Create a DataFrame of the individual category columns
    categories = df['categories'].str.split(';', expand=True)
    
    # Extract a list of new column names for categories from the first row of the categories DataFrame
    row = categories.iloc[0]
    start, stop, step = 0, -2, 1
    category_colnames = row.str.slice(start, stop, step)
    
    # Rename the columns of `categories`
    categories.columns = category_colnames
    
    # Convert category values to just numbers 0 or 1
    for column in categories:
        # set each value to be the last character of the string
        categories[column] = categories[column].str[-1]
        
        # convert column from string to numeric
        categories[column] = categories[column].astype(int)
        
        # ensure non-zero values are 1
        categories[column] = categories[column].apply(lambda x: 1 if x > 1 else x)
        
    # Replace the `categories` column in df with the new columns in the categories DataFrame
    df.drop(['categories'], axis=1, inplace=True)
    df = pd.concat([df, categories], axis=1)
    
    # Remove duplicates
    df.drop_duplicates(inplace=True)
    
    return df


def save_data(df, database_filename):
    '''
    Saves the contents of the df DataFrame into a table of the SQLite database
    
    Input:
     - df: the Disaster Relief DataFrame (Messages + Categories)
     - database_filename: the URL to the SQLite database
    '''
    engine = create_engine(database_filename)
    df.to_sql('Bunn_DisasterResponse', engine, if_exists='replace', index=False)


def main():
    if len(sys.argv) == 4:

        messages_filepath, categories_filepath, database_filepath = sys.argv[1:]

        print('Loading data...\n    MESSAGES: {}\n    CATEGORIES: {}'
              .format(messages_filepath, categories_filepath))
        df = load_data(messages_filepath, categories_filepath)

        print('Cleaning data...')
        df = clean_data(df)
        
        print('Saving data...\n    DATABASE: {}'.format(database_filepath))
        save_data(df, database_filepath)
        
        print('Cleaned data saved to database!')
    
    else:
        print('Please provide the filepaths of the messages and categories '\
              'datasets as the first and second argument respectively, as '\
              'well as the filepath of the database to save the cleaned data '\
              'to as the third argument. \n\nExample: python process_data.py '\
              'disaster_messages.csv disaster_categories.csv '\
              'DisasterResponse.db')


if __name__ == '__main__':
    main()