CREATE OR REPLACE FUNCTION m1_model.gen_trigger_element_types_relations_load()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  NEW.merged := m1_utils.jsonb_extend(OLD.merged, NEW.merged);
  RETURN NEW;
END;
$function$
;