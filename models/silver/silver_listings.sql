-- Silver Layer: Cleaned and enriched listings
-- Applies business logic, handles nulls, standardizes formats

{{
    config(
        materialized='incremental',
        unique_key='listing_id',
        on_schema_change='sync_all_columns'
    )
}}

with staged as (
    select * from {{ ref('stg_listings') }}
),

cleaned as (
    select
        listing_id,
        listing_name,
        description,
        host_id,
        host_name,
        host_since::date                            as host_since_date,
        neighbourhood,
        latitude::float                             as latitude,
        longitude::float                            as longitude,
        room_type,
        accommodates::int                           as accommodates,
        coalesce(bedrooms::int, 0)                  as bedrooms,
        coalesce(beds::int, 0)                      as beds,
        -- Clean price column
        try_to_number(
            replace(replace(price, '$', ''), ',', '')
        )                                           as nightly_price,
        minimum_nights::int                         as minimum_nights,
        maximum_nights::int                         as maximum_nights,
        case when has_availability = 't' then true
             else false end                         as is_available,
        availability_365::int                       as availability_365,
        number_of_reviews::int                      as number_of_reviews,
        first_review::date                          as first_review_date,
        last_review::date                           as last_review_date,
        review_scores_rating::float                 as review_score,
        case when instant_bookable = 't' then true
             else false end                         as is_instant_bookable,
        ingested_at,
        current_timestamp()                         as updated_at

    from staged
    where listing_id is not null
      and nightly_price > 0  -- Filter invalid prices
)

select * from cleaned

{% if is_incremental() %}
    where ingested_at > (select max(ingested_at) from {{ this }})
{% endif %}
