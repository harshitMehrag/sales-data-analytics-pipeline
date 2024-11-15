import os
import snowflake.connector
import pandas as pd

# Define connection parameters
connection_parameters = {
    "account": os.getenv("SNOWFLAKE_ACCOUNT"),
    "user": os.getenv("HARSHITMEHRA"),
    "password": os.getenv("Harshit@123"),
    "role": "your_role",  # Optional
    "warehouse": "your_warehouse",  # Optional
    "database": "your_database",  # Optional
    "schema": "your_schema"  # Optional
}
