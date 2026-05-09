-- if we did not clean the data in Python, it would have been done here
SELECT * 
FROM {{ source('market_data','dividend') }}