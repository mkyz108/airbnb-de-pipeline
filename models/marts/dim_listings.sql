-- Gold Layer: Dimension table — listings

with listings as (
    select * from {{ ref('silver_listings') }}
)

select
    listing_id,
    listing_name,
    description,
    neighbourhood,
    latitude,
    longitude,
    room_type,
    accommodates,
    bedrooms,
    beds,
    nightly_price,
    minimum_nights,
    maximum_nights,
    availability_365,
    is_available,
    is_instant_bookable,
    review_score,
    number_of_reviews,
    first_review_date,
    last_review_date,
    updated_at

from listings
