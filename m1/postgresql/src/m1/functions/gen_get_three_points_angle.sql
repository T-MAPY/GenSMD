CREATE OR REPLACE FUNCTION m1.gen_get_three_points_angle(pt1 geometry, pt2 geometry, pt3 geometry, side character)
 RETURNS double precision
 LANGUAGE plpgsql
AS $function$
DECLARE
  az1 double precision;
  az2 double precision;
  angle double precision; 
BEGIN
  az1 := ST_Azimuth(pt2, pt1);
  az2 := ST_Azimuth(pt2, pt3);
  
  angle := CASE side WHEN 'r' THEN az1 - az2 ELSE az2 - az1 END;
  angle := CASE WHEN angle < 0 THEN angle + 2 * pi() ELSE angle END;
  
  RETURN angle;
END;
$function$
;