CREATE OR REPLACE FUNCTION admin.rmtree(dirname character varying)
 RETURNS void
 LANGUAGE plpython3u
AS $function$
    import shutil
    shutil.rmtree(dirname, True)
$function$
;