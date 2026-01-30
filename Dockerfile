# Use an official Python runtime as a parent image
FROM python:3.12-slim

# Prevents Python from writing .pyc files and buffers
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Install system dependencies required to build some scientific packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential gcc g++ gfortran \
    libopenblas-dev liblapack-dev libatlas-base-dev \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy requirements and install dependencies (caches layers)
COPY Phishing-Website-Detection-System/requirements.txt ./requirements.txt
RUN python -m pip install --upgrade pip setuptools wheel && \
    pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code
COPY Phishing-Website-Detection-System/ .

# Expose the port Flask uses
EXPOSE 5000

# Environment variables
ENV FLASK_APP=app.py \
    FLASK_ENV=production \
    PORT=5000

# Create a non-root user and switch to it
RUN useradd --create-home appuser && chown -R appuser /app
USER appuser

# Start the app: prefer gunicorn if available, otherwise fallback to Python's built-in runner
CMD ["/bin/sh", "-c", "if command -v gunicorn >/dev/null 2>&1; then gunicorn --bind 0.0.0.0:$PORT app:app; else python app.py; fi"]
