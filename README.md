# AWS Lambda Python Layers with Docker

This project provides a simple and automated way to create Python layers for AWS Lambda functions using Docker.  It leverages a Dockerfile and a bash script to build, run, and manage the layer creation process, ensuring consistent package installations across environments.

## Project Structure

The project consists of the following files:

*   `create_layers.sh`: A bash script that orchestrates the Docker build, container execution, and layer packaging.
*   `Dockerfile`: Defines the Docker image used to build the Python layer.
*   `requirements.txt`:  Lists the Python packages to be included in the layer.
*   `layers/`: (This directory will be created) Where the resulting layer zip file will be stored after the `create_layers.sh` script runs.

## Prerequisites

*   **Docker:**  Ensure Docker is installed and running on your system.
*   **AWS CLI (Optional, for Lambda usage):** Required if you intend to deploy or manage Lambda functions directly using the AWS CLI.
*   **Bash:**  A Bash shell or compatible environment to run the `create_layers.sh` script.

## Usage

1.  **Create `requirements.txt`:**
    Create a `requirements.txt` file in the project root, listing the Python packages your Lambda functions need. For example:
    ```
    requests==2.31.0
    ```

2.  **Run the `create_layers.sh` script:**
    Execute the `create_layers.sh` script from your terminal. This script will:
    *   Build a Docker image based on the `Dockerfile`.
    *   Run a container based on the built image.
    *   Install Python packages from `requirements.txt` inside the container.
    *   Package the installed packages into a zip file stored in the `layers/` directory.
    ```bash
    chmod +x create_layers.sh #Make sure the script is executable
    ./create_layers.sh
    ```

3.  **Using the generated layer (e.g. with the AWS CLI):**
    After successfully running `create_layers.sh`, a zip file will be created e.g. in the `layers/` directory.  You can then use this zip file when creating or updating your Lambda functions using the AWS Management Console or the AWS CLI.  The AWS CLI command to do so, e.g. (replace AWS_REGION):
    ```bash
    aws lambda create-layer \
    --layer-name lambda-layer \
    --zip-file fileb://layers/lambda-layer.zip \
    --compatible-runtimes python3.10 python3.11 python3.12 python3.13 \
    --region AWS_REGION
    ```

    Or if you already have created the layer using the console and need to add updated dependencies:
    ```bash
    aws lambda update-layer-version --layer-name lambda-layer --zip-file fileb://layers/lambda-layer.zip --compatible-runtimes python3.9 python3.10 python3.11 python3.12 --region AWS_REGION
    ```
    Then, when you create or update a Lambda function, associate the layer's ARN with your Lambda function.  The ARN will look something like: `arn:aws:lambda:YOUR_REGION:YOUR_ACCOUNT_ID:layer:lambda-layer:1` (the number at the end is different for each version)

## How it Works

*   **`create_layers.sh`**: This script automates the layer creation.  It builds a Docker image, runs a container, and moves the generated layer. A notable aspect is the cleanup, removing the Docker image and container after the layer creation is complete with the `docker rmi --force lambda-layer`, `docker rm lambda-layer-container` and  `docker stop lambda-layer-container` commands.
*   **`Dockerfile`**:
    *   Specifies a base image (`amazonlinux:2023.6.20250303.0`).
    *   Sets the working directory to `/app`.
    *   Installs necessary system packages ( `zip` and `python-pip` and `python3-setuptools`).
    *   Copies `requirements.txt`.
    *   Installs the Python packages into `/opt/python/`. Python lambda layers look for packages there.
    *   The `CMD` zips the contents of `/opt` (where the python packages are now) into a zip file named as the `LAYER_NAME` with .zip extension in the `/app` directory.  This is the layer that will be used inside our lambda function.

## Customization

*   **`requirements.txt`**: Add, remove, or update Python packages in this file to match your Lambda function's dependencies.
*   **`LAYER_NAME`**: Change the value of `LAYER_NAME` variable in the `create_layers.sh` script to customize the name of the layer zip file.
*    **`Dockerfile`**:  The `Dockerfile` can be customized to accommodate the needs you have in your lambda functions (e.g. you can provide additional OS packages)

##  Troubleshooting

*   **Docker Issues:** Ensure Docker is running correctly. Verify your user has permissions to access Docker.
*   **Package Installation Errors:** Check for any errors during the `pip install` step within the Docker container. Review the `requirements.txt` for correct package names and versions. Check the Docker logs.
*   **Missing Dependencies at Runtime:** If your Lambda function fails to import packages after deploying the layer, double-check that the packages are correctly listed in `requirements.txt` and installed in the layer.  Verify the python runtime version is correct inside AWS lambda functions settings.

##  Future Improvements

*   Add support for configuring layer compatibilities (e.g., Python versions).
*   Integrate with automated CI/CD pipelines (e.g., GitHub Actions, GitLab CI).
*   More robust error handling in the `create_layers.sh` script.
