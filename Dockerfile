FROM apache/airflow:3.2.0

USER airflow

RUN pip install dbt-postgres
