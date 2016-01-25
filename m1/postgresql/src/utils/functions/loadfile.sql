CREATE OR REPLACE FUNCTION utils.loadfile(filename character varying)
 RETURNS text
 LANGUAGE plpython3u
AS $function$
  infile = open(filename, 'r')
  data = infile.read()
  infile.close()
  return data
$function$
;