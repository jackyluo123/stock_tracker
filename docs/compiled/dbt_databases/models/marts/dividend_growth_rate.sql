

-- We want to sum up all dividend payments in a year
-- Then we need to get the difference between x and x-1
-- Then we can first make a table with just the grouped dividend payments

WITH yearly_payout AS (
   SELECT 
      ticker, 
      EXTRACT(YEAR FROM ex_dividend_date) AS year, 
      SUM(amount) as payout, 
      COUNT(*) as num_payouts
   FROM "market_data"."public"."stg_dividend"
   GROUP BY ticker, EXTRACT(YEAR FROM ex_dividend_date)
)
SELECT

   currYear.ticker,
   currYear.year,
   currYear.num_payouts AS payouts_this_year,
   pastYear.num_payouts AS payouts_last_year,
   (currYear.payout - pastYear.payout) / NULLIF(pastYear.payout, 0) AS yearly_growth_rate

FROM yearly_payout AS currYear
LEFT JOIN yearly_payout AS pastYear
   ON currYear.year = pastYear.year + 1 AND currYear.ticker = pastYear.ticker
ORDER BY currYear.ticker, currYear.year

-- Use LEFT JOIN even though there is no past year on the first year so at least we can see the first year with null data
-- Not using LEFT JOIN will display the first year with growth data which may seem confusing