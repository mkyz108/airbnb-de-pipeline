-- Reusable Jinja macro for incremental filtering
-- Usage: {{ incremental_filter('ingested_at') }}

{% macro incremental_filter(timestamp_col) %}
    {% if is_incremental() %}
        where {{ timestamp_col }} > (
            select max({{ timestamp_col }}) from {{ this }}
        )
    {% endif %}
{% endmacro %}


-- Macro to clean price strings (remove $, commas)
{% macro clean_price(col) %}
    try_to_number(replace(replace({{ col }}, '$', ''), ',', ''))
{% endmacro %}


-- Macro to cast boolean flags from 't'/'f' strings
{% macro bool_flag(col) %}
    case when {{ col }} = 't' then true else false end
{% endmacro %}
