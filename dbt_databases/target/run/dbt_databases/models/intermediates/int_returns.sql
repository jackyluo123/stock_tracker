
  create view "market_data"."public"."int_returns__dbt_tmp"
    
    
  as (
    


-- the formula is (close - prev_close) / prev_close
-- we can use the LAG window function which gives us access to the previous rows
-- the opposite would be LEAD
-- The default offset for these functions is 1 row

WITH base AS (
   SELECT 
       ticker, 
       date,
       volume,
       (close - LAG(close) OVER (PARTITION BY ticker ORDER BY date)) / 
           LAG(close) OVER (PARTITION BY ticker ORDER BY date) as weekly_return,
       (close - LAG(close, 4) OVER (PARTITION BY ticker ORDER BY date)) / 
           LAG(close, 4) OVER (PARTITION BY ticker ORDER BY date) as monthly_return,
       (close - LAG(close, 12) OVER (PARTITION BY ticker ORDER BY date)) / 
           LAG(close, 12) OVER (PARTITION BY ticker ORDER BY date) as three_month_return,
       (close - LAG(close, 52) OVER (PARTITION BY ticker ORDER BY date)) / 
           LAG(close, 52) OVER (PARTITION BY ticker ORDER BY date) as yearly_return
    FROM "market_data"."public"."stg_time_series_weekly"
) 
SELECT 
   ticker,
   date,
   weekly_return,
   monthly_return,
   three_month_return,
   yearly_return,
   weekly_return * volume AS price_volume_confirmation

FROM base
  );