CREATE OR REPLACE FUNCTION m1.gen_element_proc_get_info(aelm_proc_id integer)
 RETURNS TABLE(elm_id integer, elt_id character varying, len double precision, topology boolean, is_start_single boolean, is_end_single boolean)
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN QUERY (
    WITH ep AS (
      SELECT *, ST_Length(ep.geom) as len FROM m1_data.elements_proc ep WHERE elm_proc_id = aelm_proc_id
    )
    , edge AS (
      SELECT 
        l.elm_id, 
        l.elt_id, 
        ep.len,
        true as topology,
        ed.abs_next_right_edge = ed.edge_id as is_start_single,
        ed.abs_next_left_edge = ed.edge_id as is_end_single
      FROM ep
      INNER JOIN m1_topo_data.edge_data ed ON ep.edge_id = ed.edge_id
      INNER JOIN m1_topo_data.relation r ON ep.edge_id = r.element_id
      INNER JOIN topology.layer lr ON r.layer_id = lr.layer_id
      INNER JOIN m1_data.elements_in l ON ((l.topo_ln).id) = r.topogeo_id
      WHERE 
        lr.feature_type = 2 AND lr.table_name = 'elements_in' AND lr.schema_name = 'data'
    )
    , elm AS (
      SELECT 
        l.elm_id, 
        l.elt_id,
        ep.len,
        false,
        false,
        false
      FROM ep 
      INNER JOIN m1_data.elements_in l ON ep.elm_id = l.elm_id 
    )
    SELECT * FROM edge
    UNION
    SELECT * FROM elm
  );
END;
$function$
;