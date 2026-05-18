FROM python:3.10-slim

# Install system dependencies (bc for bash math logic, dos2unix for line endings)
RUN apt-get update && apt-get install -y bc dos2unix && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# CRITICAL FIX: Tell the Docker container to install BOTH libraries
RUN pip install --no-cache-dir gradio reportlab

# Copy all repository files into the container
COPY . .

# Sanitize line endings and make the script executable
RUN dos2unix DNAProt.sh && chmod +x DNAProt.sh

# Configure the network ports for Render
ENV GRADIO_SERVER_NAME="0.0.0.0"

CMD ["python", "app.py"]
