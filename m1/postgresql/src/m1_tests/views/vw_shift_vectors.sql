CREATE OR REPLACE VIEW m1_tests.vw_shift_vectors AS
 WITH data AS (
         SELECT st_geometryfromtext('LINESTRING(0 2,4 2,4.5 3,5.5 2,20 0)'::text) AS refgeom,
            'l'::bpchar AS refside,
            0.5 AS refradius,
            st_geometryfromtext('LINESTRING(8 -10,2 10)'::text) AS shiftgeom,
            'r'::bpchar AS shiftside,
            1 AS shiftradius,
            1::double precision AS maxsegmentdistance
        ), refoffset AS (
         SELECT l.line
           FROM data,
            LATERAL m1.gen_create_footprint_side_dist_lines(data.refgeom, (('{"buffer": {"cap": "round", "radius": '::text || (data.refradius + data.shiftradius::numeric)) || '}}'::text)::jsonb) l(line, side)
          WHERE l.side = data.refside
        ), refoffset2 AS (
         SELECT l.line
           FROM data
             CROSS JOIN LATERAL m1.gen_create_footprint_side_dist_lines(data.refgeom, (('{"buffer": {"cap": "round", "radius": '::text || data.refradius) || '}}'::text)::jsonb) l(line, side)
          WHERE l.side = data.refside
        ), refsidezone AS (
         SELECT m1.gen_create_buffer_one_side_flat(refoffset.line, (
                CASE data.refside
                    WHEN 'l'::bpchar THEN '-1'::integer
                    ELSE 1
                END * 50)::double precision) AS zone
           FROM refoffset,
            data
        ), shiftvectors AS (
         SELECT t_1.vector
           FROM ( SELECT m1.gen_get_shift_vectors(refoffset.line, refsidezone.zone, data.shiftgeom, data.maxsegmentdistance) AS vector
                   FROM data,
                    refoffset,
                    refsidezone) t_1
        ), shiftline AS (
         SELECT m1.gen_apply_shift_vectors(data.shiftgeom, ( SELECT array_agg(shiftvectors.vector) AS array_agg
                   FROM shiftvectors), '{}'::jsonb) AS line
           FROM data
        ), shiftfoot AS (
         SELECT m1.gen_create_footprint(shiftline.line, (('{"buffer": {"cap": "round", "radius": '::text || data.shiftradius) || '}}'::text)::jsonb) AS line
           FROM shiftline,
            data
        )
 SELECT row_number() OVER () AS id,
    t.type,
    t.geom
   FROM ( SELECT 'ref'::text AS type,
            data.refgeom AS geom
           FROM data
        UNION
         SELECT 'shift'::text AS type,
            data.shiftgeom AS geom
           FROM data
        UNION
         SELECT 'refOffset'::text AS type,
            refoffset.line AS geom
           FROM refoffset
        UNION
         SELECT 'refOffset'::text AS type,
            refoffset2.line AS geom
           FROM refoffset2
        UNION
         SELECT 'vectors'::text AS type,
            shiftvectors.vector AS geom
           FROM shiftvectors
        UNION
         SELECT 'shifted'::text AS type,
            shiftline.line AS geom
           FROM shiftline
        UNION
         SELECT 'shiftedFootprint'::text AS type,
            st_exteriorring((st_dump(shiftfoot.line)).geom) AS geom
           FROM shiftfoot
        UNION
         SELECT 'refsidezone'::text AS type,
            st_exteriorring((st_dump(refsidezone.zone)).geom) AS geom
           FROM refsidezone) t;;