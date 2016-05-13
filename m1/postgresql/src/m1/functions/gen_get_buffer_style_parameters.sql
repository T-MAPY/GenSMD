CREATE OR REPLACE FUNCTION m1.gen_get_buffer_style_parameters(params jsonb, endtype text, functype text DEFAULT 'buffer'::text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE
  result text;
BEGIN
  result := '';
  IF (functype = 'buffer') THEN
    IF (params#>'{buffer,quad_segs}' IS NOT NULL) THEN
      result := result || ' quad_segs=' || (params#>>'{buffer,quad_segs}');
    END IF;
    result := result || ' endcap=' || COALESCE(
      CASE jsonb_extract_path_text(params, 'buffer', 'cap' || endtype) 
      WHEN 'triangle' 
      THEN 'round quad_segs=1' 
      ELSE jsonb_extract_path_text(params, 'buffer', 'cap' || endtype) 
      END, 
      CASE jsonb_extract_path_text(params, 'buffer', 'cap') 
      WHEN 'triangle' 
      THEN 'round quad_segs=1' 
      ELSE jsonb_extract_path_text(params, 'buffer', 'cap') 
      END, 
      'round'
    );
  END IF;
  IF (jsonb_extract_path(params, 'buffer') ? 'join') THEN
    result := result || ' join=' || jsonb_extract_path_text(params, 'buffer', 'join');
  END IF;
  RETURN trim(result);
END;
$function$
;