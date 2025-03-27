# Use the official Python runtime as the base image
FROM amazonlinux:2023.6.20250303.0@sha256:97bee6ea9b724a96fc90f8a5a8738ec6d8a7c94a6b5a502dfed0461170b98137

# Set the working directory in the container
WORKDIR /app

# Install any necessary dependencies
RUN yum update && \
    yum install -y zip python-pip python3-setuptools && \
    rm -rf /var/lib/apt/lists/*

# Copy the requirements file to the working directory
COPY requirements.txt .

# Install the Python packages listed in requirements.txt
RUN pip install -r requirements.txt -t /opt/python/

# Set the CMD to zip the installed packages into a layer
# change the `requests-layer` to the LAYER_NAME variable as per create_layer.sh file

CMD cd /opt && zip -r9 /app/lambda-layer.zip .