import datetime

from airflow.sdk import DAG
from airflow.providers.standard.operators.bash import BashOperator
from airflow.operators.trigger_dagrun import TriggerDagRunOperator

dbt_profiles_dir = "/opt/dbt/dbt_databases"

# @daily is a cron expression equivalent from linux. This is a standard for defining schedules
# we could use the literal cron expression "0 0 * * *" with no @ sign, but we cannot use "daily"

# INGESTION
with DAG(
    dag_id="market_data_ingestion",
    start_date=datetime.datetime(2026, 4, 20),
    schedule="@daily",
    catchup=False,
):
    ingest = BashOperator(task_id="load_market_data", bash_command="python /opt/airflow/scripts/update_market_data.py")
    trigger_cleanup = TriggerDagRunOperator(task_id = "trigger_cleanup", trigger_dag_id = "cleanup_backups")

    ingest >> trigger_cleanup
    

# CLEANUP BACKUPS FROM BAD RUNS
with DAG(
    dag_id="cleanup_backups",
    start_date=datetime.datetime(2026, 4, 20),
    schedule=None,
    catchup=False,
):
    cleanup = BashOperator(task_id="cleanup_dbt_backups", bash_command="python /opt/airflow/scripts/cleanup_dbt_backups.py")
    trigger_deps = TriggerDagRunOperator(task_id = "trigger_deps", trigger_dag_id = "download_deps")
    
    cleanup >> trigger_deps

# DOWNLOAD DEPENDENCIES
with DAG(
    dag_id="download_deps",
    start_date=datetime.datetime(2026, 4, 20),
    schedule=None,
    catchup=False,
):
    download_deps = BashOperator(task_id="download_dbt_deps", bash_command="cd /opt/dbt/dbt_databases && dbt clean && dbt deps --profiles-dir {profiles_dir}".format(profiles_dir = dbt_profiles_dir))
    trigger_transforms = TriggerDagRunOperator(task_id = "trigger_transforms", trigger_dag_id = "market_data_transform")
    
    download_deps >> trigger_transforms

# TRANSFORMATION
with DAG(
    dag_id="market_data_transform",
    start_date=datetime.datetime(2026, 4, 20),
    schedule=None,
    catchup=False,
):
    transform_market_data = BashOperator(task_id="transform_market_data", bash_command="cd /opt/dbt/dbt_databases && dbt run --profiles-dir {profiles_dir}".format(profiles_dir = dbt_profiles_dir))
    trigger_tests = TriggerDagRunOperator(task_id = "trigger_tests", trigger_dag_id = "market_data_test")

    transform_market_data >> trigger_tests


# TESTS
with DAG(
    dag_id="market_data_test",
    start_date=datetime.datetime(2026, 4, 20),
    schedule=None,
    catchup=False,
):
    test_market_data = BashOperator(task_id="test_market_data", bash_command="cd /opt/dbt/dbt_databases && dbt run --profiles-dir {profiles_dir}".format(profiles_dir = dbt_profiles_dir))
    trigger_docs = TriggerDagRunOperator(task_id = "trigger_docs", trigger_dag_id = "market_data_generate_docs")

    test_market_data >> trigger_docs

# GENERATE DOCS
with DAG(
    dag_id="market_data_generate_docs",
    start_date=datetime.datetime(2026, 4, 20),
    schedule=None,
    catchup=False,
):
    generate_docs = BashOperator(task_id="market_data_docs", bash_command="cd /opt/dbt/dbt_databases && dbt docs generate --profiles-dir {profiles_dir}".format(profiles_dir = dbt_profiles_dir))
    