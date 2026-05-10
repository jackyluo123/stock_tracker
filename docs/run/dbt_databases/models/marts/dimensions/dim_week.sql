
  create view "market_data"."public"."dim_week__dbt_tmp"
    
    
  as (
    

-- we want to convert the weekly dates into year, month, quarter
WITH dates AS (
SELECT
    DISTINCT date
FROM "market_data"."public"."stg_time_series_weekly"
),
base AS (
SELECT 
    DISTINCT date,
    EXTRACT(YEAR FROM date) AS year,
    EXTRACT(MONTH FROM date) AS month,
    EXTRACT(QUARTER FROM date) AS quarter,
    EXTRACT(WEEK FROM date) AS week
FROM dates
)
SELECT 
    *,
    CONCAT(CAST(year AS TEXT), '-W', LPAD(CAST(week AS TEXT), 2, '0')) AS year_week
FROM base
  );