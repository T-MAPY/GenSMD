CREATE OR REPLACE FUNCTION m1.gen_topo_edge_get_elm_ids(aedge_id integer)
 RETURNS integer[]
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN (
    SELECT array_agg(elm_id) 
    FROM data.elements_in l 
    INNER JOIN topo_data.relation r ON ((l.topo_ln).id) = r.topogeo_id 
    INNER JOIN topology.layer lr ON r.layer_id = lr.layer_id
    WHERE r.element_id = aedge_id AND lr.feature_type = 2 AND lr.table_name = 'elements_in' AND lr.schema_name = 'data'
  );
END;
$function$
;