CREATE OR REPLACE VIEW amazon_reviews_cleaned_vw AS
SELECT
    product_id,
    product_name,
    category,
    discounted_price,
    actual_price,
    discount_percentage,
    rating,
    rating_count,
    sentiment_score,
    CASE
        WHEN discount_percentage > 50 THEN TRUE
        ELSE FALSE
    END AS is_highly_discounted,
    CASE
        WHEN sentiment_score > 0 THEN TRUE
        ELSE FALSE
    END AS is_positive_review,
    review_title,
    review_content,
    review_length
FROM amazon_reviews
WHERE
    rating IS NOT NULL
    AND rating_count > 0
    AND sentiment_score IS NOT NULL;

    select * from amazon_reviews_cleaned_vw;
    SELECT COUNT(*) FROM amazon_reviews;
SELECT
    COUNT(*) AS total_records,
    COUNT(CASE WHEN product_id IS NULL OR TRIM(product_id) = '' THEN 1 END) AS missing_product_ids,
    COUNT(CASE WHEN rating IS NULL THEN 1 END) AS missing_ratings
FROM amazon_reviews;
