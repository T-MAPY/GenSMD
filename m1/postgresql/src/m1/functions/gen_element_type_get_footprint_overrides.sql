CREATE OR REPLACE FUNCTION m1.gen_element_type_get_footprint_overrides(aelt_id character varying, bidirectional boolean DEFAULT false)
 RETURNS TABLE(elt_id character varying)
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN QUERY (
    SELECT 
      jsonb_object_keys(t.footprint_params->'overrides')::varchar as elt_id
    FROM data.element_types t 
    WHERE t.elt_id = aelt_id
    UNION
    SELECT 
      t.elt_id 
    FROM data.element_types t 
    WHERE bidirectional AND t.footprint_params ? 'overrides' AND t.footprint_params->'overrides' ? aelt_id
  );
END;
$function$
;