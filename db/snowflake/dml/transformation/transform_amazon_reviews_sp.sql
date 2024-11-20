CREATE OR REPLACE PROCEDURE transform_amazon_reviews(input_table STRING, output_table STRING)
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
    -- Step 1: Create the output table with additional derived fields
    EXECUTE IMMEDIATE
    'CREATE OR REPLACE TABLE ' || output_table || ' AS
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
        sentiment_score,
        CAST(NULL AS STRING) AS discount_level,
        CAST(NULL AS BOOLEAN) AS is_positive_review,
        CAST(NULL AS BOOLEAN) AS is_long_review
    FROM ' || input_table || ' LIMIT 0';

    -- Step 2: Insert transformed data
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
        sentiment_score,
        -- Derived field: Is the discount high?
        CASE
            WHEN discount_percentage > 50 THEN ''High''
            WHEN discount_percentage BETWEEN 20 AND 50 THEN ''Medium''
            ELSE ''Low''
        END AS discount_level,
        -- Derived field: Is the review positive?
        CASE
            WHEN sentiment_score > 0 THEN TRUE
            ELSE FALSE
        END AS is_positive_review,
        -- Derived field: Does the review content indicate long reviews?
        CASE
            WHEN review_length > 100 THEN TRUE
            ELSE FALSE
        END AS is_long_review
    FROM ' || input_table;

    -- Step 3: Return confirmation
    RETURN 'Data transformation completed successfully for table: ' || output_table;
END;
$$;


CALL transform_amazon_reviews('amazon_reviews_cleaned', 'amazon_reviews_transformed');