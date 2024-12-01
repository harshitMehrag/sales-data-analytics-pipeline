import snowflake.connector
import os
import boto3

# Initialize the SNS client
sns_client = boto3.client('sns')

# Function to send notifications via SNS
def send_notification(subject, message):
    try:
        sns_client.publish(
            TopicArn=os.environ['SNS_TOPIC_ARN'],  # Add your SNS Topic ARN in environment variables
            Message=message,
            Subject=subject
        )
    except Exception as sns_error:
        print(f"Error sending SNS notification: {sns_error}")

# Function to validate the uploaded file from S3
def validate_file(event):
    try:
        bucket = event['Records'][0]['s3']['bucket']['name']
        key = event['Records'][0]['s3']['object']['key']
        print(f"Processing file: s3://{bucket}/{key}")

        # Validate file format (example: only CSV files allowed)
        if not key.endswith('.csv'):
            raise ValueError(f"Invalid file format for file: {key}. Only CSV files are supported.")

        print("File validation successful!")
    except Exception as validate_error:
        send_notification("File Validation Error", f"Error validating file: {validate_error}")
        raise

def lambda_handler(event, context):
    # Validate the file uploaded to S3
    validate_file(event)

    # Snowflake connection parameters
    user = os.environ['SNOWFLAKE_USER']
    password = os.environ['SNOWFLAKE_PASSWORD']
    account = os.environ['SNOWFLAKE_ACCOUNT']
    warehouse = os.environ['SNOWFLAKE_WAREHOUSE']
    database = os.environ['SNOWFLAKE_DATABASE']
    schema = os.environ['SNOWFLAKE_SCHEMA']

    # Connect to Snowflake
    try:
        conn = snowflake.connector.connect(
            user=user,
            password=password,
            account=account,
            warehouse=warehouse,
            database=database,
            schema=schema
        )
        # Create a Snowflake cursor
        cur = conn.cursor()

        # Execute the stored procedure to load data into Snowflake
        print("Executing Snowflake procedure...")
        cur.execute("CALL transform_amazon_reviews('amazon_reviews_cleaned_vw', 'amazon_reviews_transformed');")

        # Log success
        print("Snowflake stored procedure executed successfully!")
        send_notification("Snowflake Procedure Success", "The stored procedure executed successfully.")

    except snowflake.connector.errors.ProgrammingError as snowflake_error:
        error_message = f"Snowflake ProgrammingError: {snowflake_error}"
        print(error_message)
        send_notification("Snowflake Execution Error", error_message)
        raise
    except Exception as e:
        error_message = f"General Error: {e}"
        print(error_message)
        send_notification("Pipeline General Error", error_message)
        raise
    finally:
        # Close the Snowflake connection
        try:
            cur.close()
            conn.close()
        except Exception as close_error:
            print(f"Error closing Snowflake connection: {close_error}")

    return {
        'statusCode': 200,
        'body': 'Pipeline triggered and Snowflake procedure executed successfully.'
    }
