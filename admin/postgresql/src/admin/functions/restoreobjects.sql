CREATE OR REPLACE FUNCTION admin.restoreobjects(schemalist character varying[], sourcedir character varying, clear boolean DEFAULT false)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
  schemaName varchar;
  fileList varchar[];
  fileName varchar;
  objType varchar;
  sql varchar;
BEGIN
  FOR schemaName IN (SELECT * FROM unnest(schemalist)) LOOP
    IF (clear) THEN
      EXECUTE 'DROP SCHEMA IF EXISTS ' || schemaName || ' CASCADE';
    END IF;
    EXECUTE 'CREATE SCHEMA IF NOT EXISTS ' || schemaName;
    FOREACH objType IN ARRAY array['functions', 'tables', 'tables_post', 'tables_fk', 'views'] LOOP
      fileList := admin.glob(concat(sourcedir,'/',schemaName,'/',objType,'/*.sql'));
      FOREACH fileName IN ARRAY fileList LOOP
        sql := admin.loadfile(fileName);
        --RAISE NOTICE '%', sql;
        EXECUTE sql;
      END LOOP;
    END LOOP ;
  END LOOP;
END;
$function$
;