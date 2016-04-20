CREATE OR REPLACE FUNCTION m1.gen_element_proc_get_conflicting_footprints(aelm_proc_id integer, clearance_distance double precision DEFAULT 0)
 RETURNS TABLE(foo_id integer, conflicting_foo_id integer)
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN QUERY
    WITH ep AS (
      SELECT * FROM data.elements_proc ep WHERE ep.elm_proc_id = aelm_proc_id
    )
    , elements AS (
      SELECT 
        epf.foo_id, epf.elm_proc_id, epf.source_type, epf.source_elt_id, epf.target_elt_id,
        f.foo_id as conflicting_foo_id, f.elm_proc_id, f.source_type, f.source_elt_id, f.target_elt_id,
        row_number() OVER (PARTITION BY f.elm_proc_id ORDER BY (epf.source_type + f.source_type) DESC) as rn
      FROM ep
      INNER JOIN data.element_footprints epf ON epf.elm_proc_id = ep.elm_proc_id
      INNER JOIN data.element_footprints f ON 
        ST_DWithin(epf.footprint, f.footprint, clearance_distance) 
        AND ST_DWithin(
          epf.footprint, 
          f.footprint, 
          CASE epf.source_clearance_category WHEN f.source_clearance_category THEN clearance_distance ELSE 0 END
        )
      WHERE ep.elm_proc_id <> f.elm_proc_id
        -- source_type (topo, nontopo) should be the same
        AND MOD(epf.source_type, 2) = MOD(f.source_type, 2)
        -- source_type = 3,4 only for current element
        AND NOT (epf.source_type IN (3,4) AND epf.target_elt_id <> f.source_elt_id)
        AND NOT (f.source_type IN (3,4) AND f.target_elt_id <> epf.source_elt_id)
        AND NOT (epf.source_topology_participant AND f.source_topology_participant AND epf.source_type IN (1,3))
        -- source_type = 1 ignore for footprint overrides
        AND NOT (
          epf.source_type NOT IN (3,4) 
          AND f.source_type NOT IN (3,4)
          AND array[f.source_elt_id, epf.source_elt_id] && (SELECT array_agg(elt_id) FROM m1.gen_element_type_get_footprint_overrides(epf.source_elt_id, true))
        )
    )
    SELECT e.foo_id, e.conflicting_foo_id FROM elements e WHERE e.rn = 1;
END;
$function$
;