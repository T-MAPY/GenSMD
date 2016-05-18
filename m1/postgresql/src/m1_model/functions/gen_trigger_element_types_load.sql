CREATE OR REPLACE FUNCTION m1_model.gen_trigger_element_types_load()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  NEW.merged := m1_utils.jsonb_extend(m1_utils.jsonb_extend(OLD.merged, NEW.merged), OLD.source);
  RETURN NEW;
END;
$function$
;