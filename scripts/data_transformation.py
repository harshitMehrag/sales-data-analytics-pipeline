import boto3
import pandas as pd
import re
from textblob import TextBlob
import nltk
import os

# Define the directory where you want to download the NLTK data
nltk_data_path = os.path.join(os.getcwd(), 'nltk_data')
nltk.data.path.append(nltk_data_path)

# Download the necessary corpora to the specified directory
nltk.download('punkt_tab', download_dir=nltk_data_path)
nltk.download('averaged_perceptron_tagger_eng', download_dir=nltk_data_path)


#download the dataset from s3

def download_from_s3(bucket_name, file_key, download_path):
  s3 = boto3.client('s3')
  s3.download_file(bucket_name, file_key, download_path)
  print(f"Downloaded {file_key} from {bucket_name} to {download_path}")


#data cleaning and tranformation functions

def clean_price(price):
  """Remove currency symbols and commas from prices and convert to float """
  if isinstance(price, str):
    return float(price.replace('₹', '').replace(',', '').strip())
  return price

def extract_keywords(text):
    """ Extract keywords from text using a simple method (top nouns and adjectives) """
    blob = TextBlob(text)
    return [word for word, pos in blob.tags if pos in ('NN', 'JJ')]

def sentiment_analysis(text):
    """ Perform sentiment analysis and return polarity score """
    return TextBlob(text).sentiment.polarity

def transform_data(df):
    # Clean price columns
    df['discounted_price'] = df['discounted_price'].apply(clean_price)
    df['actual_price'] = df['actual_price'].apply(clean_price)

    # Clean discount percentage
    df['discount_percentage'] = df['discount_percentage'].str.replace('%', '').astype(float)

    # Clean rating count
    df['rating_count'] = df['rating_count'].str.replace(',', '').astype(float)

    # Convert rating to float
    df['rating'] = pd.to_numeric(df['rating'], errors='coerce')

    # Feature Engineering: Calculate review length
    df['review_length'] = df['review_content'].apply(lambda x: len(x) if isinstance(x, str) else 0)

    # Feature Engineering: Extract keywords from review content
    df['keywords'] = df['review_content'].apply(lambda x: extract_keywords(x) if isinstance(x, str) else [])

    # Sentiment Analysis on reviews
    df['sentiment_score'] = df['review_content'].apply(lambda x: sentiment_analysis(x) if isinstance(x, str) else 0)

    return df

  #Upload the transformed dataset back to S3
def upload_to_s3(bucket_name, file_key, upload_path):
    s3 = boto3.client('s3')
    s3.upload_file(upload_path, bucket_name, file_key)
    print(f"Uploaded {file_key} to {bucket_name}")

# Main function to execute the workflow
def main():
    bucket_name = 'sales-data-pipeline-bucket-hm'
    download_key = 'amazon.csv'
    download_path = './data/amazon.csv'
    upload_key = 'amazon_transformed.csv'
    upload_path = './data/amazon_transformed.csv'


    # Step 1: Download data from S3
    download_from_s3(bucket_name, download_key, download_path)

    # Step 2: Load data and apply transformations
    df = pd.read_csv(download_path)
    transformed_df = transform_data(df)

    # Save the transformed dataset locally
    transformed_df.to_csv(upload_path, index=False)

    # Step 3: Upload the transformed dataset back to S3
    upload_to_s3(bucket_name, upload_key, upload_path)
    print("Data transformation complete and uploaded to S3.")

# Run the script
main()