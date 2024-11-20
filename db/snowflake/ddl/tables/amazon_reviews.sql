CREATE OR REPLACE TABLE amazon_reviews (
    product_id VARCHAR NOT NULL,
    product_name VARCHAR NOT NULL,
    category VARCHAR,
    discounted_price FLOAT NOT NULL,
    actual_price FLOAT NOT NULL,
    discount_percentage FLOAT,
    rating FLOAT DEFAULT 0.0 ,
    rating_count INT DEFAULT 0,
    about_product VARCHAR,
    user_id VARCHAR NOT NULL,
    user_name VARCHAR,
    review_id VARCHAR PRIMARY KEY,
    review_title VARCHAR,
    review_content VARCHAR NOT NULL,
    img_link VARCHAR,
    product_link VARCHAR,
    review_length INT,
    keywords ARRAY,
    sentiment_score FLOAT DEFAULT 0.0
);