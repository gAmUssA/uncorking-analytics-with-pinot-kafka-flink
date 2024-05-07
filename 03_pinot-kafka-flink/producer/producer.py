#!/bin/local/python

import json
import logging
import os
import random
import time

import numpy as np
import pandas as pd
from confluent_kafka import Producer


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
            # Generate a normally distributed rating around 8 with standard deviation 1.5
            # Clip the ratings to ensure they stay within 0 to 10
            rating = np.random.normal(8, 1.5)
            rating = max(0, min(10, rating))  # Ensuring rating is between 0 and 10
            data = json.dumps({
                "movieId": key,
                "rating": round(rating, 2),
                "ratingTime": round(time.time() * 1000)
            })
            yield str(key).encode('utf-8'), data.encode('utf-8')


def delivery_report(err, msg):
    """ Called once for each message produced to indicate a delivery result.
        Triggered by poll() or flush(). """
    if err is not None:
        print('Message delivery failed: {}'.format(err))
    else:
        print('Message delivered to {} [{}]'.format(msg.topic(), msg.partition()))


def send(p, topic, gen: Generator, limit: int = 100000):
    p.poll(0)
    count = 0

    for key, data in gen.next():
        while True:
            try:
                p.produce(
                    key=key,
                    topic=topic,
                    value=data,
                    on_delivery=delivery_report)
                break  # Break the loop if produce succeeds
            except BufferError:
                print('Local producer queue is full ({} messages awaiting delivery): trying again...'.format(len(p)))
                p.poll(1000)  # Wait a bit for the producer to clear up buffer space
        count += 1
        if count % 100 == 0:  # Adjust the frequency of poll() based on your application's requirement
            p.poll(0)  # Serve delivery callback queue
        if count >= limit:
            break

    # Wait for any outstanding messages to be delivered and delivery report
    # callbacks to be triggered.
    p.flush()


if __name__ == "__main__":
    bootstrap = os.getenv('BOOTSTRAPSERVER', 'kafka:9092')
    movie_topic = os.getenv('MOVIE_TOPIC', 'movies_topic')
    rating_topic = os.getenv('RATING_TOPIC', 'ratings_topic')
    lmt = int(os.getenv('LIMIT', 100000))
    path = os.getenv('DATA')

    if path is None:
        raise Exception("Need to movies.jsonl file")

    df = pd.read_json(path, lines=True)

    logging.basicConfig(level=logging.INFO)
    pr = Producer({'bootstrap.servers': bootstrap})

    movie_gen = MovieDataGenerator(df)
    rating_gen = RatingGenerator(df)

    # Send movie data to movies topic (no limit as we send all movies)
    send(pr, topic=movie_topic, gen=movie_gen, limit=len(df))

    # Continuously generate and send ratings data to ratings topic
    send(pr, topic=rating_topic, gen=rating_gen, limit=lmt)
