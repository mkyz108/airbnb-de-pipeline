-- Bronze Layer: Staging model for raw Airbnb listings
-- Source: AWS S3 → Snowflake external stage

with source as (
    select * from {{ source('airbnb_raw', 'listings') }}
),

renamed as (
    select
        id                          as listing_id,
        listing_url,
        name                        as listing_name,
        description,
        host_id,
        host_name,
        host_since,
        neighbourhood_cleansed      as neighbourhood,
        latitude,
        longitude,
        room_type,
        accommodates,
        bathrooms_text,
        bedrooms,
        beds,
        price,
        minimum_nights,
        maximum_nights,
        has_availability,
        availability_365,
        number_of_reviews,
        first_review,
        last_review,
        review_scores_rating,
        instant_bookable,
        _loaded_at                  as ingested_at

    from source
)

select * from renamed
