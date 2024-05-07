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
    movieId          INT,
    rating DOUBLE,
    ratingTimeMillis BIGINT,                            -- Read the epoch milliseconds as BIGINT
    ratingTime AS TO_TIMESTAMP_LTZ(ratingTimeMillis, 3) -- Convert to TIMESTAMP_LTZ
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

INSERT INTO RatedMoviesSink
SELECT m.movieId,
       m.title,
       m.releaseYear,
       m.actors,
       r.rating,
       r.ratingTime
FROM MovieRatings r
         JOIN
     Movies m
     ON r.movieId = m.movieId;
