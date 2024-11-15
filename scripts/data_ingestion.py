import boto3
import pandas as pd
import os
from botocore.exceptions import NoCredentialsError

s3 = boto3.client('s3')

def upload_to_s3(file_name,bucket,object_name=None):
  """Upload a file to an S3 bucket"""
  if object_name is None:
    object_name = os.path.basename(file_name)
  try:
    s3.upload_file(file_name, bucket, object_name)
    print(f"File {file_name} uploaded to {bucket}/{object_name}")
  except NoCredentialsError:
    print("Error: AWS Credentials not found.")


def main():
  #Define path to your CSV file
  csv_path = 'data/raw/amazon.csv'

  #Define your S3 bucket name
  bucket_name = 'sales-data-pipeline-bucket-hm'

  #Upload file to S3
  upload_to_s3(csv_path,bucket_name)

if __name__ == '__main__':
    main()