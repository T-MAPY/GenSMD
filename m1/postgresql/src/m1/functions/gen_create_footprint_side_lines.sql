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
      SELECT o.offset, o.direction, (SELECT ST_Union(ST_Collect(ST_StartPoint((dmp).geom), ST_EndPoint((dmp).geom))) FROM ST_Dump(o.offset) dmp) as endpoint
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
    , startend AS (
      SELECT 
        CASE h1.captype WHEN 'ext' THEN ST_Difference(h1.half, b.buff) ELSE h1.half END as start, 
        CASE h2.captype WHEN 'ext' THEN ST_Difference(h2.half, b.buff) ELSE h2.half END as end, 
        o.*
      FROM offsets o
      CROSS JOIN (SELECT ST_Union(ST_Buffer(buff, -0.00001)) as buff FROM buffs) b 
      LEFT JOIN halfs h1 ON (ST_DWithin(o.endpoint, h1.half, 0.00001) AND h1.id = 'b')
      LEFT JOIN halfs h2 ON (ST_DWithin(o.endpoint, h2.half, 0.00001) AND h2.id = 'e')
    )
    , lines AS (
      SELECT 1 as part, s.offset as line, s.direction FROM startend s
      UNION
      SELECT 2 as part, CASE WHEN ST_DWithin(s.offset, ST_StartPoint(s.start), 0.00001) THEN ST_Reverse(s.start) ELSE s.start END, s.direction FROM startend s WHERE s.start IS NOT NULL
      UNION
      SELECT 3 as part, s.end, s.direction FROM startend s WHERE s.end IS NOT NULL
    )
    --SELECT t.half,id::bpchar FROM halfs t;
    SELECT ST_LineMerge(ST_SnapToGrid(ST_Union(l.line), 0.0001)), direction
    FROM lines l 
    GROUP BY direction;

END;
$function$
;