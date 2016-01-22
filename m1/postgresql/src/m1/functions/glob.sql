CREATE OR REPLACE FUNCTION m1.glob(dirname text)
 RETURNS text[]
 LANGUAGE plpython3u
AS $function$
    import glob
    return glob.glob(dirname)
$function$
