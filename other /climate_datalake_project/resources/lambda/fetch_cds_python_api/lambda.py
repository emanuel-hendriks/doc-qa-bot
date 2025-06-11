import json
import boto3
import cdsapi
import os

# Initialize the S3 client
s3_client = boto3.client('s3')

def lambda_handler(event, context):
    # Initialize CDS API client
    client = cdsapi.Client()

    # Define the dataset and request parameters
    dataset = "reanalysis-era5-single-levels"
    request = {
        "product_type": ["reanalysis"],
        "variable": [
            "10m_u_component_of_wind",
            "10m_v_component_of_wind",
            "2m_dewpoint_temperature",
            "2m_temperature",
            "mean_sea_level_pressure",
            "mean_wave_direction",
            "mean_wave_period",
            "sea_surface_temperature",
            "significant_height_of_combined_wind_waves_and_swell",
            "surface_pressure",
            "total_precipitation"
        ],
        "year": ["2020", "2021", "2022", "2023"],  # Adjust year ranges as necessary
        "month": ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"],
        "day": ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31"],
        "time": ["00:00", "06:00", "12:00", "18:00"],
        "format": "netcdf"
    }

    try:
        # Define the local file path (Lambda /tmp is writable, but ephemeral)
        local_file = '/tmp/era5_data.nc'

        # Retrieve and download the data using CDS API
        client.retrieve(dataset, request).download(local_file)
        print(f"Data successfully downloaded to {local_file}")

        # Define the S3 bucket and key
        s3_bucket = os.environ['S3_BUCKET']  # You should pass this as an environment variable
        s3_key = 'era5_data/era5_data.nc'

        # Upload the file to the S3 bucket
        s3_client.upload_file(local_file, s3_bucket, s3_key)
        print(f"Data successfully uploaded to S3: {s3_bucket}/{s3_key}")

        # Return success response
        return {
            'statusCode': 200,
            'body': json.dumps(f'Data successfully uploaded to {s3_bucket}/{s3_key}')
        }
    
    except Exception as e:
        print(f"Error occurred: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps(f"Error: {str(e)}")
        }
