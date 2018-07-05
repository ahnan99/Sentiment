


DROP TABLE reviews_sp2017;

CREATE TABLE reviews_sp2017
(
hw_id STRING,
hw_number INT,
label STRING,
review STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t';

LOAD DATA INPATH '/dualcore/sp2017reviews.txt' INTO
TABLE reviews;


ADD JAR stop.jar;


CREATE TEMPORARY FUNCTION STOP
      AS 'stop.StopWords';


DROP TABLE negwords;

CREATE TABLE negwords
(
word STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t';

LOAD DATA INPATH '/dualcore/neg-words.txt' INTO
TABLE negwords;



DROP TABLE poswords;

CREATE TABLE poswords
(
word STRING
);

LOAD DATA INPATH '/dualcore/pos-words.txt' INTO
TABLE poswords;



DROP TABLE prereviews;


CREATE TABLE prereviews AS
SELECT hw_id, hw_number, label, STOP(lower(review)) FROM reviews;





