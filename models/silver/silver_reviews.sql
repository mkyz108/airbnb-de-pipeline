-- Silver Layer: Cleaned reviews with sentiment indicators

{{
    config(
        materialized='incremental',
        unique_key='review_id',
        on_schema_change='sync_all_columns'
    )
}}

with staged as (
    select * from {{ ref('stg_reviews') }}
),

cleaned as (
    select
        review_id,
        listing_id,
        review_date::date               as review_date,
        date_trunc('month', review_date::date) as review_month,
        date_trunc('year', review_date::date)  as review_year,
        reviewer_id,
        reviewer_name,
        review_text,
        len(review_text)                as review_length,
        ingested_at,
        current_timestamp()             as updated_at

    from staged
    where review_id is not null
      and review_date is not null
)

select * from cleaned

{% if is_incremental() %}
    where ingested_at > (select max(ingested_at) from {{ this }})
{% endif %}
