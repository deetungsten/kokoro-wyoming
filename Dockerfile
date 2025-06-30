# Use NVIDIA's L4T (Linux for Tegra) base image with CUDA support
# This is specifically designed for Jetson devices
FROM nvcr.io/nvidia/l4t-pytorch:r35.2.1-pth2.0-py3

# Alternative base images you can use:
# FROM nvcr.io/nvidia/l4t-base:r35.4.1  # Minimal L4T base
# FROM nvcr.io/nvidia/l4t-python:r35.4.1  # L4T with Python

WORKDIR /app

# Update package lists and install curl
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install Python packages
COPY requirements.txt .
RUN pip install -r requirements.txt

# Install ONNX Runtime GPU (for Jetson/ARM64)
# This is the GPU-accelerated version for Jetson devices
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
