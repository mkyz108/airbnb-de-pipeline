-- ============================================================
-- Snowflake Setup Script for Airbnb DE Project
-- Run these commands in your Snowflake worksheet
-- ============================================================

-- Step 1: Create warehouse
CREATE WAREHOUSE IF NOT EXISTS COMPUTE_WH
  WAREHOUSE_SIZE = 'X-SMALL'
  AUTO_SUSPEND = 120
  AUTO_RESUME = TRUE;

-- Step 2: Create database and schemas
CREATE DATABASE IF NOT EXISTS AIRBNB;

CREATE SCHEMA IF NOT EXISTS AIRBNB.RAW;        -- Bronze: raw ingested data
CREATE SCHEMA IF NOT EXISTS AIRBNB.SILVER;     -- Silver: cleaned data
CREATE SCHEMA IF NOT EXISTS AIRBNB.GOLD;       -- Gold: analytics-ready
CREATE SCHEMA IF NOT EXISTS AIRBNB.SNAPSHOTS;  -- SCD Type 2 history

-- Step 3: Create role and user for dbt
CREATE ROLE IF NOT EXISTS TRANSFORM;
GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE TRANSFORM;
GRANT ALL ON DATABASE AIRBNB TO ROLE TRANSFORM;
GRANT ALL ON ALL SCHEMAS IN DATABASE AIRBNB TO ROLE TRANSFORM;
GRANT ALL ON FUTURE SCHEMAS IN DATABASE AIRBNB TO ROLE TRANSFORM;
GRANT ALL ON ALL TABLES IN DATABASE AIRBNB TO ROLE TRANSFORM;
GRANT ALL ON FUTURE TABLES IN DATABASE AIRBNB TO ROLE TRANSFORM;

CREATE USER IF NOT EXISTS DBT_USER
  PASSWORD = 'YourStrongPassword123!'
  DEFAULT_ROLE = TRANSFORM
  DEFAULT_WAREHOUSE = COMPUTE_WH;

GRANT ROLE TRANSFORM TO USER DBT_USER;

-- Step 4: Create external stage for AWS S3
-- Replace with your actual S3 bucket and IAM credentials
CREATE STAGE IF NOT EXISTS AIRBNB.RAW.S3_STAGE
  URL = 's3://your-airbnb-bucket/data/'
  CREDENTIALS = (
    AWS_KEY_ID = 'YOUR_AWS_KEY_ID'
    AWS_SECRET_KEY = 'YOUR_AWS_SECRET_KEY'
  )
  FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1);

-- Step 5: Create raw tables
CREATE TABLE IF NOT EXISTS AIRBNB.RAW.LISTINGS (
    id              VARCHAR,
    listing_url     VARCHAR,
    name            VARCHAR,
    description     VARCHAR,
    host_id         VARCHAR,
    host_name       VARCHAR,
    host_since      VARCHAR,
    neighbourhood_cleansed VARCHAR,
    latitude        VARCHAR,
    longitude       VARCHAR,
    room_type       VARCHAR,
    accommodates    VARCHAR,
    bathrooms_text  VARCHAR,
    bedrooms        VARCHAR,
    beds            VARCHAR,
    price           VARCHAR,
    minimum_nights  VARCHAR,
    maximum_nights  VARCHAR,
    has_availability VARCHAR,
    availability_365 VARCHAR,
    number_of_reviews VARCHAR,
    first_review    VARCHAR,
    last_review     VARCHAR,
    review_scores_rating VARCHAR,
    instant_bookable VARCHAR,
    _loaded_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

CREATE TABLE IF NOT EXISTS AIRBNB.RAW.REVIEWS (
    id              VARCHAR,
    listing_id      VARCHAR,
    date            VARCHAR,
    reviewer_id     VARCHAR,
    reviewer_name   VARCHAR,
    comments        VARCHAR,
    _loaded_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

CREATE TABLE IF NOT EXISTS AIRBNB.RAW.CALENDAR (
    listing_id      VARCHAR,
    date            VARCHAR,
    available       VARCHAR,
    price           VARCHAR,
    minimum_nights  VARCHAR,
    maximum_nights  VARCHAR,
    _loaded_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

-- Step 6: Load data from S3 stage
COPY INTO AIRBNB.RAW.LISTINGS
FROM @AIRBNB.RAW.S3_STAGE/listings.csv
ON_ERROR = 'CONTINUE';

COPY INTO AIRBNB.RAW.REVIEWS
FROM @AIRBNB.RAW.S3_STAGE/reviews.csv
ON_ERROR = 'CONTINUE';

COPY INTO AIRBNB.RAW.CALENDAR
FROM @AIRBNB.RAW.S3_STAGE/calendar.csv
ON_ERROR = 'CONTINUE';
