FROM python:3.10-slim

# Install system dependencies
RUN apt-get update && apt-get install -y bc dos2unix && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install Gradio
RUN pip install --no-cache-dir gradio

# Copy files
COPY . .

# Fix line endings and permissions
RUN dos2unix DNAProt.sh && chmod +x DNAProt.sh

# Render uses a dynamic port, so we don't hardcode it in ENV
# But we tell Python to listen on all interfaces
ENV GRADIO_SERVER_NAME="0.0.0.0"

CMD ["python", "app.py"]
