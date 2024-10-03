FROM python:3.12.5-slim

# Install any needed system dependencies
RUN apt-get update -y && \
    apt-get install -y build-essential libssl-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /code

# Copy the requirements file and the producer script
COPY requirements.txt requirements.txt
COPY producer.py producer.py

# Upgrade pip and install Python dependencies
RUN pip install --upgrade pip && \
    python3 --version && \
    pip install -r requirements.txt

# Run the producer script
CMD ["python", "producer.py"]