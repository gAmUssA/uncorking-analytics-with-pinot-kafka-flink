# Use Python 3.9 base image
FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first to leverage Docker cache
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY producer.py .
#COPY data/ ./data/

# Environment variables with defaults
ENV PULSAR_URL=pulsar://pulsar:6650
ENV MOVIE_TOPIC=persistent://public/default/movies
ENV RATING_TOPIC=persistent://public/default/ratings
ENV LIMIT=100000
ENV DATA=/app/data/movies.jsonl

# Run the application
CMD ["python", "producer.py"]