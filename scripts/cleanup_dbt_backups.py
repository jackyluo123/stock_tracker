from update_market_data import connect_database

def clean_backups():
    conn = connect_database(False)
    cur = conn.cursor()
    
    # grab all table names that have "backup" in them
    cur.execute("""
    SELECT table_schema, table_name
    FROM information_schema.tables
    WHERE table_name LIKE '%\_\_dbt\_backup' ESCAPE '\' AND table_type = 'BASE TABLE'
    """)

    rows = cur.fetchall()

    for row in rows:
        cur.execute("""
        DROP TABLE IF EXISTS {schema}.{table_name}
        """.format(schema = row[0], table_name = row[1]))

    conn.commit()
    conn.close()