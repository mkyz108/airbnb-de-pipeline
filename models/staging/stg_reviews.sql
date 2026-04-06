-- Bronze Layer: Staging model for raw Airbnb reviews
-- Source: AWS S3 → Snowflake external stage

with source as (
    select * from {{ source('airbnb_raw', 'reviews') }}
),

renamed as (
    select
        id              as review_id,
        listing_id,
        date            as review_date,
        reviewer_id,
        reviewer_name,
        comments        as review_text,
        _loaded_at      as ingested_at
    from source
)

select * from renamed
