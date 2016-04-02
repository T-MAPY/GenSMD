CREATE OR REPLACE FUNCTION m1.gen_create_footprint(geom geometry, params jsonb, rotation double precision DEFAULT 0)
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
    IF (rotation != 0) THEN
      footprint := ST_Rotate(
        footprint,
        pi() * rotation / 180,
        centroid
      );
    END IF;
  END IF;
  IF (params ? 'buffer') THEN
    footprint := ST_Buffer(
      footprint, 
      COALESCE((params#>>'{buffer,radius}')::float, 0), 
      'endcap=' || COALESCE(params#>>'{buffer,endcap}', 'round')
    );
  END IF;
  RETURN footprint;
END;
$function$
;

COMMENT ON FUNCTION m1.gen_create_footprint(geom geometry, params jsonb, rotation double precision) IS 'Create geometry footprint using input JSON params

geom: geometry,             //required
params: {                   //required
  "geometry": "[wkt]",      //optional, wkt(polygon)
  "origin": [1.1, 1.5],     //optional, [float, float], default: [0, 0]
  "buffer": {               //optional,
    "radius": 2,            //optional, float, default: 0
    "endcap": "flat"        //optional, [round|flat|square], defaul: round
  }
},
rotation: 45                //optional, float, default: 0 (for params with wkt geometry only)

test: tests.test_create_footprint()
';