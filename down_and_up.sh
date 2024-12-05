#!/bin/bash


HTTP_URL=$1  # The HTTP URL to download the file from
BUCKET_NAME=$2  # The name of the GCS bucket
FILE_NAME=$(basename "$HTTP_URL")

if ! command -v gsutil &> /dev/null
then
    echo "Error: gsutil is not installed."
    exit 1
fi


echo "Downloading file from $HTTP_URL..."
curl -O "$HTTP_URL"


if [ $? -ne 0 ]; then
    echo "Error: Failed to download file from $HTTP_URL"
    exit 1
fi

echo "File downloaded: $FILE_NAME"


echo "Uploading $FILE_NAME to bucket gs://$BUCKET_NAME..."
gsutil cp "$FILE_NAME" "gs://$BUCKET_NAME/"


if [ $? -ne 0 ]; then
    echo "Error: Failed to upload $FILE_NAME to gs://$BUCKET_NAME/"
    exit 1
fi

echo "File uploaded successfully to gs://$BUCKET_NAME/$FILE_NAME"


rm -f "$FILE_NAME"
echo "Local file cleaned up."
