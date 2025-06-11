"""
# NetCDF to Parquet Conversion Pipeline

This script is used to convert NetCDF files (stored on Amazon S3) into Apache Parquet format using PySpark.

### Features:
- Extracts and flattens geospatial data (latitudes, longitudes, and times) from NetCDF files.
- Converts geographical coordinates into H3 geospatial indexes for better geospatial analysis.
- Allows for timestamp-based filtering of the dataset, and customizable H3 resolution.
- Outputs a Parquet file, a highly efficient columnar format, to Amazon S3.

### Usage:
The script is designed to be used as part of a data pipeline on AWS Glue. It supports the following command-line arguments:

- `--file_name`: The name of the NetCDF file (e.g. `precipitation_amount_1hour_Accumulation.nc`).
- `--date`: The timestamp of the data as `YYYY_MM` format.
- `--timestamp_filter`: Optional filter for a start and end date (e.g. `2022-01-01 2022-01-31`).
- `--resolution`: The H3 geospatial resolution (default: 10).
- `--output_path`: The path where the converted Parquet file should be saved.
"""

import logging
import coloredlogs
from pyspark.sql import SparkSession
from pyspark.sql.functions import udf
from pyspark.sql.types import LongType
import xarray as xr
import h3.api.numpy_int as h3
import numpy as np

# Set up logging with colored output for better visibility during execution
logger = logging.getLogger(__name__)

# Colored logging configuration for different log levels
coloredlogs.install(
    fmt="%(levelname)s:%(message)s",
    level="INFO",
    level_styles={
        "info": {"color": "white"},
        "error": {"color": "red"},
        "warning": {"color": "yellow"},
    },
)

BUCKET = "era5-pds"

# Initialize a PySpark session with custom configurations
def get_spark_session():
    return (
        SparkSession.builder.appName("NetCDF-to-Parquet")
        .config("spark.sql.debug.maxToStringFields", 1000)  # Ensures large strings can be displayed fully
        .getOrCreate()
    )

# Function to convert lat/lon coordinates into H3 index
def geo_to_h3(lat, lon, resolution):
    # Convert the given latitude and longitude into an H3 index
    return h3.geo_to_h3(lat, lon, resolution)

# Register H3 conversion function as a User Defined Function (UDF) in Spark
udf_h3 = udf(geo_to_h3, LongType())

# Function to read the NetCDF file from S3 using xarray
def read_obj_from_s3(spark, s3path: str):
    # Load NetCDF dataset using xarray with h5netcdf engine
    ds = xr.open_dataset(s3path, engine="h5netcdf")
    return ds

# Main function to convert the NetCDF file to Parquet, including spatial H3 indexing
def convert_netCDF_to_parquet(spark, file_path, output_path: str, timestamp_filter=None, resolution=10):
    """Convert the downloaded NetCDF file to Parquet using PySpark"""

    # Read the NetCDF file
    logger.info("Reading climate file from %s", BUCKET)
    ds = read_obj_from_s3(spark, file_path)
    
    # Extract the variable name and coordinates from the NetCDF dataset
    variable_name = list(ds.keys())[1]
    list_coords = list(ds.coords)

    # Apply optional timestamp filtering
    if None not in timestamp_filter:
        logger.info("Filtering datestampe between %s & %s", timestamp_filter[0], timestamp_filter[1])
        filter = {list_coords[2]: slice(timestamp_filter[0], timestamp_filter[1])}
        ds = ds.sel(filter)

    # Extract latitude, longitude, and time coordinates along with the dataset values
    logger.info("Extracting coordinates and values")
    longitudes = ds[list_coords[0]].values
    latitudes = ds[list_coords[1]].values
    times = ds[list_coords[2]].values
    ds_values = ds[variable_name].values

    # Flatten the 3D grids of latitude, longitude, and time into 1D arrays
    times_grid, latitudes_grid, longitudes_grid = [
        x.flatten() for x in np.meshgrid(times, latitudes, longitudes, indexing="ij")
    ]
    coordinates = np.vstack((latitudes_grid, longitudes_grid)).T

    # Create a Spark DataFrame from the extracted data
    df = spark.createDataFrame(
        zip(latitudes_grid, longitudes_grid, times_grid, ds_values.flatten()),
        schema=["latitude", "longitude", "time", f"{variable_name}"],
    )

    # Apply H3 geospatial indexing to the coordinates using the UDF
    logger.info("Applying Spatial Index")
    df = df.withColumn("h3Index", udf_h3(df["latitude"], df["longitude"], resolution))

    # Write the resulting DataFrame to Parquet format
    logger.info("Writing to Parquet at %s", output_path)
    df.write.parquet(output_path)

# Main function to handle command-line arguments and run the conversion
def main():
    parser = argparse.ArgumentParser(
        description="Transform the data into the Apache Parquet datasource"
    )

    # Argument for specifying the NetCDF file name (required)
    parser.add_argument(
        "--file_name",
        help="The file name e.g. precipitation_amount_1hour_Accumulation.nc",
        type=str,
        required=True,
    )

    # Argument for specifying the date of the data in YYYY_MM format (required)
    parser.add_argument(
        "--date", help="Timestamp of data as YYYY_MM", type=str, required=True
    )

    # Argument for specifying a timestamp filter (optional)
    parser.add_argument(
        "--timestamp_filter",
        nargs=2,
        metavar=("StartDate", "EndDate"),
        help="Filtering by timestamp.",
        type=str,
        default=(None, None),
    )

    # Argument for specifying H3 resolution (default is 10)
    parser.add_argument(
        "--resolution",
        help="Hierarchical geospatial index of your choice.",
        type=int,
        default=10,
        required=False,
    )

    # Argument for specifying the output path where Parquet files will be saved
    parser.add_argument(
        "--output_path", help="Path to save the parquet file.", type=str, required=True
    )

    # Parse the command-line arguments
    args = parser.parse_args()
    FILE = args.file_name
    StartDate, EndDate = args.timestamp_filter
    RESOLUTION = args.resolution
    OUTPATH = args.output_path
    DATE = args.date

    # Initialize Spark session
    spark = get_spark_session()

    # Construct the S3 path to the input file based on the date and file name
    KEY = f"{DATE.split('-')[0]}/{DATE.split('-')[1]}/data/{FILE}"
    FILE_PATH = f"s3://{BUCKET}/{KEY}"

    # Call the function to convert NetCDF to Parquet
    convert_netCDF_to_parquet(spark, FILE_PATH, OUTPATH, (StartDate, EndDate), RESOLUTION)

    logger.info("File was saved to %s", OUTPATH)

if __name__ == "__main__":
    main()
