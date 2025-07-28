dockerfile
# Use a base image with CUDA 12.1 and PyTorch already set up for NVIDIA GPUs
FROM pytorch/pytorch:2.4.0-cuda12.1-cudnn9-devel

# Set environment variables to prevent interactive prompts during apt-get
ENV DEBIAN_FRONTEND=noninteractive

# Install basic tools and dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git \
        curl \
        sudo \
        unzip \
        # Clean up apt caches to reduce image size
        && rm -rf /var/lib/apt/lists/*

# Install Ollama
# The 'sh' script needs sudo, so we run it from root.
RUN curl -fsSL https://ollama.com/install.sh | sh

# Set Ollama to listen on all network interfaces inside the container
# This is crucial for Open WebUI to connect to Ollama.
ENV OLLAMA_HOST=0.0.0.0

# Install Python dependencies for Open WebUI and other potential tools
# We are installing vLLM here too, even if Ollama is primary. Good for future options.
# --no-cache-dir helps keep the image size down
RUN pip install --no-cache-dir \
    transformers \
    accelerate \
    bitsandbytes \
    vllm \
    # Additional libraries for WhatsApp parsing and general data handling
    whatstk \
    pandas \
    matplotlib \
    seaborn \
    # General utilities for web interactions if needed
    requests \
    # Required for Open WebUI from its requirements.txt (simplified for Dockerfile)
    # Note: Open WebUI typically runs its own setup, but these are common
    uvicorn \
    fastapi \
    python-multipart \
    asyncio \
    jinja2 \
    # Add any other specific dependencies for Open WebUI if manually integrating
    # For a full Open WebUI setup, cloning their repo and running 'pip install -r requirements.txt' is more robust
    # But for this simple docker, we assume the Docker run command below will handle Open WebUI

# Create a non-root user (good security practice)
RUN useradd -m appuser
USER appuser
WORKDIR /home/appuser/workspace

# Copy the startup script (we'll create this next)
COPY start_server.sh /usr/local/bin/start_server.sh
RUN chmod +x /usr/local/bin/start_server.sh

# Expose ports for Ollama and Open WebUI
# These are internal container ports. RunPod handles mapping them to external URLs.
EXPOSE 11434
EXPOSE 8080

# Define the command to run when the container starts
# This will execute our custom startup script
CMD ["/usr/local/bin/start_server.sh"]
