CREATE OR REPLACE PROCEDURE validate_amazon_reviews(input_table STRING, valid_table STRING, invalid_table STRING)
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
    -- Step 1: Create tables for valid and invalid data
    EXECUTE IMMEDIATE
    'CREATE OR REPLACE TABLE ' || valid_table || ' AS
    SELECT * FROM ' || input_table || ' LIMIT 0';

    EXECUTE IMMEDIATE
    'CREATE OR REPLACE TABLE ' || invalid_table || ' AS
    SELECT * FROM ' || input_table || ' LIMIT 0';

    -- Step 2: Validate data and insert into respective tables
    -- Criteria for valid rows: no NULLs in critical fields, rating in range, etc.
    EXECUTE IMMEDIATE
    'INSERT INTO ' || valid_table || '
    SELECT *
    FROM ' || input_table || '
    WHERE
        product_id IS NOT NULL
        AND product_name IS NOT NULL
        AND category IS NOT NULL
        AND rating BETWEEN 1 AND 5
        AND rating_count > 0';

    -- Criteria for invalid rows
    EXECUTE IMMEDIATE
    'INSERT INTO ' || invalid_table || '
    SELECT *
    FROM ' || input_table || '
    WHERE
        product_id IS NULL
        OR product_name IS NULL
        OR category IS NULL
        OR rating NOT BETWEEN 1 AND 5
        OR rating_count <= 0';

    -- Step 3: Return confirmation
    RETURN 'Data validation completed. Valid rows in: ' || valid_table || ', Invalid rows in: ' || invalid_table;
END;
$$;

CALL validate_amazon_reviews('amazon_reviews', 'amazon_reviews_valid', 'amazon_reviews_invalid');

