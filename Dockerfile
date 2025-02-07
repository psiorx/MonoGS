# Use an official NVIDIA CUDA base image with Ubuntu 20.04
FROM nvidia/cuda:11.3.1-cudnn8-runtime-ubuntu20.04

# Set environment variables to avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    wget \
    bzip2 \
    build-essential \
    libopenblas-dev \
    liblapack-dev \
    libatlas-base-dev \
    libopencv-dev \
    && rm -rf /var/lib/apt/lists/*

# Download and install Miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh \
    && bash /tmp/miniconda.sh -b -p /opt/conda \
    && rm /tmp/miniconda.sh

# Add Conda to PATH
ENV PATH="/opt/conda/bin:${PATH}"

# Clone the MonoGS repository recursively (including submodules)
RUN git clone --recursive https://github.com/psiorx/MonoGS.git /workspace/MonoGS
WORKDIR /workspace/MonoGS

# Create the Conda environment from environment.yml
RUN conda env create -f environment.yml

# Activate the Conda environment and make it the default for subsequent commands
RUN echo "source activate $(head -1 environment.yml | cut -d' ' -f2)" > ~/.bashrc
ENV PATH /opt/conda/envs/$(head -1 environment.yml | cut -d' ' -f2)/bin:$PATH

# Install simple-knn from the submodule
WORKDIR /workspace/MonoGS/submodules/simple-knn
RUN pip install .

# Return to the MonoGS root directory
WORKDIR /workspace/MonoGS

# Set the default command to run when the container starts
CMD ["bash"]