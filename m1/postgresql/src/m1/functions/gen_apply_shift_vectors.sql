CREATE OR REPLACE FUNCTION m1.gen_apply_shift_vectors(geom geometry, shiftvectors geometry[], params jsonb)
 RETURNS geometry
 LANGUAGE plpgsql
AS $function$
BEGIN
  -- interpolate all points
  RETURN (
  WITH data AS (
    SELECT 
--       'LINESTRING(0 0, 10 0, 10 10)'::geometry as geom,
--       array['LINESTRING(0 0, 2 10)'::geometry, 'LINESTRING(1 1, 2 5)'::geometry, 'LINESTRING(5 1, 4 8)'::geometry]::geometry[] as vectors
     geom as geom,
     shiftvectors as vectors
  ),
  mdata AS (
    SELECT ST_AddMeasure(d.geom, 0, ST_Length(d.geom)) as mgeom FROM data d
  )
  , vertices AS (  
    SELECT (ST_DumpPoints(mgeom)).geom as pt FROM mdata
  )
  , vectordxdy AS (
    SELECT 
      ST_InterpolatePoint(mgeom, ptstart) as measure, 
      ST_X(ptend) - ST_X(ptstart) as dx,
      ST_Y(ptend) - ST_Y(ptstart) as dy,
      ptstart
    FROM (
      SELECT mgeom, ST_StartPoint(vect.vect) as ptstart, ST_EndPoint(vect.vect) as ptend 
      FROM mdata, (SELECT unnest(vectors) as vect FROM data) vect
    ) t
  )
  , measures AS (
    SELECT measure, dx, dy, sqrt(pow(dx,2) + pow(dy, 2)) as dv, ptstart
    FROM vectordxdy
    UNION 
    SELECT ST_M(pt), 0, 0, 0, pt FROM vertices
    ORDER BY measure
  )
  , measuresgrouped AS ( 
    SELECT * FROM (
      SELECT 
        measure, dx, dy, ptstart, row_number() OVER (PARTITION BY round(measure::numeric, 5) ORDER BY dv DESC) as rn
      FROM measures
    ) t
    WHERE rn = 1
  )
  , pts AS (
    SELECT 
      ST_Azimuth(ptstart, ptgeom) as azgeom, 
      ST_Azimuth(ST_MakePoint(0,0), ST_MakePoint(dx, dy)) as azvect,
      ST_Distance(ptgeom, ptstart) as ds,
      dx, dy, measure, ptgeom
    FROM (
      SELECT (ST_Dump(ST_LocateAlong(mgeom, measure))).geom as ptgeom, measure, dx, dy, ptstart FROM measuresgrouped, mdata
    ) t
  )
  SELECT
    ST_RemoveRepeatedPoints(ST_Force2D(ST_MakeLine(array_agg(ST_Translate(ptgeom, dx + COALESCE(dsadd * sin(azvect), 0), dy + COALESCE(dsadd * cos(azvect), 0)) ORDER BY measure))))
  FROM (
    SELECT 
      measure, ptgeom, dx, dy, azvect, azgeom, ds * (1 - cos(azgeom - azvect)) as dsadd, ds 
    FROM pts
  ) t

  );
  
--  RETURN null;
END;
$function$
;