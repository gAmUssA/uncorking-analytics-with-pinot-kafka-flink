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
      'connector' = 'pulsar',
      'topics' = 'persistent://public/default/movies',
      'service-url' = 'pulsar://pulsar:6650',
      'value.format' = 'json',
      'source.subscription-name' = 'flink-movies-subscription',
      'source.subscription-type' = 'Shared'
      );

CREATE TABLE MovieRatings
(
    movieId          INT,
    rating DOUBLE,
    ratingTimeMillis BIGINT,
    ratingTime AS TO_TIMESTAMP_LTZ(ratingTimeMillis, 3)
) WITH (
      'connector' = 'pulsar',
      'topics' = 'persistent://public/default/ratings',
      'service-url' = 'pulsar://pulsar:6650',
      'value.format' = 'json',
      'source.subscription-name' = 'flink-ratings-subscription',
      'source.subscription-type' = 'Shared'
      );