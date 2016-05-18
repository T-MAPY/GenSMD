CREATE OR REPLACE FUNCTION m1.gen_topo_is_registered()
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN (topology.TopologySummary('m1_topo_data') !~ 'unregistered');
END;
$function$
;