CREATE OR REPLACE FUNCTION m1.gen_element_proc_create_footprints(aelm_proc_id integer)
 RETURNS TABLE(foo_type smallint, elt_id_from character varying, elt_id_to character varying, elm_proc_topology boolean, geom geometry)
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN QUERY

    WITH ep AS (
      SELECT * FROM m1_data.elements_proc WHERE elm_proc_id = aelm_proc_id
    )
    , info AS (
      SELECT DISTINCT elt_id, len, topology, is_start_single, is_end_single 
      FROM m1.gen_element_proc_get_info((SELECT elm_proc_id FROM ep))
    )
    -- default footprint
    , footprint1 AS (
      SELECT 
        1::smallint as foo_type, 
        info.elt_id as elt_id_from, 
        '-'::varchar as elt_id_to,
        t.topology as elm_proc_topology,
        m1.gen_create_footprint(ep.geom, t.footprint) as geom
      FROM ep
      INNER JOIN info ON TRUE
      INNER JOIN m1_data.element_types t ON info.elt_id = t.elt_id
    )
    -- default topo footprint
    , footprint2 AS (
      SELECT 
        2::smallint as foo_type, 
        info.elt_id as elt_id_from, 
        '-'::varchar as elt_id_to,
        t.topology as elm_proc_topology,
        m1.gen_create_footprint(
          ST_LineSubstring(
            ep.geom,
            CASE WHEN info.is_start_single THEN 0 ELSE 2 * COALESCE((t.footprint#>>'{buffer,radius}')::float, 0) / info.len END,
            CASE WHEN info.is_end_single THEN 1 ELSE 1 - 2 * COALESCE((t.footprint#>>'{buffer,radius}')::float, 0) / info.len END
          ),
          jsonb_set(
            t.footprint, '{buffer}', t.footprint->'buffer' 
            || CASE WHEN info.is_start_single THEN '{}'::jsonb ELSE '{"capstart": "triangle"}'::jsonb END
            || CASE WHEN info.is_end_single THEN '{}'::jsonb ELSE '{"capend": "triangle"}'::jsonb END
          )
        ) as geom
      FROM ep
      INNER JOIN info ON TRUE
      INNER JOIN m1_data.element_types t ON info.elt_id = t.elt_id
      WHERE 
        info.topology
        AND (CASE WHEN info.is_start_single THEN 0 ELSE 2 END + CASE WHEN info.is_end_single THEN 0 ELSE 2 END) * COALESCE((t.footprint#>>'{buffer,radius}')::float, 0) < info.len
    )
    -- special relations footprints
    , footprint3 AS (
      SELECT 
        3::smallint as foo_type, 
        info.elt_id as elt_id_from, 
        r.elt_id_to,
        t.topology as elm_proc_topology,
        m1.gen_create_footprint(ep.geom, r.footprint_from) as geom
      FROM ep
      INNER JOIN info ON TRUE
      INNER JOIN m1_data.element_types t ON info.elt_id = t.elt_id
      INNER JOIN m1_data.element_types_relations r ON info.elt_id = r.elt_id_from
      INNER JOIN m1_data.element_types tt ON tt.elt_id = r.elt_id_to
      WHERE r.footprint_from IS NOT NULL AND (NOT info.topology OR NOT tt.topology)
    )
    -- special relations topo footprints
    , footprint4 AS (
      SELECT 
        4::smallint as foo_type, 
        info.elt_id as elt_id_from, 
        r.elt_id_to,
        t.topology as elm_proc_topology,
        m1.gen_create_footprint(
          ST_LineSubstring(
            ep.geom,
            CASE WHEN info.is_start_single THEN 0 ELSE 2 * COALESCE((r.footprint_from#>>'{buffer,radius}')::float, 0) / info.len END,
            CASE WHEN info.is_end_single THEN 1 ELSE 1 - 2 * COALESCE((r.footprint_from#>>'{buffer,radius}')::float, 0) / info.len END
          ),
          jsonb_set(
            r.footprint_from, '{buffer}', r.footprint_from->'buffer' 
            || CASE WHEN info.is_start_single THEN '{}'::jsonb ELSE '{"capstart": "triangle"}'::jsonb END
            || CASE WHEN info.is_end_single THEN '{}'::jsonb ELSE '{"capend": "triangle"}'::jsonb END
          )
        ) as geom
      FROM ep
      INNER JOIN info ON TRUE
      INNER JOIN m1_data.element_types t ON info.elt_id = t.elt_id
      INNER JOIN m1_data.element_types_relations r ON info.elt_id = r.elt_id_from
      INNER JOIN m1_data.element_types tt ON tt.elt_id = r.elt_id_to
      WHERE
        r.footprint_from IS NOT NULL 
        AND info.topology AND tt.topology
        AND (CASE WHEN info.is_start_single THEN 0 ELSE 2 END + CASE WHEN info.is_end_single THEN 0 ELSE 2 END) * COALESCE((r.footprint_from#>>'{buffer,radius}')::float, 0) < info.len
    )
    SELECT * FROM footprint1
    UNION
    SELECT * FROM footprint2
    UNION
    SELECT * FROM footprint3
    UNION
    SELECT * FROM footprint4;
END;
$function$
;