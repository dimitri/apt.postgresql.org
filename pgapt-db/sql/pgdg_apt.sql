BEGIN;

CREATE SCHEMA apt;
SET search_path TO apt;

CREATE EXTENSION debversion;
CREATE EXTENSION hstore;


CREATE OR REPLACE FUNCTION control2hstore (control text)
RETURNS hstore LANGUAGE sql IMMUTABLE AS
$$SELECT regexp_replace (regexp_replace ($1, '([\\"])', '\\\1', 'g'),
	E'^([^:]*): (.*(?:\n .*)*)', '"\1"=>"\2",', 'gn')::hstore$$;
-- intentionally no E'' in the first line


-- ARCHIVE-WIDE DATA

CREATE TABLE architecture (
	architecture text PRIMARY KEY
);
COMMENT ON TABLE architecture IS 'All known architectures, including all, excluding source';


CREATE TABLE srcdistribution (
	distribution text NOT NULL,
	component text NOT NULL,
	last_update timestamp with time zone,
	active boolean NOT NULL DEFAULT TRUE,

	PRIMARY KEY (distribution, component)
);


CREATE TABLE distribution (
	distribution text NOT NULL,
	component text NOT NULL,
	architecture text NOT NULL
		REFERENCES architecture (architecture),
	last_update timestamp with time zone,
	active boolean NOT NULL DEFAULT TRUE,

	PRIMARY KEY (distribution, component, architecture),
	FOREIGN KEY (distribution, component) REFERENCES srcdistribution (distribution, component)
);


-- PACKAGE DATA

CREATE TABLE source (
	source text NOT NULL,
	srcversion debversion NOT NULL,
	control text NOT NULL,
	c hstore,

	PRIMARY KEY (source, srcversion)
);

CREATE TABLE package (
	package text NOT NULL,
	version debversion NOT NULL,
	arch text NOT NULL
		REFERENCES architecture (architecture),
	control text NOT NULL,
	c hstore,
	source text NOT NULL,
	srcversion debversion NOT NULL,

	PRIMARY KEY (package, version, arch)
);
--ALTER TABLE package ADD FOREIGN KEY (source, srcversion) REFERENCES source (source, srcversion);


-- SUITE DATA

CREATE TABLE sourcelist (
	distribution text NOT NULL,
	component text NOT NULL,
	source text NOT NULL,
	srcversion debversion NOT NULL,

	FOREIGN KEY (distribution, component) REFERENCES srcdistribution (distribution, component),
	FOREIGN KEY (source, srcversion) REFERENCES source (source, srcversion)
);
CREATE INDEX ON sourcelist (distribution, component);
CREATE INDEX ON sourcelist (source);

CREATE TABLE packagelist (
	distribution text NOT NULL,
	component text NOT NULL,
	architecture text NOT NULL,
	package text NOT NULL,
	version debversion NOT NULL,
	arch text NOT NULL,
	CHECK ((architecture = arch) OR (arch = 'all')),

	FOREIGN KEY (distribution, component, architecture)
		REFERENCES distribution (distribution, component, architecture),
	FOREIGN KEY (package, version, arch) REFERENCES package (package, version, arch)
);
CREATE INDEX ON packagelist (distribution, component, architecture);
CREATE INDEX ON packagelist (package);


GRANT USAGE ON SCHEMA apt TO PUBLIC;
GRANT SELECT ON ALL TABLES IN SCHEMA apt TO PUBLIC;

COMMIT;
