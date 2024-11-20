CREATE OR REPLACE PROCEDURE clean_amazon_reviews(input_table STRING, output_table STRING)
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
    -- Step 1: Create or replace the output table dynamically
    EXECUTE IMMEDIATE
    'CREATE OR REPLACE TABLE ' || output_table || ' AS
    SELECT * FROM ' || input_table || ' LIMIT 0';

    -- Step 2: Insert cleaned data dynamically
    EXECUTE IMMEDIATE
    'INSERT INTO ' || output_table || '
    SELECT
        product_id,
        product_name,
        category,
        discounted_price,
        actual_price,
        discount_percentage,
        rating,
        rating_count,
        about_product,
        user_id,
        user_name,
        review_id,
        review_title,
        review_content,
        img_link,
        product_link,
        review_length,
        keywords,
        sentiment_score
    FROM ' || input_table || '
    WHERE
        product_id IS NOT NULL
        AND product_name IS NOT NULL
        AND category IS NOT NULL
        AND rating BETWEEN 1 AND 5
        AND rating_count > 0
        AND sentiment_score IS NOT NULL';

    -- Step 3: Return confirmation
    RETURN 'Data cleaning completed successfully for table: ' || output_table;
END;
$$;

CALL clean_amazon_reviews('amazon_reviews_valid', 'amazon_reviews_cleaned');

