CREATE OR REPLACE FUNCTION m1.gen_element_proc_get_conflicting_footprints(aelm_proc_id integer, max_clearence double precision DEFAULT 0)
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
        epf.foo_id, epf.elm_proc_id, epf.foo_type, epf.elt_id_from, epf.elt_id_to,
        f.foo_id as conflicting_foo_id, f.elm_proc_id, f.foo_type, f.elt_id_from, f.elt_id_to,
        row_number() OVER (PARTITION BY f.elm_proc_id ORDER BY (epf.foo_type + f.foo_type) DESC) as rn
      FROM ep
      INNER JOIN data.element_footprints epf ON epf.elm_proc_id = ep.elm_proc_id
      INNER JOIN data.element_footprints f ON ST_DWithin(epf.geom, f.geom, max_clearence) 
      INNER JOIN data.element_types_relations r ON r.elt_id_from = epf.elt_id_from AND r.elt_id_to = f.elt_id_from AND r.conflict
      WHERE ep.elm_proc_id <> f.elm_proc_id
        -- foo_type (topo, nontopo) should be the same
        AND MOD(epf.foo_type, 2) = MOD(f.foo_type, 2)
        -- foo_type = 3,4 only for current element
        AND NOT (epf.foo_type IN (3,4) AND epf.elt_id_to <> f.elt_id_from)
        AND NOT (f.foo_type IN (3,4) AND f.elt_id_to <> epf.elt_id_from)
        AND NOT (epf.elm_proc_topology AND f.elm_proc_topology AND epf.foo_type IN (1,3))
        -- foo_type = 1,2 ignore if exists footprint override for element_types relation
        AND NOT (
          epf.foo_type NOT IN (3,4) 
          AND f.foo_type NOT IN (3,4)
          AND COALESCE(r.footprint_from, r.footprint_to) IS NOT NULL
        )
        -- distance by clearence
        AND ST_DWithin(epf.geom, f.geom, COALESCE(r.clearence, 0)) 
    )
    SELECT e.foo_id, e.conflicting_foo_id FROM elements e WHERE e.rn = 1;
END;
$function$
;