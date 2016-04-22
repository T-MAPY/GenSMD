CREATE OR REPLACE FUNCTION utils.jsonb_extend(js1 jsonb, js2 jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN utils.jsondoc_extend(js1::text, js2::text)::jsonb;
END;
$function$
;