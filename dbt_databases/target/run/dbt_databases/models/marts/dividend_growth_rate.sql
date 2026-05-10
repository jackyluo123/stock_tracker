
      insert into "market_data"."public"."dividend_growth_rate" ("ticker", "year", "payouts_this_year", "payouts_last_year", "yearly_growth_rate")
    (
        select "ticker", "year", "payouts_this_year", "payouts_last_year", "yearly_growth_rate"
        from "dividend_growth_rate__dbt_tmp000922787871"
    )


  