CREATE OR REPLACE FUNCTION m1.m1_backup(filterschema character varying, filterobject character varying, targetdir character varying)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
  schemaName varchar;
  objName varchar;
  copySQL varchar;
  obj record;
BEGIN
  FOR schemaName IN (SELECT schema_name FROM information_schema.schemata WHERE schema_name ~ filterSchema) LOOP
    FOR obj IN (
      WITH objects AS
      (
        SELECT n.nspname as schema, 'functions'::varchar as type, p.proname as name, pg_get_functiondef(p.oid) AS src
          FROM pg_proc p
          LEFT JOIN pg_namespace n ON n.oid = p.pronamespace
          WHERE n.nspname = schemaName
        UNION
        SELECT table_schema as schema, 'views'::varchar as type, table_name as name, concat('CREATE OR REPLACE VIEW ',table_schema, '.',table_name, ' AS', E'\n', pg_get_viewdef(concat(table_schema,'.',table_name)::regclass, true)) AS src
          FROM information_schema.views
          WHERE table_schema = schemaName
      )
      SELECT *
      FROM objects)
    LOOP
      PERFORM m1.saveFile(concat_ws('/', targetDir, schemaName, obj.type, obj.name || '.sql'), obj.src);
    END LOOP;
  END LOOP;
END;
$function$
