bash
#!/bin/bash

# Start Ollama service in the background
echo "Starting Ollama service..."
ollama serve &

# Give Ollama a moment to start up
sleep 5

# Download the specific Qwen model
echo "Downloading Qwen2.5-1m:14b model (this might take a while)..."
ollama pull qwen2.5-1m:14b

# Start Open WebUI
# Use Docker to run Open WebUI for easier setup and updates
# -d: run in detached mode (background)
# -p 8080:8080: map container port 8080 to host port 8080 (which RunPod will expose)
# --add-host=host.docker.internal:host-gateway: allows Open WebUI to connect to Ollama running on the host
# -v open-webui:/app/backend/data: creates a named Docker volume for Open WebUI data (persists across container restarts)
# --name open-webui: names the container
# --restart always: restarts the container if it stops
echo "Starting Open WebUI..."
docker run -d -p 8080:8080 --add-host=host.docker.internal:host-gateway -v open-webui:/app/backend/data --name open-webui --restart always ghcr.io/open-webui/open-webui:main

echo "Ollama and Open WebUI are starting. Check RunPod's HTTP services for Open WebUI URL."

# Keep the script running in foreground to prevent the Docker container from exiting
tail -f /dev/null