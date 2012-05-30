BEGIN;

CREATE SCHEMA pgapt;
SET search_path = pgapt, apt, public;

-- Auxilliary views

-- All binaries with source packages
CREATE OR REPLACE VIEW package_view AS
 SELECT bl.suite_id, bsu.suite, bsu.component, bsu.architecture, b.package_id, b.package, b.version, b.pkg_architecture, b.source_id, bs.package AS source_package, bs.version AS source_version
   FROM package b
   JOIN package bs ON b.source_id = bs.package_id
   JOIN packagelist bl ON b.package_id = bl.package_id
   JOIN suite bsu USING (suite_id);

-- All sources
CREATE OR REPLACE VIEW source_view AS
 SELECT l.suite_id, su.suite, su.component, s.package_id AS source_id, s.package AS source_package, s.version AS source_version
   FROM package s
   JOIN packagelist l USING (package_id)
   JOIN suite su USING (suite_id)
  WHERE su.architecture = 'source'::text;

-- Actual views

-- Source

-- Sources never built in a suite
CREATE OR REPLACE VIEW missing_source AS
 SELECT suite.suite, sid.source_package AS package, sid.source_version AS version
   FROM suite, source_view sid
  WHERE suite.architecture = 'source'::text AND sid.suite = 'sid-pgapt'::text AND NOT (EXISTS ( SELECT other.suite_id, other.suite, other.component, other.source_id, other.source_package, other.source_version
           FROM source_view other
          WHERE other.source_package = sid.source_package AND other.suite = suite.suite));

-- Outdated sources in suites other than sid
CREATE OR REPLACE VIEW outdated_source AS
 SELECT other.suite, other.source_package AS package, other.source_version AS version, sid.source_version AS sid_version
   FROM source_view sid
   JOIN source_view other ON sid.source_package = other.source_package
  WHERE sid.suite = 'sid-pgapt'::text AND other.suite <> 'sid-pgapt'::text AND (sid.source_version::text || '~'::text) > (other.source_version::text || '~'::text);

-- Source TODO list
CREATE OR REPLACE VIEW todo_source AS
         SELECT outdated_source.suite, outdated_source.package, outdated_source.version, outdated_source.sid_version
           FROM outdated_source
UNION ALL
         SELECT missing_source.suite, missing_source.package, NULL::debversion, missing_source.version AS sid_version
           FROM missing_source;

-- Binary

-- Binaries in sid never built for a given other suite
CREATE OR REPLACE VIEW missing_binary AS
 SELECT suite.suite, suite.architecture, sid.package, sid.source_package, sid.source_version AS new_source_version
   FROM package_view sid, suite
  WHERE sid.suite = 'sid-pgapt'::text AND suite.architecture = sid.architecture AND NOT (EXISTS ( SELECT other.suite_id, other.suite, other.component, other.architecture, other.package_id, other.package, other.version, other.pkg_architecture, other.source_id, other.source_package, other.source_version
           FROM package_view other
          WHERE sid.package = other.package AND other.suite = suite.suite));

-- Existing binaries where newer source exists (all suites)
CREATE OR REPLACE VIEW outdated_binary AS
 SELECT b.suite, b.architecture, b.package, s.source_package, b.source_version, s.source_version AS new_source_version
   FROM package_view b
   JOIN source_view s ON b.source_package = s.source_package AND b.suite = s.suite
  WHERE b.source_version < s.source_version;

-- Binary TODO list
CREATE OR REPLACE VIEW todo_binary AS
         SELECT outdated_binary.suite, outdated_binary.architecture, outdated_binary.package, outdated_binary.source_package, outdated_binary.source_version, outdated_binary.new_source_version
           FROM outdated_binary
UNION ALL
         SELECT missing_binary.suite, missing_binary.architecture, missing_binary.package, missing_binary.source_package, NULL::debversion AS source_version, missing_binary.new_source_version
           FROM missing_binary;

COMMIT;
