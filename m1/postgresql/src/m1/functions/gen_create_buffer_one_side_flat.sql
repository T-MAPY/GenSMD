CREATE OR REPLACE FUNCTION m1.gen_create_buffer_one_side_flat(geom geometry, radius double precision, params text DEFAULT ''::text)
 RETURNS geometry
 LANGUAGE plpgsql
 STRICT
AS $function$
DECLARE
  result geometry;
  halfradius double precision := radius / 2;
  absradius double precision := abs(radius);
  angle double precision;
  angleper double precision;
  r record;
  numpts integer := ST_NumPoints(geom);
  side bpchar := CASE WHEN radius > 0 THEN 'l' ELSE 'r' END;
  geomext geometry;
  geomoff geometry;
  buff geometry;
  halfpi double precision := pi() / 2;
  linelenngth double precision;
  line geometry;
  lines geometry[];
  lineoff geometry;
  perc double precision; 
  poly geometry;
BEGIN
  IF (NOT ST_IsValid(geom) OR radius = 0) THEN
    result := null;
  ELSIF (numpts = 2) THEN
    result := ST_Buffer(ST_OffsetCurve(geom, halfradius), abs(halfradius), 'endcap=flat');
  ELSE
    linelenngth := ST_Length(geom);
    -- extend line by perpendicular end segments for clipping
    SELECT INTO geomext ST_SnapToGrid(ST_MakeLine(t.lnper), 0.00001) FROM (
      WITH data AS (
        SELECT 1 as p1, 2 as p2, 1 as pe
        UNION
        SELECT numpts - 1, numpts, numpts
      )
      , angles AS (
        SELECT t.*, t.angle + CASE side WHEN 'l' THEN halfpi ELSE -halfpi END as angleper FROM (
          SELECT t.*, ST_Azimuth(pt1, pt2) as angle 
          FROM (
            SELECT p1, p2, ST_PointN(geom, p1) as pt1, ST_PointN(geom, p2) as pt2, ST_PointN(geom, pe) as pte FROM data
          ) t
        ) t
      )
      , points AS (
        SELECT 
          *, 
          ST_Translate(pte, sin(t.angleper) * (absradius + linelenngth + 1), cos(t.angleper) * (absradius + linelenngth + 1)) as ptel,
          ST_Translate(pte, sin(t.angleper + pi()) * (absradius + linelenngth + 1), cos(t.angleper + pi()) * (absradius + linelenngth + 1)) as pter
        FROM angles t
      )
      , endlines AS (
        SELECT *, (SELECT ST_LineMerge(ST_Union((dmp).geom)) as lnper FROM ST_Dump(ST_Split(ST_MakeLine(ptel, pter), geom)) dmp WHERE ST_DWithin((dmp).geom, pte, 0.00001)) as lnper 
        FROM points t
      )
      SELECT 1 as id, lnper FROM endlines WHERE p1 = 1
      UNION
      SELECT 2, ST_MakeLine(ST_EndPoint(lnper), pte) FROM endlines WHERE p1 = 1
      UNION
      SELECT 3, geom
      UNION
      SELECT 4, ST_MakeLine(pte, ST_EndPoint(lnper)) FROM endlines WHERE p1 > 1
      UNION
      SELECT 5, lnper FROM endlines WHERE p1 > 1
      ORDER BY id
    ) t;
    --RAISE NOTICE '%', ST_AsTExt(geomext);

    -- offset line for splitted buffer parts selection
    geomoff := ST_OffsetCurve(geom, CASE side WHEN 'r' THEN 0.0001 ELSE -0.0001 END);
    perc := 0.001 / ST_Length(geomoff);
    geomoff := ST_LineSubstring(geomoff, perc, 1 - perc);

    -- for each three points
    FOR r IN 
      SELECT
        num,
        ST_PointN(geom, num) as pt1,
        ST_PointN(geom, num + 1) as pt2,
        ST_PointN(geom, num + 2) as pt3
      FROM generate_series(1, numpts - 2) num
    LOOP
      angle := m1.gen_get_three_points_angle(r.pt1, r.pt2, r.pt3, side);
      
      -- angle 0 - no buffer
      IF (angle = 0) THEN
        CONTINUE;
      END IF;
      
      -- convex angle <= 180 - two separate buffers for segments
      IF (angle <= pi()) THEN
        lines := array[ST_MakeLine(r.pt1, r.pt2), ST_MakeLine(r.pt2, r.pt3)];
      -- nonconvex angle > 180 - one buffer for whole line
      ELSE
        lines := array[ST_MakeLine(array[r.pt1, r.pt2, r.pt3])];
        IF (r.num IN (1, numpts)) THEN
          lines := lines || array[ST_MakeLine(r.pt1, r.pt2)];
        END IF;
      END IF;

      -- loop on lines 
      -- 1. create one side buffer using offset and offset curve for selection (lineoff)
      -- 2. split in by geomext
      -- 3. select right parts using lineoff and geomoff
      -- 4. add to result
      FOREACH line IN ARRAY lines
      LOOP
        buff := ST_SnapToGrid(ST_Buffer(line, abs(radius), params || ' endcap=flat'), 0.00001);
        lineoff := ST_OffsetCurve(line, CASE side WHEN 'l' THEN 0.00001 ELSE -0.00001 END);
        perc := 0.001 / ST_Length(lineoff);
        lineoff := ST_LineSubstring(lineoff, perc, 1 - perc);
        
        SELECT INTO poly ST_SnapToGrid(ST_Union(t.geom), 0.00001)
        FROM (
          SELECT (ST_Dump(ST_Split(buff, geomext))).geom
        ) t
        WHERE NOT ST_Intersects(t.geom, geomoff) AND ST_Intersects(t.geom, lineoff);
        
        poly := ST_Buffer(poly, 0.0001);
        IF (poly IS NOT NULL) THEN
          result := COALESCE(ST_Union(result, poly), poly);
        END IF;
      END LOOP;
      
    END LOOP;

  END IF;

  RETURN ST_Simplify(result, 0.00001);
END;
$function$
;