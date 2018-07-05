
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

LOAD DATA INPATH '/dualcore/allreviews' INTO
TABLE reviews;


DROP TABLE docs;

CREATE TABLE docs AS
SELECT lower(review) AS line FROM reviews;

DROP TABLE wc;

CREATE TABLE wc AS
SELECT word, count(1) AS count FROM
(SELECT explode(split(line, ' ')) AS word FROM docs) w
GROUP BY word
ORDER BY word;

DROP TABLE nwc;
CREATE TABLE nwc AS
SELECT w.word,w.count AS count FROM wc w JOIN negwords n ON (w.word=n.word)
ORDER BY count DESC;

DROP TABLE pwc;
CREATE TABLE pwc AS
SELECT w.word,w.count AS count FROM wc w JOIN poswords n ON (w.word=n.word)
ORDER BY count DESC;




ADD JAR stop.jar;

ADD FILE english.stop;

CREATE TEMPORARY FUNCTION STOP AS 'stop.StopWords';



DROP TABLE preall;

CREATE TABLE preall AS
SELECT hw_id, hw_number, label, STOP(lower(review)) AS review FROM reviews;

DROP TABLE 2gram;
CREATE TABLE 2gram AS
SELECT ngrams.ngram, ngrams.estfrequency FROM
(SELECT EXPLODE(NGRAMS(SENTENCES(review), 2, 3)) AS ngrams FROM preall) n;

DROP TABLE 3gram;
CREATE TABLE 3gram AS
SELECT ngrams.ngram, ngrams.estfrequency FROM
(SELECT EXPLODE(NGRAMS(SENTENCES(review), 3, 3)) AS ngrams FROM preall) n;

select * from 2gram order by estfrequency DESC;
select * from 3gram order by estfrequency DESC;


ADD JAR score.jar;

ADD FILE neg-words.txt;

ADD FILE pos-words.txt;

CREATE TEMPORARY FUNCTION SCORE AS 'sentimentscore.Score';



DROP TABLE allscore;

CREATE TABLE allscore AS
SELECT hw_id, hw_number, label, SCORE(review) AS score FROM preall;

SELECT count(*) FROM allscore WHERE (score < 0 AND label='negative') OR (score = 0 AND label='neutral') OR (score > 0 AND label='positive');

SELECT count(*) FROM allscore;


