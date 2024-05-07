CREATE TABLE Movies
(
    movieId             INT,
    title               STRING,
    releaseYear         INT,
    country             STRING,
    rating DOUBLE,
    genres              ARRAY<STRING>,
    actors              ARRAY<STRING>,
    directors           ARRAY<STRING>,
    composers           ARRAY<STRING>,
    screenwriters       ARRAY<STRING>,
    productionCompanies ARRAY<STRING>,
    cinematographer     STRING
) WITH (
      'connector' = 'kafka',
      'topic' = 'movies',
      'properties.bootstrap.servers' = 'kafka:9092',
      'scan.startup.mode' = 'earliest-offset',
      'format' = 'json'
      );

SELECT *
FROM Movies
WHERE LOWER(title) LIKE '%lethal weapon%';


CREATE TABLE MovieRatings
(
    movieId    INT,
    rating DOUBLE,
    ratingTime TIMESTAMP(3),                                      -- Using TIMESTAMP(3) to include millisecond precision
    WATERMARK FOR ratingTime AS ratingTime - INTERVAL '5' SECONDS -- Adjust as needed based on your event-time characteristics
) WITH (
      'connector' = 'kafka',
      'topic' = 'movie_ratings', -- Ensure this is the correct Kafka topic name for ratings
      'properties.bootstrap.servers' = 'kafka:9092', -- Adjust for your Kafka setup
      'scan.startup.mode' = 'latest-offset', -- Adjust if needed
      'format' = 'json', -- Assuming JSON format for data
      'json.timestamp-format.standard' = 'ISO-8601' -- Ensure this matches the format used in your data
      );


CREATE TABLE MovieRatings
(
    movieId          INT,
    rating DOUBLE,
    ratingTimeMillis BIGINT,                             -- Read the epoch milliseconds as BIGINT
    ratingTime AS TO_TIMESTAMP_LTZ(ratingTimeMillis, 3), -- Convert to TIMESTAMP_LTZ
    WATERMARK FOR ratingTime AS ratingTime - INTERVAL '5' SECONDS
) WITH (
      'connector' = 'kafka',
      'topic' = 'movie_ratings',
      'properties.bootstrap.servers' = 'kafka:9092',
      'scan.startup.mode' = 'latest-offset',
      'format' = 'json'
      );

SELECT movieId, AVG(rating) as avgRating
FROM MovieRatings
GROUP BY movieId;

SELECT movieId, rating, ratingTime
FROM MovieRatings LIMIT 10;

CREATE TABLE RatedMoviesSink
(
    movieId     INT,
    title       STRING,
    releaseYear INT,
    actors      ARRAY<STRING>,
    rating DOUBLE,
    ratingTime  TIMESTAMP(3),
    PRIMARY KEY (movieId) NOT ENFORCED -- Declare the PRIMARY KEY constraint
) WITH (
      'connector' = 'upsert-kafka', -- This enables updates and deletes
      'topic' = 'rated_movies',
      'properties.bootstrap.servers' = 'kafka:9092',
      'key.format' = 'json', -- Key format is JSON, matching the value format
      'value.format' = 'json' -- Values are serialized in JSON
      );
