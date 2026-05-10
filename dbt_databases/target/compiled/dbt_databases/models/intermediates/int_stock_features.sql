

SELECT 
    r.ticker,
    r.date,
    r.weekly_return,
    r.monthly_return,
    r.three_month_return,
    r.yearly_return,
    r.price_volume_confirmation,

    tsw.high,
    tsw.low,
    tsw.open,
    tsw.close,
    o.weekly_range,
    o.candle_body,
    o.upper_wick,
    o.lower_wick,

    v.monthly_volatility,
    v.quarterly_volatility,
    v.half_year_volatility,
    v.yearly_volatility,

    va.volume_change,
    va.quarterly_volume_spikes,
    va.monthly_volume_spikes,

    m.week_4_MA,
    m.week_12_MA,
    m.week_52_MA,
    m.moving_ave_trend_flag,
    CASE 
        WHEN m.week_4_MA > m.week_12_MA AND tsw.close > m.week_4_MA AND r.monthly_return > 0 THEN 1
        WHEN m.week_4_MA < m.week_12_MA AND tsw.close < m.week_4_MA AND r.monthly_return < 0 THEN -1
    ELSE 0
    END AS trend_flag
    
FROM "market_data"."public"."stg_time_series_weekly" AS tsw
INNER JOIN "market_data"."public"."int_returns" AS r
    ON tsw.ticker = r.ticker AND tsw.date = r.date
INNER JOIN "market_data"."public"."int_volatility" AS v
    ON tsw.ticker = v.ticker AND tsw.date = v.date
INNER JOIN "market_data"."public"."int_volume_analytics" AS va
    ON tsw.ticker = va.ticker AND tsw.date = va.date
INNER JOIN "market_data"."public"."int_moving_averages" AS m
    ON tsw.ticker = m.ticker AND tsw.date = m.date
INNER JOIN "market_data"."public"."int_ohlc" AS o
    ON tsw.ticker = o.ticker AND tsw.date = o.date