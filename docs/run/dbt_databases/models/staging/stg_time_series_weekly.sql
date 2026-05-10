
  create view "market_data"."public"."stg_time_series_weekly__dbt_tmp"
    
    
  as (
    -- if we did not clean the data in Python, it would have been done here
SELECT * 
FROM "market_data"."public"."time_series_weekly"
  );