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
TABLE reviews_sp2017;


ADD JAR stop.jar;

ADD FILE english.stop;

CREATE TEMPORARY FUNCTION STOP
      AS 'stop.StopWords';

DROP TABLE presp2017;

CREATE TABLE presp2017
AS SELECT hw_id, hw_number, label, STOP(lower(review)) AS review FROM reviews_sp2017;




ADD JAR score.jar;

ADD FILE neg-words.txt;

ADD FILE pos-words.txt;

CREATE TEMPORARY FUNCTION SCORE
      AS 'sentimentscore.Score';



DROP TABLE sp2017score;

CREATE TABLE sp2017score AS
SELECT hw_id, hw_number, label, SCORE(review) FROM presp2017;



--p3 step 1 a
DROP TABLE avgsp2017;
CREATE TABLE avgsp2017 AS
select hw_number, avg(score) AS avgscore
from (
  select hw_number,score from sp2017score
) t
group by hw_number;


--p3 step 1 b
DROP TABLE docs_sp2017;

CREATE TABLE docs_sp2017 AS
SELECT lower(review) AS line FROM reviews_sp2017;

DROP TABLE wcsp2017;

CREATE TABLE wcsp2017 AS
SELECT word, count(1) AS count FROM
(SELECT explode(split(line, ' ')) AS word FROM docs) w
GROUP BY word
ORDER BY word;

DROP TABLE nwcsp2017;
CREATE TABLE nwcsp2017 AS
SELECT w.word,w.count AS count FROM wcsp2017 w JOIN negwords n ON (w.word=n.word)
ORDER BY count DESC;

DROP TABLE pwcsp2017;
CREATE TABLE pwcsp2017 AS
SELECT w.word,w.count AS count FROM wcsp2017 w JOIN poswords n ON (w.word=n.word)
ORDER BY count DESC;


--p3 step 2 a b (ngram)
DROP TABLE 2gsp2017;
CREATE TABLE 2gsp2017 AS
SELECT ngrams.ngram, ngrams.estfrequency FROM
(SELECT EXPLODE(NGRAMS(SENTENCES(review), 2, 3)) AS ngrams FROM presp2017) n;


DROP TABLE 3gsp2017;
CREATE TABLE 3gsp2017 AS
SELECT ngrams.ngram, ngrams.estfrequency FROM
(SELECT EXPLODE(NGRAMS(SENTENCES(review), 3, 3)) AS ngrams FROM presp2017) n;


--p3 step 3 a
SELECT avg(score) FROM sp2017score WHERE hw_number < 7;

SELECT avg(score) FROM sp2017score WHERE hw_number > 6;

SELECT avg(score) FROM sp2017score WHERE hw_number = 1 OR hw_number = 2 OR hw_number = 7;

SELECT avg(score) FROM sp2017score WHERE hw_number = 3 OR hw_number = 4 OR hw_number = 5 OR hw_number = 6 OR hw_number = 8;

SELECT avg(score) FROM sp2017score WHERE hw_number = 9 OR hw_number = 10;

--p3 step 4 accuracy


SELECT count(*) FROM sp2017score WHERE (score < 0 AND label='negative') OR (score = 0 AND label='neutral') OR (score > 0 AND label='positive');

SELECT count(*) FROM sp2017score;

