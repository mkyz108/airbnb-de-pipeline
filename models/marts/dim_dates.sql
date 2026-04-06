-- Gold Layer: Dimension table — date spine

with date_spine as (
    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('2020-01-01' as date)",
        end_date="cast('2026-12-31' as date)"
    ) }}
)

select
    date_day                                as date_id,
    date_day                                as full_date,
    dayofweek(date_day)                     as day_of_week,
    dayname(date_day)                       as day_name,
    day(date_day)                           as day_of_month,
    month(date_day)                         as month_number,
    monthname(date_day)                     as month_name,
    quarter(date_day)                       as quarter,
    year(date_day)                          as year,
    date_trunc('week', date_day)            as week_start,
    date_trunc('month', date_day)           as month_start,
    case when dayofweek(date_day) in (1, 7)
         then true else false end           as is_weekend

from date_spine
