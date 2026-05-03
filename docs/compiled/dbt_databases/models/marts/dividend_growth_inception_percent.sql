

/*
-- THIS IS USING NON-WINDOW FUNCTIONS
WITH first_date AS (
   SELECT ticker, MIN(ex_dividend_date) as ex_dividend_date
   FROM dividend
   GROUP BY ticker
),
first_payment AS (
   SELECT d.ticker, d.amount
   FROM dividend AS d
   INNER JOIN first_date AS f
      ON f.ticker = d.ticker AND f.ex_dividend_date = d.ex_dividend_date
)

SELECT d.ticker, d.ex_dividend_date, (d.amount - f.amount) / f.amount as growth
FROM dividend AS d
JOIN first_payment AS f
ON d.ticker = f.ticker
ORDER BY d.ticker, d.ex_dividend_date

*/

-- THIS IS USING WINDOW FUNCTIONS
WITH difference AS (
   SELECT ticker, ex_dividend_date, amount, FIRST_VALUE(amount) OVER (PARTITION BY ticker ORDER BY ex_dividend_date) AS first_val
   FROM "market_data"."public"."stg_dividend"
)
SELECT ticker, ex_dividend_date, (amount - first_val) / NULLIF(first_val, 0) AS growth
FROM difference