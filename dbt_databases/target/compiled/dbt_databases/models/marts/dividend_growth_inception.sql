

WITH difference AS (
    SELECT 
    ticker,
    ex_dividend_date,
    amount,
    FIRST_VALUE(amount) OVER (PARTITION BY ticker ORDER BY ex_dividend_date) AS first_payout
    FROM "market_data"."public"."stg_dividend"
)
SELECT 
    ticker, 
    ex_dividend_date, 
    amount,
    amount - first_payout AS delta_growth_since_inception,
    (amount - first_payout) / first_payout AS percent_growth_since_inception
FROM difference