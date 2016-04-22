CREATE OR REPLACE FUNCTION model.gen_trigger_element_types_relations_load()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  NEW.merged := utils.jsonb_extend(OLD.merged, NEW.merged);
  RETURN NEW;
END;
$function$
;