CREATE OR REPLACE FUNCTION m1.gen_topo_update()
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
BEGIN
  PERFORM m1.gen_topo_unregister();
  PERFORM m1.gen_topo_register();
  PERFORM m1.gen_topo_load_data();
  RETURN true;
END;
$function$
;