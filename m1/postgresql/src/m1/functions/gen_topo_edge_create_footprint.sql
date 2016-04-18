CREATE OR REPLACE FUNCTION m1.gen_topo_edge_create_footprint(aedge_id integer)
 RETURNS geometry
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN (
    WITH data AS (
      SELECT 
        t.footprint_params, 
        ed.abs_next_right_edge = ed.edge_id as is_start_single,
        ed.abs_next_left_edge = ed.edge_id as is_end_single,
        ST_Length(ed.geom) as len,
        COALESCE((t.footprint_params#>>'{buffer,radius}')::float, 0) as radius,
        ed.geom
      FROM data.elements_in e 
      INNER JOIN topo_data.edge_data ed ON TRUE
      INNER JOIN data.element_types t ON e.elt_id = t.elt_id 
      WHERE ed.edge_id = aedge_id AND e.elm_id = ANY (m1.gen_topo_edge_get_elm_ids(aedge_id))
    )
    , shorten AS (
      SELECT 
        ST_Line_Substring(
          d.geom, 
          CASE WHEN d.is_start_single THEN 0 ELSE 2 * d.radius / d.len END,
          CASE WHEN d.is_end_single THEN 1 ELSE 1 - (2 * d.radius / d.len) END
        ) as geom
        , jsonb_set(footprint_params, '{buffer}', footprint_params->'buffer' 
          || CASE WHEN is_start_single THEN '{}'::jsonb ELSE '{"capstart": "triangle"}'::jsonb END
          || CASE WHEN is_end_single THEN '{}'::jsonb ELSE '{"capend": "triangle"}'::jsonb END
        ) as footprint_params
      FROM data d
      WHERE 
        (CASE WHEN d.is_start_single THEN 0 ELSE 2 END + CASE WHEN d.is_end_single THEN 0 ELSE 2 END) * d.radius < d.len
    )
    SELECT ST_Union(m1.gen_create_footprint(geom, footprint_params)) FROM shorten
  );
END;
$function$
;