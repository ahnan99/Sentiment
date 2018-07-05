DROP TABLE docs;

CREATE TABLE docs AS
SELECT lower(review) AS line FROM reviews;

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
SELECT w.word,w.count FROM temp1 w FULL OUTER JOIN poswords n ON (w.word=n.word) WHERE n.word IS NULL;

DROP TABLE swlist;
CREATE TABLE swlist AS
SELECT word FROM temp2 WHERE count>=50;

DROP TABLE nwc;
CREATE TABLE nwc AS
SELECT w.word,w.count AS count FROM word_counts w JOIN negwords n ON (w.word=n.word)
ORDER BY count DESC;

DROP TABLE pwc;
CREATE TABLE pwc AS
SELECT w.word,w.count AS count FROM word_counts w JOIN poswords n ON (w.word=n.word)
ORDER BY count DESC;




