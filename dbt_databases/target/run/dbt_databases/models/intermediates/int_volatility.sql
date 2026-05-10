
  create view "market_data"."public"."int_volatility__dbt_tmp"
    
    
  as (
    


-- For Windows functions, we can specify LAG, LEAD, but we can also use ROWS BETWEEN to specify multiple rows instead of a single row
-- We require ROWS BETWEEN lower_bound AND upper_bound
-- for the bounds, we can use:
-- UNBOUNDED PRECEDING: all rows before the current row (does not include the current row)
-- n PRECEDING
-- CURRENT ROW
-- n FOLLOWING
-- UNBOUNDED FOLLOWING: all rows after the current row (does not include the current row)

SELECT 
    ticker, 
    date,
    stddev(weekly_return) OVER (PARTITION BY ticker ORDER BY DATE ROWS BETWEEN 4 PRECEDING AND CURRENT ROW) AS monthly_volatility,
    stddev(weekly_return) OVER (PARTITION BY ticker ORDER BY DATE ROWS BETWEEN 12 PRECEDING AND CURRENT ROW) AS quarterly_volatility,
    stddev(weekly_return) OVER (PARTITION BY ticker ORDER BY DATE ROWS BETWEEN 26 PRECEDING AND CURRENT ROW) AS half_year_volatility,
    stddev(weekly_return) OVER (PARTITION BY ticker ORDER BY DATE ROWS BETWEEN 52 PRECEDING AND CURRENT ROW) AS yearly_volatility

FROM "market_data"."public"."int_returns"
  );