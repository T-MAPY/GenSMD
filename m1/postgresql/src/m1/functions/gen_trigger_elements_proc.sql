CREATE OR REPLACE FUNCTION m1.gen_trigger_elements_proc()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  INSERT INTO data.element_footprints (elm_proc_id, source_type, source_elt_id, target_elt_id, footprint)
    SELECT NEW.elm_proc_id, source_type, source_elt_id, target_elt_id, footprint
    FROM m1.gen_element_proc_create_footprints(NEW.elm_proc_id)
  ON CONFLICT ON CONSTRAINT element_footprints_pkey 
  DO UPDATE SET footprint = EXCLUDED.footprint;
  RETURN NEW;
END;
$function$
;