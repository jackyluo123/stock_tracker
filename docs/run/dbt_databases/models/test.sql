
  create view "market_data"."public"."test__dbt_tmp"
    
    
  as (
    SELECT * 
FROM dividend
LIMIT 2
  );