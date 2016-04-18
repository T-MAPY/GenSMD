CREATE OR REPLACE FUNCTION m1.gen_trigger_elements_proc()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
  params jsonb;
BEGIN
  --RAISE NOTICE 'id: %', NEW.id;
  IF (NEW.elm_id IS NOT NULL) THEN
    SELECT INTO params footprint_params 
    FROM data.elements_in e
    INNER JOIN data.element_types t ON e.elt_id = t.elt_id
    WHERE e.elm_id = NEW.elm_id;
    NEW.footprint = m1.gen_create_footprint(NEW.geom, params);
  ELSE
    NEW.footprint = m1.gen_topo_edge_create_footprint(NEW.edge_id);
  END IF;
  RETURN NEW;
END;
$function$
;