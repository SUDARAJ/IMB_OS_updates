# Use the official Python 3.9 slim image as the base image
FROM python:3.9-slim

# Copy the Python script to the root directory of the container


# Install the necessary Python packages
RUN pip install requests
RUN pip install boto3
RUN pip install pytz

# Ensure the script is executable


# Expose the required ports
EXPOSE 80
EXPOSE 443
EXPOSE 993
EXPOSE 465

# Define the command to run the script
