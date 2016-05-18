CREATE OR REPLACE FUNCTION m1.gen_trigger_elements_proc()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  INSERT INTO m1_data.element_footprints (
      elm_proc_id, foo_type, elt_id_from, elt_id_to, elm_proc_topology, geom
    )
    SELECT 
      NEW.elm_proc_id, foo_type, elt_id_from, elt_id_to, elm_proc_topology, geom
    FROM m1.gen_element_proc_create_footprints(NEW.elm_proc_id)
  ON CONFLICT ON CONSTRAINT element_footprints_pkey 
  DO UPDATE SET 
    elm_proc_topology = EXCLUDED.elm_proc_topology, 
    geom = EXCLUDED.geom;
  RETURN NEW;
END;
$function$
;