CREATE OR REPLACE FUNCTION utils.describetable(database_name text, schema_name text, table_name text, section text DEFAULT ''::text)
 RETURNS text
 LANGUAGE plpython3u
 SECURITY DEFINER
AS $function$
  import os, subprocess, io
  import re

  new_env = os.environ.copy()
  new_env['PGPASSWORD'] = 'postgres'  

  par_section = ''
  if (section):
    par_section = ' --section=' + section;

  proc = subprocess.Popen('c:/Progra~2/PostgreSQL/9.4/bin/pg_dump.exe -U postgres -O -s -t ' + schema_name + '.' + table_name + par_section + ' ' + database_name, 
    env=new_env, 
    stdout=subprocess.PIPE
  )

  pg_dump_output = "SET search_path = " + schema_name + ", public, pg_catalog;\n"
  for line in io.TextIOWrapper(proc.stdout, encoding="utf-8"):
    if (not line.startswith(tuple(['--', 'SET']))) and line.strip() != '':
      if line.startswith(tuple(['CREATE', 'ALTER'])):
        pg_dump_output += "\n"; 
      pg_dump_output += line;

  pg_dump_output += "\nSET search_path TO DEFAULT;\n";

  return pg_dump_output
$function$
;