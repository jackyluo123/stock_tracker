
      insert into "market_data"."public"."dividend_growth_inception_delta" ("ticker", "ex_dividend_date", "growth")
    (
        select "ticker", "ex_dividend_date", "growth"
        from "dividend_growth_inception_delta__dbt_tmp202659428993"
    )


  