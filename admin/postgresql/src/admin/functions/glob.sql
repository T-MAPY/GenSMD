CREATE OR REPLACE FUNCTION admin.glob(dirname character varying)
 RETURNS character varying[]
 LANGUAGE plpython3u
AS $function$
    import glob
    return glob.glob(dirname)
$function$
;