-- SCD Type 2: Tracks historical changes in listing prices and availability
-- Uses dbt snapshot strategy to auto-manage start/end dates

{% snapshot scd_listings %}

{{
    config(
        target_schema='snapshots',
        unique_key='listing_id',
        strategy='timestamp',
        updated_at='updated_at',
        invalidate_hard_deletes=True
    )
}}

select
    listing_id,
    listing_name,
    nightly_price,
    is_available,
    review_score,
    neighbourhood,
    room_type,
    updated_at

from {{ ref('silver_listings') }}

{% endsnapshot %}
