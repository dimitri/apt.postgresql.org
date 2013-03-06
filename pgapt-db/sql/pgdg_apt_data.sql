BEGIN;

INSERT INTO architecture
    SELECT * FROM (VALUES ('amd64'), ('i386')) arch(architecture)
    WHERE NOT EXISTS (SELECT * FROM architecture
          WHERE architecture = arch.architecture);

INSERT INTO srcdistribution
    SELECT * FROM (VALUES ('sid-pgdg'), ('wheezy-pgdg'), ('squeeze-pgdg')) dist(distribution),
                  (VALUES ('main'), ('9.2'), ('9.1'), ('9.0'), ('8.4'), ('8.3')) comp(component)
    WHERE NOT EXISTS (SELECT * FROM srcdistribution
                      WHERE (distribution, component) = (dist.distribution, comp.component));

INSERT INTO distribution
    SELECT * FROM (VALUES ('sid-pgdg'), ('wheezy-pgdg'), ('squeeze-pgdg')) dist(distribution),
                  (VALUES ('main'), ('9.2'), ('9.1'), ('9.0'), ('8.4'), ('8.3')) comp(component),
                  (VALUES ('amd64'), ('i386')) arch(architecture)
    WHERE NOT EXISTS (SELECT * FROM distribution
          WHERE (distribution, component, architecture) = (dist.distribution, comp.component, arch.architecture));

COMMIT;
