ADD JAR s3://liu.yinan-emr/FP/json-serde-1.3.8-jar-with-dependencies.jar;

DROP TABLE json;

CREATE EXTERNAL TABLE json ( reviewerID string, asin string, reviewerName string, helpful string, reviewText string,overall double, summary string, unixReviewTime string, reviewTime string)
      ROW FORMAT SERDE 'org.openx.data.jsonserde.JsonSerDe'
      LOCATION 's3://liu.yinan-emr/reviews';


ADD JAR s3://liu.yinan-emr/FP/jsw.jar;

ADD FILE s3://liu.yinan-emr/FP/english.stop1;

CREATE TEMPORARY FUNCTION JSTOP
      AS 'json.JsonStopWords';

CREATE TEMPORARY FUNCTION JPRE
      AS 'json.JsonPre';

CREATE TEMPORARY FUNCTION JSCORE
      AS 'json.JsonScore';

ADD FILE s3://liu.yinan-emr/FP/neg-words.txt;

ADD FILE s3://liu.yinan-emr/FP/pos-words.txt;

DROP TABLE predict;

CREATE TABLE predict AS
SELECT overall,JSCORE(JSTOP(lower(JPRE(reviewText)))) AS score FROM json;


INSERT OVERWRITE DIRECTORY 's3://liu.yinan-emr/jsonOutput/scores' SELECT * FROM predict;

INSERT OVERWRITE DIRECTORY 's3://liu.yinan-emr/jsonOutput/allnumber' SELECT COUNT(*) FROM predict;

INSERT OVERWRITE DIRECTORY 's3://liu.yinan-emr/jsonOutput/correctprediction' SELECT COUNT(*) FROM predict WHERE overall=score;
