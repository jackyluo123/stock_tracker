dbt has its own DAGs.
Unlike Airflow, we don't need to create a specific file to tell dbt the order.
We use
{{ ref('model_name') }}
and dbt will figure out the downstream/upstream
We can also use 
{{ source('raw','tableName') }}

For data tests in the schema.yml
There's:
not_null,
unique,
accepted_values:
  values: [,]
relationships:
  to: ref('tableName') or some way to reference a table
  field: columnName 
for above, relationships enforces that the current model has values in the reference table
field also refers to a column in the reference table

For sql files, we can set the materialization for efficiency at the top of the file
{{ config(materialized='incremental') }}
Can be view, table, incremental