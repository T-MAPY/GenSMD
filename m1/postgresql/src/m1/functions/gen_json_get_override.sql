CREATE OR REPLACE FUNCTION m1.gen_json_get_override(adata jsonb, path text, akey text)
 RETURNS jsonb
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN jsonb_set(adata, array[path], jsonb_extract_path(adata, path) || COALESCE(jsonb_extract_path(adata, 'overrides', akey, path), '{}'::jsonb));
END;
$function$
;