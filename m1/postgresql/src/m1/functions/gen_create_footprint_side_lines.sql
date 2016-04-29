CREATE OR REPLACE FUNCTION m1.gen_create_footprint_side_lines(geom geometry, params jsonb, footprint geometry DEFAULT NULL::geometry)
 RETURNS TABLE(line geometry, side character)
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN QUERY
    WITH data AS (
      SELECT 
        t.line, 
        ST_NumPoints(t.line) as numpts, 
        t.params, 
        COALESCE(jsonb_extract_path_text(t.params, 'buffer', 'radius')::float, 0) as radius,
        ST_Buffer(COALESCE(footprint, m1.gen_create_footprint(t.line, t.params)), -0.01) as internalmask
      FROM (
        --SELECT 'LINESTRING(0 0,0.5 0,10 0)'::geometry as line, '{"buffer":{"cap":"round"}}'::jsonb as params
        SELECT geom as line, params
      ) t
    )
    , offsets AS (
      SELECT 
        o.offset, 
        o.direction 
      FROM (
        SELECT 
          ST_Difference(o.offset, d.internalmask) as offset, 
          direction 
        FROM (
          SELECT ST_OffsetCurve(d.line, d.radius, m1.gen_get_buffer_style_parameters(d.params, 'start', 'offset')) as offset, 'l'::bpchar as direction FROM data d
          UNION
          SELECT ST_Reverse(ST_OffsetCurve(d.line, -d.radius, m1.gen_get_buffer_style_parameters(d.params, 'start', 'offset'))) as offset, 'r'::bpchar as direction FROM data d
        ) o, data d
      ) o
    )
    , parts AS (
      SELECT  
        id, ST_MakeLine(ST_PointN(d.line, n.n1), ST_PointN(d.line, n.n2)) as part, ST_PointN(d.line, n.n1) as pt, buffstyle
      FROM data d, (
        SELECT 'b'::bpchar as id, 1 as n1, 2 as n2, m1.gen_get_buffer_style_parameters(d.params, 'start') as buffstyle FROM data d
        UNION 
        SELECT 'e'::bpchar as id, numpts, numpts - 1, m1.gen_get_buffer_style_parameters(d.params, 'end') as buffstyle FROM data d
      ) n
    )
    , buffs  AS (
      SELECT 
        ST_SnapToGrid(ST_Buffer(p.part, 1, 'endcap=flat'), 0.00001) as flat, 
        ST_SnapToGrid(ST_Buffer(p.part, 1, buffstyle), 0.00001) as buff,
        pt, id
      FROM parts p
    )
    , extcaps AS (
      SELECT cap, id FROM (
        SELECT 
          *,  
          row_number() OVER (PARTITION BY id ORDER BY ST_Distance(cap, pt)) as rn
        FROM (
          SELECT 
            (ST_Dump((ST_Difference(ST_ExteriorRing(buff), flat)))).geom as cap, pt, id
          FROM buffs
        ) t
      ) t
      WHERE rn = 1
    )
    , caps AS (
      SELECT cap, id, 'ext' as captype FROM extcaps
      UNION
      SELECT ST_MakeLine(
        ST_Translate(pt, sin(az) * d.radius, cos(az) * d.radius),
        ST_Translate(pt, sin(az) * -d.radius, cos(az) * -d.radius)
      ), id, 'flat' as captype
      FROM (
        SELECT id, pt, ST_Azimuth(ST_StartPoint(part), ST_EndPoint(part)) + pi() / 2 as az FROM parts
      ) t, data d
      WHERE 
        id NOT IN (SELECT id FROM extcaps)
    )
    , halfs AS (
      SELECT ST_LineSubstring(cap, 0, 0.5) as half, id, captype FROM caps
      UNION
      SELECT ST_LineSubstring(cap, 0.5, 1) as half, id, captype FROM caps
    )
    , offsetdmp AS (
      SELECT direction, (ST_Dump(o.offset)).geom
      FROM offsets o
    )
    , offsetstartend AS (
      SELECT 
        direction, 
        o.geom, 
        CASE WHEN ST_Dwithin(ST_StartPoint(o.geom), ST_StartPoint(h1.half), 0.00001) THEN ST_Reverse(h1.half) ELSE h1.half END as halfstart,
        CASE WHEN ST_Dwithin(ST_EndPoint(o.geom), ST_EndPoint(h2.half), 0.00001) THEN ST_Reverse(h2.half) ELSE h2.half END as halfend
      FROM offsetdmp o
      LEFT JOIN halfs h1 ON (ST_DWithin(ST_StartPoint(o.geom), h1.half, 0.00001) AND h1.id = 'b')
      LEFT JOIN halfs h2 ON (ST_DWithin(ST_EndPoint(o.geom), h2.half, 0.00001) AND h2.id = 'e')
    )
    SELECT
      ST_Union((COALESCE(
        ST_LineMerge(ST_Collect(array[halfstart, o.geom, CASE WHEN ST_Equals(halfstart, halfend) THEN null ELSE halfend END])),
        o.geom
      ))),
      direction
    FROM offsetstartend o
    GROUP BY direction;


END;
$function$
;