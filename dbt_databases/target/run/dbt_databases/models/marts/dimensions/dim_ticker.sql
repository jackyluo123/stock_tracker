
  create view "market_data"."public"."dim_ticker__dbt_tmp"
    
    
  as (
    

SELECT
    DISTINCT ticker
FROM "market_data"."public"."stg_time_series_weekly"
  );