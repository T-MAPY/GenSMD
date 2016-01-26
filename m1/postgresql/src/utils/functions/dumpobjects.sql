CREATE OR REPLACE FUNCTION utils.dumpobjects(schemalist character varying[], targetdir character varying)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
  schemaName varchar;
  objName varchar;
  copySQL varchar;
  obj record;
BEGIN
  FOR schemaName IN (SELECT schema_name FROM information_schema.schemata WHERE schema_name = ANY (schemalist)) LOOP
    PERFORM utils.rmtree(concat(targetdir,'/',schemaName));
    FOR obj IN (
      WITH objects AS
      (
        SELECT 
            table_schema as schema, 
            'tables'::varchar as type, 
            table_name as name, 
            utils.describetable(current_database(), table_schema, table_name, 'pre-data')  AS src
          FROM information_schema.tables
          WHERE table_schema = schemaName          
        UNION
        SELECT 
            table_schema as schema, 
            'tables_post'::varchar as type, 
            table_name as name, 
            utils.describetable(current_database(), table_schema, table_name, 'post-data')  AS src
          FROM information_schema.tables
          WHERE table_schema = schemaName          
        UNION
        SELECT 
            n.nspname as schema, 
            'functions'::varchar as type, 
            p.proname as name, 
            array_to_string(array_agg(pg_get_functiondef(p.oid) ORDER BY p.proname, p.proargtypes), E';\n\n') || ';' AS src
          FROM pg_proc p
          LEFT JOIN pg_namespace n ON n.oid = p.pronamespace
          WHERE n.nspname = schemaName
          GROUP BY n.nspname, p.proname
        UNION
        SELECT 
            table_schema as schema, 
            'views'::varchar as type, 
            table_name as name, 
            concat('CREATE OR REPLACE VIEW ',table_schema, '.',table_name, ' AS', E'\n', pg_get_viewdef(concat(table_schema,'.',table_name)::regclass, true), ';') AS src
          FROM information_schema.views
          WHERE table_schema = schemaName
      )
      SELECT *
      FROM objects)
    LOOP
      PERFORM utils.saveFile(concat_ws('/', targetDir, schemaName, obj.type, obj.name || '.sql'), obj.src);
    END LOOP;
  END LOOP;
END;
$function$
;