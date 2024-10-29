#!/bin/local/python

import json
import logging
import os
import random
import time

import numpy as np
import pandas as pd
import pulsar


class Generator:
    def next(self) -> (str, object):
        pass


class MovieDataGenerator(Generator):
    def __init__(self, df):
        self.df = df

    def next(self):
        for _, row in self.df.iterrows():
            key = str(row['movieId'])
            data = json.dumps(row.to_dict())
            yield key, data.encode('utf-8')


class RatingGenerator(Generator):
    def __init__(self, df):
        self.df = df

    def next(self):
        while True:
            key = random.randint(self.df['movieId'].min(), self.df['movieId'].max())
            rating = np.random.normal(8, 1.5)
            rating = max(0, min(10, rating))
            data = json.dumps({
                "movieId": key,
                "rating": round(rating, 2),
                "ratingTime": round(time.time() * 1000)
            })
            yield str(key), data.encode('utf-8')


def create_producer(client: pulsar.Client, topic: str) -> pulsar.Producer:
    return client.create_producer(
        topic,
        block_if_queue_full=True,
        batching_enabled=True,
        batching_max_messages=1000,
        batching_max_publish_delay_ms=10
    )


def message_callback(result, message):
    """Callback function for message delivery"""
    if result == pulsar.Result.Ok:
        logging.info(f'Message published successfully')
    else:
        logging.error(f'Failed to publish message: {result}')


def send(client: pulsar.Client, topic: str, gen: Generator, limit: int = 100000):
    producer = create_producer(client, topic)
    count = 0

    try:
        for key, data in gen.next():
            producer.send_async(
                data,
                message_callback,
                partition_key=key
            )

            count += 1
            if count % 1000 == 0:
                producer.flush()
                logging.info(f"Sent {count} messages to topic {topic}")
            if count >= limit:
                break

    except Exception as e:
        logging.error(f"Error sending messages: {e}")
        raise e

    finally:
        try:
            producer.flush()
            producer.close()
        except Exception as e:
            logging.error(f"Error closing producer: {e}")


if __name__ == "__main__":
    # Configure logging
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(levelname)s - %(message)s'
    )

    # Get configuration from environment
    service_url = os.getenv('PULSAR_URL', 'pulsar://pulsar:6650')
    movie_topic = os.getenv('MOVIE_TOPIC', 'persistent://public/default/movies')
    rating_topic = os.getenv('RATING_TOPIC', 'persistent://public/default/ratings')
    lmt = int(os.getenv('LIMIT', 100000))
    path = os.getenv('DATA')

    if path is None:
        raise Exception("Need to specify movies.jsonl file path")

    # Create client instance
    client = pulsar.Client(service_url)

    try:
        # Load data
        logging.info(f"Loading data from {path}")
        df = pd.read_json(path, lines=True)

        movie_gen = MovieDataGenerator(df)
        rating_gen = RatingGenerator(df)

        # Send movie data
        logging.info("Starting to send movie data...")
        send(client, topic=movie_topic, gen=movie_gen, limit=len(df))
        logging.info("Finished sending movie data")

        # Send rating data
        logging.info("Starting to send rating data...")
        send(client, topic=rating_topic, gen=rating_gen, limit=lmt)
        logging.info("Finished sending rating data")

    except Exception as e:
        logging.error(f"Error in main: {e}")
        raise e

    finally:
        try:
            client.close()
        except Exception as e:
            logging.error(f"Error closing client: {e}")
