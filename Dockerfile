# Use a more recent L4T base image with newer Python
FROM nvcr.io/nvidia/l4t-base:r36.2.0

WORKDIR /app

# Install Python 3.10+ and development tools
RUN apt-get update && apt-get install -y \
    python3.10 \
    python3.10-dev \
    python3-pip \
    curl \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Create symlinks for python3 to point to python3.10
RUN ln -sf /usr/bin/python3.10 /usr/bin/python3
RUN ln -sf /usr/bin/python3.10 /usr/bin/python

# Upgrade pip
RUN python3 -m pip install --upgrade pip

# Install your requirements
COPY requirements.txt .
RUN pip install -r requirements.txt

# Install ONNX Runtime GPU for Jetson
RUN pip install onnxruntime-gpu --extra-index-url https://developer.download.nvidia.com/compute/redist

# Download required model files
RUN mkdir -p /app/src && \
    curl -L "https://github.com/thewh1teagle/kokoro-onnx/releases/download/model-files/voices.json" -o /app/src/voices.json && \
    curl -L "https://github.com/thewh1teagle/kokoro-onnx/releases/download/model-files/kokoro-v0_19.onnx" -o /app/src/kokoro-v0_19.onnx

# Copy source code
COPY src/ /app/src/

# Set environment variables for CUDA
ENV PYTHONPATH=/app
ENV CUDA_VISIBLE_DEVICES=0
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility

WORKDIR /app/src
CMD ["python", "main.py"]
