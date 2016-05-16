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
            utils.describetable(current_database(), table_schema, table_name, 'pre-data', targetdir)  AS src
          FROM information_schema.tables
          WHERE table_schema = schemaName AND table_type NOT IN ('VIEW')
        UNION
        SELECT * FROM (
          SELECT 
            table_schema as schema, 
            'tables_post'::varchar as type, 
            table_name as name, 
            (SELECT array_to_string(array_agg(line), E'\n\n') FROM (
              SELECT regexp_split_to_table(
                utils.describetable(current_database(), table_schema, table_name, 'post-data', targetdir),
                E'\n\n'
              )  AS line
            ) a WHERE line !~* E'(FOREIGN KEY)') as src
          FROM information_schema.tables
          WHERE table_schema = schemaName
        ) b
        UNION
        SELECT * FROM (
          SELECT 
            table_schema as schema, 
            'tables_fk'::varchar as type, 
            table_name as name, 
            (SELECT array_to_string(array_agg(line), E'\n\n') FROM (
              SELECT regexp_split_to_table(
                utils.describetable(current_database(), table_schema, table_name, 'post-data', targetdir),
                E'\n\n'
              )  AS line
            ) a WHERE line ~* E'(SET|FOREIGN KEY)') as src
          FROM information_schema.tables
          WHERE table_schema = schemaName
        ) a WHERE src ~* 'FOREIGN KEY'
        UNION
        SELECT 
            n.nspname as schema, 
            'functions'::varchar as type, 
            p.proname as name, 
            array_to_string(
              array_cat(
                array_agg(pg_get_functiondef(p.oid) ORDER BY p.proname, p.proargtypes),
                array_agg('COMMENT ON FUNCTION ' || n.nspname || '.' || p.proname || '(' || pg_get_function_identity_arguments(p.oid) || ') IS ''' || obj_description(p.oid) || '''' ORDER BY p.proname, p.proargtypes)
              )
              , E';\n\n'
            ) || ';' AS src
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