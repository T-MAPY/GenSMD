CREATE OR REPLACE FUNCTION m1.gen_create_footprint_side_dist_lines(geom geometry, params jsonb)
 RETURNS TABLE(line geometry, side character)
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN QUERY 
  WITH data AS (
    SELECT 
      COALESCE((params#>>'{buffer,radius}')::float, 0) as radius,
      CASE WHEN COALESCE(params#>>'{buffer,startcap}', params#>>'{buffer,cap}', 'round') = 'flat' THEN 0 ELSE 1 END as extstart,
      CASE WHEN COALESCE(params#>>'{buffer,endcap}', params#>>'{buffer,cap}', 'round') = 'flat' THEN 0 ELSE 1 END as extend,
      COALESCE(params#>>'{buffer,offset}', '0')::float as offset
  )
  , lines AS (
    SELECT 
      s as side, 
      ST_OffsetCurve(
        line.line, 
        d.offset + d.radius * CASE s WHEN 'l' THEN 1 ELSE -1 END,
        m1.gen_get_buffer_style_parameters(params, 'start', 'offset')
      ) as line
    FROM unnest(array['l', 'r']::bpchar[]) s, data d, m1.gen_extend_line(geom, d.radius * d.extstart, d.radius * d.extend) line
  )
  SELECT
     ST_SnapToGrid(
       CASE l.side WHEN 'l' THEN l.line ELSE ST_Reverse(l.line) END, 
       0.00001
     ), l.side
  FROM lines l;  
END;
$function$
;