import requests
import psycopg2
from datetime import date
import os
import time

def get_api_key(alt_api_key = False):
    file_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "AlphaVantage API KEY.txt")
    f = open(file_path)
    if alt_api_key:
        file_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "AlphaVantage API KEY2.txt")
        f = open(file_path)
    return f.readline()

def connect_database(isLocal):
    # To connect to a database:
    # conn = psycopg2.connect(dbname, user_name, password, host, port)
    # As this is outside Docker, host is "localhost" and port is the host port which is 5433.
    # we assigned 5433 in docker-compose.yaml
    if isLocal:
        conn = psycopg2.connect(dbname="market_data", user="market_data", password="market_data", host="localhost", port=5433)
    else:
        conn = psycopg2.connect(dbname="market_data", user="market_data", password="market_data", host="postgres_market_data", port=5432)
    return conn

def reset_database():
    conn = connect_database(False)
    cur = conn.cursor()

    # DELETING THE TABLE
    cur.execute("""
    DROP TABLE IF EXISTS dividend
    """)

    # DELETING THE TABLE
    cur.execute("""
    DROP TABLE IF EXISTS time_series_weekly
    """)

    conn.commit()

    create_tables()

    
def create_tables():
    conn = connect_database(False)
    cur = conn.cursor()

    # CREATING THE TABLE
    cur.execute("""
    CREATE TABLE IF NOT EXISTS dividend (
                ticker VARCHAR NOT NULL, 
                ex_dividend_date DATE, 
                payment_date DATE, 
                amount FLOAT NOT NULL, 
                PRIMARY KEY (ticker, ex_dividend_date)
                )
    """)

    # CREATING THE TABLE
    cur.execute("""
    CREATE TABLE IF NOT EXISTS time_series_weekly (
                ticker VARCHAR NOT NULL, 
                date DATE NOT NULL, 
                open FLOAT, 
                high FLOAT,
                low FLOAT, 
                close FLOAT,
                volume FLOAT,
                PRIMARY KEY (ticker, date)
                )
    """)

    conn.commit()

def get_market_data(tickers:list, alt_api_key = False):

    api_key = get_api_key(alt_api_key)

    div_data = {}
    weekly_data = {}
    for ticker in tickers:
        url = "https://www.alphavantage.co/query?function=DIVIDENDS&symbol={name}&apikey={key}".format(name=ticker, key = api_key)
        r = requests.get(url)
        data = r.json() 

        if 'Information' in data and 'data' not in data:
            if alt_api_key == False:
                get_market_data(tickers, True)
            else:
                raise Exception("API key failed: " + str(data))

        time.sleep(2)

        # the url gives us a string of 'None' for no data which we need to convert into null
        for row in data["data"]:
            for key in row:
                if row[key] == "None":
                    row[key] = None

        div_data[ticker] = data["data"]

        url = "https://www.alphavantage.co/query?function=TIME_SERIES_WEEKLY&symbol={name}&apikey={key}".format(name=ticker, key = api_key)
        r = requests.get(url)
        data = r.json() 

        if 'Weekly Time Series' not in data:
            if alt_api_key == False:
                get_market_data(tickers, True)
            else:
                raise Exception("API key failed: " + str(data))

        time.sleep(2)

        weekly_data[ticker] = data['Weekly Time Series']

    conn = connect_database(False)
    cur = conn.cursor()

    create_tables()

    # cur.execute("""
    # SELECT * FROM dividend
    # """)
    # rows = cur.fetchall()
    # for row in rows:
    #     print(row)

    # cur.execute("""
    # SELECT * FROM time_series_weekly
    # """)
    # rows = cur.fetchall()
    # for row in rows:
    #     print(row)

    # grab the most recent date
    recent_div_dates = {}
    recent_weekly_dates = {}
    for ticker in tickers:
        cur.execute("""
        SELECT MAX(ex_dividend_date) 
        FROM dividend 
        WHERE ticker = %s
        """,(ticker,))
        recent_div_dates[ticker] = cur.fetchone()

        cur.execute("""
        SELECT MAX(date) 
        FROM time_series_weekly 
        WHERE ticker = %s
        """,(ticker,))
        recent_weekly_dates[ticker] = cur.fetchone()

        if recent_div_dates[ticker] is None or recent_div_dates[ticker] == (None,):
            recent_div_dates[ticker] = (date(1, 1, 1),) # if no date, set to 0001-01-01
        
        if recent_weekly_dates[ticker] is None or recent_weekly_dates[ticker] == (None,):
            recent_weekly_dates[ticker] = (date(1, 1, 1),) # if no date, set to 0001-01-01

        # convert to datetime so we can compare
        recent_div_date = recent_div_dates[ticker][0]
        recent_weekly_date = recent_weekly_dates[ticker][0]

        print ("Dividend most recent date for %s: %s", (ticker, recent_div_date))
        print ("Weekly data most recent date for %s: %s", (ticker, recent_weekly_date))

        div_data_to_add = []

        # record which rows to add
        for data in div_data[ticker]:
            ex_dividend_date_str = data['ex_dividend_date'].split("-")
            # need to convert data from api for comparison
            ex_dividend_date = date(int(ex_dividend_date_str[0]), int(ex_dividend_date_str[1]), int(ex_dividend_date_str[2]))
            if ex_dividend_date > recent_div_date:
                div_data_to_add.append(data)
        
        for data in div_data_to_add:
            cur.execute("""
            INSERT INTO dividend VALUES (%s, %s, %s, %s)
            """, (ticker, data['ex_dividend_date'], data['payment_date'], data['amount']))

        # record which rows to add
        for _date, data in weekly_data[ticker].items():
            weekly_date_str = _date.split("-")
            # need to convert data from api for comparison
            weekly_date = date(int(weekly_date_str[0]), int(weekly_date_str[1]), int(weekly_date_str[2]))
            if weekly_date > recent_weekly_date:
                cur.execute("""
                INSERT INTO time_series_weekly VALUES (%s, %s, %s, %s, %s, %s, %s)
                """, (ticker, _date, data['1. open'], data['2. high'], data['3. low'], data['4. close'], data['5. volume']))


    conn.commit()
    conn.close()

tickers = ["AAPL", "MSFT"]
if __name__ == "__main__":
    get_market_data(tickers)