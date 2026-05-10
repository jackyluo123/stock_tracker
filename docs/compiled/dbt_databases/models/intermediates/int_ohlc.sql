

-- GREATEST and LEAST are used here
-- Unlike MAX and MIN, GREATEST and LEAST only compares the listed numbers and returns the higher or lower of them
-- MAX and MIN return the highest and lower of the entire column

SELECT 
    ticker, 
    date,
    (high - low) / open AS weekly_range,
    ABS(close - open) AS candle_body,
    (high - GREATEST(open, close))  AS upper_wick,
    (LEAST(open, close) - low) AS lower_wick,
    (high - low) AS wick_body

FROM "market_data"."public"."stg_time_series_weekly"