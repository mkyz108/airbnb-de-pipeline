-- Gold Layer: Fact table — bookings (calendar-based occupancy)
-- Joins calendar availability with listing info

with calendar as (
    select * from {{ ref('stg_calendar') }}
    where available = 'f'  -- 'f' = booked/occupied
),

listings as (
    select * from {{ ref('silver_listings') }}
),

fact as (
    select
        {{ dbt_utils.generate_surrogate_key(['c.listing_id', 'c.calendar_date']) }} as booking_id,
        c.listing_id,
        c.calendar_date                         as booking_date,
        date_trunc('month', c.calendar_date)    as booking_month,
        date_trunc('year', c.calendar_date)     as booking_year,
        l.host_id,
        l.neighbourhood,
        l.room_type,
        coalesce(c.price, l.nightly_price)      as nightly_price,
        c.minimum_nights,
        l.review_score,
        l.is_instant_bookable,
        current_timestamp()                     as loaded_at

    from calendar c
    left join listings l on c.listing_id = l.listing_id
)

select * from fact
