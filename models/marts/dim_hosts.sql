-- Gold Layer: Dimension table — hosts

with listings as (
    select * from {{ ref('silver_listings') }}
),

hosts as (
    select distinct
        host_id,
        host_name,
        host_since_date,
        -- Calculate host tenure in years
        datediff('year', host_since_date, current_date()) as host_tenure_years,
        -- Aggregate host-level stats
        count(listing_id) over (partition by host_id)  as total_listings,
        avg(nightly_price) over (partition by host_id) as avg_nightly_price,
        avg(review_score) over (partition by host_id)  as avg_review_score

    from listings
    where host_id is not null
)

select * from hosts
