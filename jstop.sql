ADD JAR s3://liu.yinan-emr/FP/json-serde-1.3.8-jar-with-dependencies.jar;

DROP TABLE json;

CREATE EXTERNAL TABLE json ( reviewerID string, asin string, reviewerName string, helpful string, reviewText string,overall double, summary string, unixReviewTime string, reviewTime string)
      ROW FORMAT SERDE 'org.openx.data.jsonserde.JsonSerDe'
      LOCATION 's3://liu.yinan-emr/reviews';

ADD JAR s3://liu.yinan-emr/FP/jsw.jar;

CREATE TEMPORARY FUNCTION JPRE
      AS 'json.JsonPre';

DROP TABLE negwords;

CREATE TABLE negwords
(
word STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t';

LOAD DATA INPATH 's3://liu.yinan-emr/FP/neg-words.txt' INTO
TABLE negwords;



DROP TABLE poswords;

CREATE TABLE poswords
(
word STRING
);

LOAD DATA INPATH 's3://liu.yinan-emr/FP/pos-words.txt' INTO
TABLE poswords;



DROP TABLE docs;

CREATE TABLE docs AS
SELECT lower(JPRE(reviewText)) AS line FROM json;

DROP TABLE word_counts;

CREATE TABLE word_counts AS
SELECT word, count(1) AS count FROM
(SELECT explode(split(line, ' ')) AS word FROM docs) w
GROUP BY word
ORDER BY word;

DROP TABLE temp1;
CREATE TABLE temp1 AS
SELECT w.word,w.count FROM word_counts w FULL OUTER JOIN negwords n ON (w.word=n.word) WHERE n.word IS NULL;

DROP TABLE temp2;
CREATE TABLE temp2 AS
SELECT w.word AS word,w.count AS number FROM temp1 w FULL OUTER JOIN poswords n ON (w.word=n.word) WHERE n.word IS NULL;

INSERT OVERWRITE DIRECTORY 's3://liu.yinan-emr/jsonOutput/stopwords' SELECT word FROM temp2 WHERE number>1000;

