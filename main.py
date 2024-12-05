from google.cloud import bigquery

def load_parquet_to_bigquery(data, context):

    bucket_name = data['bucket']
    file_name = data['name']
   
    project_id = "seb-project-443618"
    dataset_id = "nyc_taxi"
    table_id = "yellow_tripdata"
    table_ref = f"{project_id}.{dataset_id}.{table_id}"

    client = bigquery.Client()
    uri = f"gs://{bucket_name}/{file_name}"
    

    job_config = bigquery.LoadJobConfig(
        source_format=bigquery.SourceFormat.PARQUET,
        write_disposition=bigquery.WriteDisposition.WRITE_APPEND
    )

    load_job = client.load_table_from_uri(
        uri, table_ref, job_config=job_config
    )
    
    load_job.result()
    print(f"File {file_name} successfully loaded into {table_ref}.")
