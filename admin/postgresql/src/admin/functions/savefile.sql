CREATE OR REPLACE FUNCTION admin.savefile(filename character varying, data text)
 RETURNS boolean
 LANGUAGE plpython3u
AS $function$
  import os
  dirname = os.path.dirname(filename)
  if not os.path.exists(dirname):
    os.makedirs(dirname)
  text_file = open(filename, "w")
  text_file.write(data.replace('\r\n', '\n'))
  text_file.close()
  return True
$function$
;