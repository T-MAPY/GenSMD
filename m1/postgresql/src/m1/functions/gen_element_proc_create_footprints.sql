CREATE OR REPLACE FUNCTION m1.gen_element_proc_create_footprints(aelm_proc_id integer)
 RETURNS TABLE(source_type smallint, source_elt_id character varying, target_elt_id character varying, footprint geometry)
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN QUERY

    WITH ep AS (
      SELECT * FROM data.elements_proc WHERE elm_proc_id = aelm_proc_id
    )
    , info AS (
      SELECT DISTINCT elt_id, len, topology_participant, is_start_single, is_end_single 
      FROM m1.gen_element_proc_get_info((SELECT elm_proc_id FROM ep))
    )
    , footprint1 AS (
      SELECT 
        1::smallint as source_type, 
        info.elt_id as source_elt_id, 
        '-'::varchar as target_elt_id,
        m1.gen_create_footprint(ep.geom, t.footprint_params) as footprint
      FROM ep
      INNER JOIN info ON TRUE
      INNER JOIN data.element_types t ON info.elt_id = t.elt_id
    )
    , footprint2 AS (
      SELECT 
        2::smallint as source_type, 
        info.elt_id as source_elt_id, 
        '-'::varchar as target_elt_id,
        m1.gen_create_footprint(
          ST_Line_Substring(
            ep.geom,
            CASE WHEN info.is_start_single THEN 0 ELSE 2 * COALESCE((t.footprint_params#>>'{buffer,radius}')::float, 0) / info.len END,
            CASE WHEN info.is_end_single THEN 1 ELSE 1 - 2 * COALESCE((t.footprint_params#>>'{buffer,radius}')::float, 0) / info.len END
          ),
          jsonb_set(
            footprint_params, '{buffer}', footprint_params->'buffer' 
            || CASE WHEN info.is_start_single THEN '{}'::jsonb ELSE '{"capstart": "triangle"}'::jsonb END
            || CASE WHEN info.is_end_single THEN '{}'::jsonb ELSE '{"capend": "triangle"}'::jsonb END
          )
        ) as footprint
      FROM ep
      INNER JOIN info ON TRUE
      INNER JOIN data.element_types t ON info.elt_id = t.elt_id
      WHERE 
        info.topology_participant
        AND (CASE WHEN info.is_start_single THEN 0 ELSE 2 END + CASE WHEN info.is_end_single THEN 0 ELSE 2 END) * COALESCE((t.footprint_params#>>'{buffer,radius}')::float, 0) < info.len
    )
    , footprint3 AS (
      SELECT 
        3::smallint as source_type, 
        info.elt_id as source_elt_id, 
        ov as target_elt_id,
        m1.gen_create_footprint(ep.geom,  m1.gen_json_get_override(t.footprint_params, 'buffer', ov)) as footprint
      FROM ep
      INNER JOIN info ON TRUE
      INNER JOIN data.element_types t ON info.elt_id = t.elt_id
      INNER JOIN jsonb_object_keys(t.footprint_params->'overrides') ov ON TRUE
      INNER JOIN data.element_types tt ON tt.elt_id = ov
      WHERE NOT info.topology_participant OR NOT tt.topology_participant
    )
    , footprint3t AS (
      SELECT 
        3::smallint as source_type, 
        elt_id as source_elt_id, 
        ov as target_elt_id,
        m1.gen_create_footprint(
          ST_Line_Substring(
            a.geom,
            CASE WHEN is_start_single THEN 0 ELSE 2 * COALESCE((footprint_params#>>'{buffer,radius}')::float, 0) / len END,
            CASE WHEN is_end_single THEN 1 ELSE 1 - 2 * COALESCE((footprint_params#>>'{buffer,radius}')::float, 0) / len END
          ),
          jsonb_set(
            footprint_params, '{buffer}', footprint_params->'buffer' 
            || CASE WHEN is_start_single THEN '{}'::jsonb ELSE '{"capstart": "triangle"}'::jsonb END
            || CASE WHEN is_end_single THEN '{}'::jsonb ELSE '{"capend": "triangle"}'::jsonb END
          )
        ) as footprint
      FROM (
        SELECT info.*, ep.geom, m1.gen_json_get_override(t.footprint_params, 'buffer', ov) as footprint_params, ov
        FROM ep
        INNER JOIN info ON TRUE
        INNER JOIN data.element_types t ON info.elt_id = t.elt_id
        INNER JOIN jsonb_object_keys(t.footprint_params->'overrides') ov ON TRUE
        INNER JOIN data.element_types tt ON tt.elt_id = ov
        WHERE 
          info.topology_participant AND tt.topology_participant
          AND (CASE WHEN info.is_start_single THEN 0 ELSE 2 END + CASE WHEN info.is_end_single THEN 0 ELSE 2 END) * COALESCE((t.footprint_params#>>'{buffer,radius}')::float, 0) < info.len
      ) a
    )
    SELECT * FROM footprint1
    UNION
    SELECT * FROM footprint2
    UNION
    SELECT * FROM footprint3
    UNION
    SELECT * FROM footprint3t;
END;
$function$
;