{{ config(materialized='view') }}

WITH base AS (
    SELECT
    ticker,
    date,
    close,
    AVG(close) OVER (PARTITION BY ticker ORDER BY date ROWS BETWEEN 4 PRECEDING AND CURRENT ROW) AS week_4_MA,
    AVG(close) OVER (PARTITION BY ticker ORDER BY date ROWS BETWEEN 12 PRECEDING AND CURRENT ROW) AS week_12_MA,
    AVG(close) OVER (PARTITION BY ticker ORDER BY date ROWS BETWEEN 52 PRECEDING AND CURRENT ROW) AS week_52_MA
    FROM {{ ref('stg_time_series_weekly') }}
)
SELECT
    ticker,
    date,
    week_4_MA,
    week_12_MA,
    week_52_MA,
    CASE 
    WHEN week_4_MA > week_12_MA AND close > week_4_MA THEN 1
    WHEN week_4_MA < week_12_MA AND close < week_4_MA THEN 1
    ELSE 0
    END AS moving_ave_trend_flag
FROM base