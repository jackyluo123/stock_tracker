





with validation_errors as (

    select
        ticker, date
    from "market_data"."public"."mart_stock_snapshot"
    group by ticker, date
    having count(*) > 1

)

select *
from validation_errors


