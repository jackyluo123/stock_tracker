-- depends_on: {{ ref('stg_time_series_weekly') }}
{{ config(materialized='view') }}

SELECT 
    tsw.ticker, 
    tsw.date,
    tsw.close,
    tsw.volume,
    sf.weekly_return,
    sf.monthly_return,
    sf.three_month_return,
    sf.week_4_MA,
    sf.week_12_MA,
    sf.week_52_MA,
    sf.monthly_volatility,
    sf.quarterly_volatility,
    sf.moving_ave_trend_flag,
    sf.trend_flag

FROM {{ ref('stg_time_series_weekly') }} AS tsw
INNER JOIN {{ ref('int_stock_features') }} AS sf
   ON tsw.ticker = sf.ticker AND tsw.date = sf.date