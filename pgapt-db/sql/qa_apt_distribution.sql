BEGIN;

SET search_path TO apt;

-- distribution table

DELETE FROM apt.distribution;

COPY apt.distribution (archive, suite, distribution) FROM STDIN WITH DELIMITER ' ';
pgapt etch-pgapt etch-pgapt
pgapt lenny-pgapt lenny-pgapt
pgapt squeeze-pgapt squeeze-pgapt
pgapt wheezy-pgapt wheezy-pgapt
pgapt sid-pgapt sid-pgapt
\.

COMMIT;
