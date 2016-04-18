CREATE OR REPLACE FUNCTION m1.gen_create_footprint(geom geometry, params jsonb)
 RETURNS geometry
 LANGUAGE plpgsql
AS $function$
DECLARE
  footprint geometry;
  centroid geometry;
BEGIN
  footprint := geom;
  IF (params ? 'geometry') THEN
    centroid := ST_Centroid(geom);
    footprint := ST_Translate(
      COALESCE(params#>>'{geometry}', '')::geometry,
      ST_X(centroid),
      ST_Y(centroid)
    );
    IF (params ? 'origin') THEN
      footprint := ST_Translate(
        footprint, 
        -1 * COALESCE((params#>>'{origin,0}')::float, 0),
        -1 * COALESCE((params#>>'{origin,1}')::float, 0)
      );
    END IF;
    IF (params ? 'rotation') THEN
      footprint := ST_Rotate(
        footprint,
        pi() * (params#>>'{rotation}')::float / 180,
        centroid
      );
    END IF;
  END IF;
  IF (params ? 'buffer') THEN
    IF (COALESCE(params#>>'{buffer,capstart}',params#>>'{buffer,capend}') IS NOT NULL) THEN
      SELECT INTO footprint a.geom FROM (
        WITH line AS (
          SELECT geom, COALESCE((params#>>'{buffer,radius}')::float, 0) as radius
        ),
        flat AS (
          SELECT ST_Buffer(line.geom, radius, 'endcap=flat') as geom FROM line
        ),
        startBuf AS (
          SELECT a.geom FROM (
            SELECT (ST_Dump(
              ST_Difference(ST_Buffer(
                line.geom, 
                radius, 
                'endcap=' || COALESCE(CASE params#>>'{buffer,capstart}' WHEN 'triangle' THEN 'round quad_segs=1' ELSE params#>>'{buffer,capstart}' END, params#>>'{buffer,cap}', 'round')
              ), flat.geom)
            )).geom, ST_StartPoint(line.geom) as pt
            FROM line, flat
          ) a
          WHERE ST_DWithin(a.geom, a.pt, 0.0001)
        ),
        endBuf AS (
          SELECT a.geom FROM (
            SELECT (ST_Dump(
              ST_Difference(ST_Buffer(
                line.geom, 
                radius, 
                'endcap=' || COALESCE(CASE params#>>'{buffer,capend}' WHEN 'triangle' THEN 'round quad_segs=1' ELSE params#>>'{buffer,capend}' END, params#>>'{buffer,cap}', 'round')
              ), flat.geom)
            )).geom, ST_EndPoint(line.geom) as pt
            FROM line, flat
          ) a
          WHERE ST_DWithin(a.geom, a.pt, 0.0001)
        ),
        allBuf AS (
          SELECT flat.geom FROM flat
          UNION
          SELECT startBuf.geom FROM startBuf
          UNION
          SELECT endBuf.geom FROM endBuf
        )
        SELECT ST_Union(ST_Buffer(ST_SnapToGrid(allBuf.geom, 0.0001), 0)) as geom FROM allBuf
      ) a;
    ELSE
      footprint := ST_SnapToGrid(ST_Buffer(
        footprint, 
        COALESCE((params#>>'{buffer,radius}')::float, 0), 
        'endcap=' || COALESCE(CASE params#>>'{buffer,cap}' WHEN 'triangle' THEN 'round quad_segs=1' ELSE params#>>'{buffer,cap}' END, 'round')
      ), 0.0001);
    END IF;
  END IF;
  RETURN footprint;
END;
$function$
;

COMMENT ON FUNCTION m1.gen_create_footprint(geom geometry, params jsonb) IS 'Create geometry footprint using input JSON params

geom: geometry,             //required
params: {                   //required
  "geometry": "[wkt]",      //optional, wkt(polygon)
  "origin": [1.1, 1.5],     //optional, [float, float], default: [0, 0]
  "buffer": {               //optional,
    "radius": 2,            //optional, float, default: 0
    "cap": "flat",          //optional, [round|flat|square|triangle], default: round
    "capstart": "flat",     //optional, [round|flat|square|triangle], default: "cap"
    "capend": "flat"        //optional, [round|flat|square|triangle], default: "cap"
  }
},
rotation: 45                //optional, float, default: 0 (for params with wkt geometry only)

test: tests.test_create_footprint()
';