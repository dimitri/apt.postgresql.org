BEGIN;

CREATE TABLE pgversion (
	pgversion text NOT NULL
);

INSERT INTO pgversion VALUES ('8.2'), ('8.3'), ('8.4'), ('9.0'), ('9.1');

CREATE VIEW all_versioned_packages AS
SELECT DISTINCT
	pgversion,
	regexp_replace (p.package, E'[0-9]+\\.[0-9].*', '') ||
	pgversion ||
	regexp_replace (p.package, E'.*[0-9]+\\.[0-9]', '') AS package,
	s.package AS source,
	MAX (s.version) AS version
FROM package p
	JOIN package_source ps ON (p.package_id = ps.package_id)
	JOIN package s ON (ps.source_id = s.package_id)
	JOIN packagelist pl ON (ps.package_id = pl.package_id)
	JOIN suite su ON (pl.suite_id = su.suite_id)
	JOIN pgversion pg ON (s.package = 'postgresql-'||pgversion OR NOT s.package ~ E'^postgresql-[0-9]+\\.[0-9]$')
WHERE p.package ~ E'[0-9]\\.[0-9]'
	AND suite = 'sid-pgapt'
GROUP BY 1, 2, 3;

CREATE VIEW missing_packages AS
SELECT m.*, s.suite, s.architecture
FROM all_versioned_packages m, suite s
WHERE NOT EXISTS
	(SELECT * FROM package bin_p
		JOIN packagelist bin_pl ON (bin_p.package_id = bin_pl.package_id)
		JOIN suite bin_s ON (bin_pl.suite_id = bin_s.suite_id)
	WHERE
		m.package = bin_p.package AND
		s.archive = bin_s.archive AND
		s.suite = bin_s.suite AND
		s.architecture = bin_s.architecture)
AND architecture <> 'source';

CREATE VIEW outdated_packages AS
SELECT ap.*, s.suite, s.architecture, p.version AS oldversion
FROM all_versioned_packages ap
	JOIN package p ON (ap.package = p.package)
	JOIN packagelist pl ON (p.package_id = pl.package_id)
	JOIN suite s ON (pl.suite_id = s.suite_id)
WHERE p.version::debversion < ap.version::debversion;

COMMIT;
