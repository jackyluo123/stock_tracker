{{ config(materialized='view') }}

-- Reminder that LAG() returns the previous row at the specified column

SELECT 
    ticker, 
    date,
    volume / LAG(volume) OVER (PARTITION BY ticker ORDER BY date) - 1 AS volume_change,
    volume > AVG(volume) OVER (PARTITION BY ticker ORDER BY date ROWS BETWEEN 12 PRECEDING AND CURRENT ROW) AS quarterly_volume_spikes,
    volume > AVG(volume) OVER (PARTITION BY ticker ORDER BY date ROWS BETWEEN 4 PRECEDING AND CURRENT ROW) AS monthly_volume_spikes

FROM {{ ref('stg_time_series_weekly') }}