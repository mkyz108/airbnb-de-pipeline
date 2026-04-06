-- Singular test: All listing prices must be positive
-- This test will FAIL (and block pipeline) if any negative or zero prices exist

select
    listing_id,
    nightly_price
from {{ ref('silver_listings') }}
where nightly_price <= 0
   or nightly_price is null
