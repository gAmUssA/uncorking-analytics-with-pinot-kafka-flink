#!/usr/bin/env python

import json
import logging
import os
import random
import time

import pandas as pd
import pulsar

class Generator:
    def next(self) -> (str, object):
        pass

class RatingGenerator(Generator):
    def __init__(self):
        path = os.getenv('DATA')
        if path is None:
            raise Exception("need to set DATA environment variable with path to movies.json file")
        self.df = pd.read_json(path, lines=True)

    def next(self):
        key = random.randint(self.df['movieId'].min(), self.df['movieId'].max())
        data = json.dumps({
            "movieId": key,
            "rating": round(random.uniform(0.0, 10.0), 2),
            "ratingTime": round(time.time() * 1000)
        })
        return str(key), data.encode('utf-8')

def send(client, topic, gen: Generator, limit: int = 100000):
    producer = client.create_producer(topic)

    for i in range(limit):
        key, data = gen.next()
        producer.send(data, partition_key=key)
        print(f'Message sent: key={key}')

    producer.flush()

if __name__ == "__main__":
    service_url = os.getenv('PULSAR_SERVICE_URL', 'pulsar://localhost:6650')
    topic = os.getenv('TOPIC', 'persistent://public/default/ratings')
    limit = int(os.getenv('LIMIT', 100000))

    logging.basicConfig(level=logging.INFO)

    client = pulsar.Client(service_url)
    try:
        gen = RatingGenerator()
        send(client, topic=topic, gen=gen, limit=limit)
    finally:
        client.close()