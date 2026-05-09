{{ config(materialized='view') }}

SELECT
    DISTINCT ticker
FROM {{ ref('stg_time_series_weekly') }}