BEGIN;

SET search_path TO apt;

-- architecture table

CREATE TEMP TABLE a ( architecture text ) ON COMMIT DROP;
INSERT INTO a VALUES ('source');
INSERT INTO a VALUES ('amd64');
INSERT INTO a VALUES ('i386');
-- no 'binary' here

INSERT INTO architecture
	SELECT architecture FROM a
	WHERE architecture NOT IN (SELECT architecture FROM architecture);
INSERT INTO architecture
	SELECT 'all' WHERE 'all' NOT IN (SELECT architecture FROM architecture);
INSERT INTO architecture
	SELECT 'binary' WHERE 'binary' NOT IN (SELECT architecture FROM architecture);

-- suite table

CREATE TEMP TABLE s ( suite text ) ON COMMIT DROP;
INSERT INTO s VALUES ('etch');
INSERT INTO s VALUES ('lenny');
INSERT INTO s VALUES ('squeeze');
INSERT INTO s VALUES ('wheezy');
INSERT INTO s VALUES ('sid');

CREATE TEMP TABLE c ( component text ) ON COMMIT DROP;
INSERT INTO c VALUES ('main');

CREATE TEMP TABLE tmp_suite (
	archive text NOT NULL,
	suite text NOT NULL,
	component text NOT NULL,
	architecture text NOT NULL
) ON COMMIT DROP;

INSERT INTO tmp_suite (archive, suite, component, architecture)
	SELECT 'pgapt', suite||'-pgapt', component, architecture FROM s, c, a;

-- copy missing data from temp table over
INSERT INTO suite (archive, suite, component, architecture)
	SELECT archive, suite, component, architecture
	FROM tmp_suite
	WHERE (archive, suite, component, architecture) NOT IN
		(SELECT archive, suite, component, architecture FROM suite);

COMMIT;
