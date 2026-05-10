
  create view "market_data"."public"."stg_dividend__dbt_tmp"
    
    
  as (
    -- if we did not clean the data in Python, it would have been done here
SELECT * 
FROM "market_data"."public"."dividend"
  );