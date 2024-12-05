# NYC Taxi Data Pipeline

## **Files**

1. **`readme.md`**  
   Guide with setup instructions for the data pipeline.

2. **`down_and_up.sh`**  
   Script to download NYC Taxi data and upload it to Google Cloud Storage.

3. **`main.py`**  
   Cloud Function to load data files from Storage into BigQuery.

4. **`requirements.txt`**  
   Python dependencies for the Cloud Function.
---

These are steps required to set up a data pipeline to process NYC Taxi data using Google Cloud.



## **Steps**

### 1. **Create a storage bucket**
Run the following to create a bucket for storing NYC Taxi data

```bash
gsutil mb -l europe-west4 -c STANDARD gs://nyc-taxi-data-seb/
```

### 2. **Create a BigQuery dataset**


```bash
bq --project_id=seb-project-443618 mk --dataset --location=EU seb-project-443618:nyc_taxi
```

### 3. **Grant permissions**
Allow the required service account to publish messages to Pub/Sub:

```bash
gcloud projects add-iam-policy-binding seb-project-443618 \
  --member="serviceAccount:service-660471941189@gs-project-accounts.iam.gserviceaccount.com" \
  --role="roles/pubsub.publisher"
```

### 4. **Deploy a cloud function**

```bash
gcloud functions deploy load_parquet_to_bigquery \
  --runtime python39 \
  --trigger-resource gs://nyc-taxi-data-seb/ \
  --trigger-event google.storage.object.finalize \
  --project seb-project-443618 \
  --region europe-west4 \
  --entry-point load_parquet_to_bigquery \
  --source .
```

### 5. **Make download and upload bash script executable**

```bash
chmod +x down_and_up.sh
```

### 6. **Download and upload files**


```bash
./down_and_up.sh https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_2023-01.parquet nyc-taxi-data-seb
./down_and_up.sh https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_2023-02.parquet nyc-taxi-data-seb
```

### 7. **Query data in BigQuery**
Run the following SQL to count trips from NYC to outside NYC during the second week of 2023.

```sql
WITH nyc_data AS (
  SELECT * 
  FROM `seb-project-443618.nyc_taxi.yellow_tripdata`
  QUALIFY ROW_NUMBER() OVER (PARTITION BY vendorid, tpep_pickup_datetime, tpep_dropoff_datetime) = 1
)
SELECT
  EXTRACT(YEAR FROM tpep_pickup_datetime) AS year,
  EXTRACT(WEEK FROM tpep_pickup_datetime) AS week,
  COUNT(*) AS trips_count_outside_nyc
FROM
  nyc_data
WHERE
  EXTRACT(WEEK FROM tpep_pickup_datetime) = 2
  AND EXTRACT(YEAR FROM tpep_pickup_datetime) = 2023
  AND pulocationid <> 265 -- Inside NYC
  AND dolocationid = 265 -- Outside NYC
GROUP BY year, week;
```
