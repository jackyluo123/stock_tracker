
      insert into "market_data"."public"."dividend_growth_inception" ("ticker", "ex_dividend_date", "amount", "delta_growth_since_inception", "percent_growth_since_inception")
    (
        select "ticker", "ex_dividend_date", "amount", "delta_growth_since_inception", "percent_growth_since_inception"
        from "dividend_growth_inception__dbt_tmp000922727063"
    )


  