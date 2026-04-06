-- Bronze Layer: Staging model for raw Airbnb calendar
-- Source: AWS S3 → Snowflake external stage

with source as (
    select * from {{ source('airbnb_raw', 'calendar') }}
),

renamed as (
    select
        listing_id,
        date                                    as calendar_date,
        available,
        -- Clean price: remove $ and commas, cast to float
        try_to_number(
            replace(replace(price, '$', ''), ',', '')
        )                                       as price,
        minimum_nights,
        maximum_nights,
        _loaded_at                              as ingested_at
    from source
)

select * from renamed
