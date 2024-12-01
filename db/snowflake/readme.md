### How to Run the Scripts
1. Upload `clean_amazon_reviews_sp.sql` to Snowflake and execute it to clean the data.
2. Use `validate_amazon_reviews_sp.sql` to separate valid and invalid records.
3. Run `transform_amazon_reviews_sp.sql` to enrich the cleaned data.
4. Create a view using `amazon_reviews_cleaned_view.sql` for easy querying.
