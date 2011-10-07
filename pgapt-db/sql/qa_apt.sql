BEGIN;

CREATE SCHEMA apt;
SET search_path TO apt;


-- ARCHIVE-WIDE DATA

CREATE TABLE architecture (
	architecture text PRIMARY KEY
);
COMMENT ON TABLE architecture IS 'All known architectures, including source and all';


CREATE TABLE suite (
	suite_id serial PRIMARY KEY,
	archive text NOT NULL,
	suite text NOT NULL,
	component text NOT NULL,
	architecture text NOT NULL
		REFERENCES architecture (architecture),
	last_update timestamp with time zone,
	active boolean NOT NULL DEFAULT TRUE
);
CREATE UNIQUE INDEX suite__archive_suite_component_architecture
ON suite (archive, suite, component, architecture);
COMMENT ON TABLE suite IS 'All known archives and suites';


-- Hopefully this is the only table that needs to be updated at release time
CREATE TABLE distribution (
	distribution text PRIMARY KEY,
	archive text NOT NULL,
	suite text NOT NULL
);
CREATE UNIQUE INDEX distribution__archive_suite ON distribution (archive, suite);
COMMENT ON TABLE distribution IS 'Symbolic names for archive/suite/* combinations';


-- PACKAGE DATA

CREATE TABLE package (
	package_id serial PRIMARY KEY,
	package text NOT NULL,
	version text NOT NULL,
	pkg_architecture text NOT NULL
		REFERENCES architecture (architecture)
);
COMMENT ON TABLE package IS 'All known packages and sources';

CREATE INDEX package__package_version_pkg_architecture ON package (package, version, pkg_architecture);
CREATE INDEX package__package_pkg_architecture ON package (package, pkg_architecture);


CREATE TABLE package_control (
	package_id integer PRIMARY KEY REFERENCES package,
	control text NOT NULL
);
COMMENT ON TABLE package_control IS
'Control files of all known packages and sources';


CREATE TABLE package_source (
	package_id integer PRIMARY KEY REFERENCES package,
	source_id integer NOT NULL REFERENCES package (package_id)
		CHECK (package_id <> source_id)
);
CREATE INDEX package_source__source_id ON package_source (source_id);
COMMENT ON TABLE package_source IS
'Table relating binary packages to their source package';


-- SUITE DATA

CREATE TABLE packagelist (
	suite_id integer NOT NULL REFERENCES suite,
	package_id integer NOT NULL REFERENCES package
	-- no PK
);
CREATE INDEX packagelist__suite_id ON packagelist (suite_id);
CREATE INDEX packagelist__package_id ON packagelist (package_id);
COMMENT ON TABLE packagelist IS 'Association of packages with suites';


-- SOURCE-SPECIFIC DATA

CREATE TABLE maintainer (
	maintainer serial PRIMARY KEY,
	name text NOT NULL
);

CREATE OR REPLACE FUNCTION maint_id_or_new (pname text)
RETURNS integer
LANGUAGE plpgsql VOLATILE STRICT
AS $$
DECLARE
	id integer;
BEGIN
	SELECT maintainer INTO id
		FROM maintainer
		WHERE name = pname;
	IF NOT FOUND THEN
		INSERT INTO maintainer (name) VALUES (pname)
		RETURNING maintainer INTO id;
	END IF;
	RETURN id;
END;
$$;

CREATE OR REPLACE FUNCTION maint_id (pname text)
RETURNS integer
LANGUAGE SQL STABLE STRICT
AS $$
	SELECT maintainer FROM apt.maintainer WHERE name = $1;
$$;

CREATE OR REPLACE FUNCTION maint_name (id integer)
RETURNS text
LANGUAGE SQL STABLE STRICT
AS $$
	SELECT name FROM apt.maintainer WHERE maintainer = $1;
$$;

CREATE OR REPLACE FUNCTION apt.email_address (name text)
RETURNS text
LANGUAGE SQL IMMUTABLE STRICT
AS $$
	SELECT regexp_replace ($1, E'.*<(.*)>.*', E'\\1');
$$;

CREATE INDEX maintainer__email_address ON maintainer (email_address (name));


CREATE TABLE source (
	package_id integer PRIMARY KEY REFERENCES package,
	-- from sources:
	maintainer integer NOT NULL REFERENCES maintainer,
	section text NULL,
	priority text NULL,
	dm_upload_allowed boolean NOT NULL DEFAULT FALSE,
	-- from projectb: (added by a separate script, hence all NULL)
	changed_by integer REFERENCES maintainer (maintainer),
	signed_by integer REFERENCES maintainer (maintainer),
	date timestamp with time zone
);
CREATE INDEX source__maintainer ON source (maintainer);
CREATE INDEX source__changed_by ON source (changed_by);
CREATE INDEX source__signed_by ON source (signed_by);


CREATE TABLE uploader (
	package_id integer REFERENCES source,
	maintainer integer REFERENCES maintainer,
	PRIMARY KEY (package_id, maintainer)
);
CREATE INDEX uploader__maintainer ON uploader (maintainer);

CREATE OR REPLACE FUNCTION uploaders (package_id integer)
RETURNS text[]
LANGUAGE SQL STABLE STRICT
AS $$
	SELECT array_agg (apt.maint_name (maintainer))
	FROM apt.uploader
	WHERE package_id = $1;
$$;


-- EXTRA PACKAGE INFORMATION

CREATE TABLE package_info (
	package_id integer REFERENCES package,
	field text,
	value text NOT NULL,
	PRIMARY KEY (package_id, field)
);

CREATE OR REPLACE FUNCTION apt.package_info (package_id integer, field text)
RETURNS text
LANGUAGE SQL STABLE STRICT
AS $$
	SELECT value FROM apt.package_info
	WHERE package_id = $1 AND field = $2;
$$;


-- GRANTS

GRANT USAGE ON SCHEMA apt TO PUBLIC;
GRANT SELECT ON
	architecture, suite, distribution, release, package, package_control,
	package_source, packagelist, maintainer, source, uploader, package_info
	TO PUBLIC;


COMMIT;
