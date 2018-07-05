DROP TABLE reviews;

CREATE TABLE reviews
(
hw_id STRING,
hw_number INT,
label STRING,
review STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t';

LOAD DATA INPATH 'FPout/SP2017/part-r-00000' INTO
TABLE reviews;


ADD JAR stop.jar;


CREATE TEMPORARY FUNCTION STOP
      AS 'stop.StopWords';

DROP TABLE prereviews;


CREATE TABLE prereviews AS
SELECT hw_id, hw_number, label, STOP(lower(review)) FROM reviews;


INSERT OVERWRITE LOCAL DIRECTORY '/home/training/FPout' 
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY '\t' 
SELECT hw_id, hw_number, label, STOP(lower(review)) FROM reviews;



