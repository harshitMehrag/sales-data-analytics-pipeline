SELECT product_name, AVG(rating) AS avg_rating, COUNT(rating) AS total_reviews
FROM amazon_reviews
GROUP BY product_name
ORDER BY avg_rating DESC
LIMIT 10;

SELECT keywords, COUNT(*) AS keyword_count
FROM amazon_reviews
GROUP BY keywords
ORDER BY keyword_count DESC
LIMIT 10;

SELECT sentiment_score, COUNT(*) AS count
FROM amazon_reviews
GROUP BY sentiment_score;
