CREATE OR REPLACE FUNCTION m1.gen_get_geometry_relationship_side(refgeom geometry, geom geometry, checkingdistance double precision DEFAULT 10)
 RETURNS character
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN (WITH buffs AS (
    SELECT ST_Buffer(ST_OffsetCurve(refgeom, checkingdistance / 2), checkingdistance / 2, 'endcap=flat') as buff, 'l'::character as side
    UNION
    SELECT ST_Buffer(ST_OffsetCurve(refgeom, checkingdistance / -2), checkingdistance / 2, 'endcap=flat') as buff, 'r'::character as side
  )
  , related AS (
    SELECT array_agg(side) as rel FROM buffs WHERE ST_Relate(buff, geom, 'T********')
  )
  SELECT 
    CASE WHEN array_length(rel, 1) > 1 
    THEN 'b'
    ELSE
      CASE WHEN array_length(rel, 1) = 1
      THEN rel[1]
      ELSE null
      END
    END
  FROM related);
END;
$function$
;