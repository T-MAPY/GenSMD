CREATE OR REPLACE FUNCTION m1.gen_get_shift_vectors(refgeom geometry, refsidezone geometry, shiftgeom geometry, maxsegmentdistance double precision DEFAULT NULL::double precision, checkingdistance double precision DEFAULT 10)
 RETURNS TABLE(vector geometry)
 LANGUAGE plpgsql
AS $function$
DECLARE
  r record;
  rpt record;
  rmeta record;
  rvect record;
  vect geometry;
  mrefgeom geometry := ST_AddMeasure(refgeom, 0, 1);
  intersection geometry;
  intersectionpart geometry;
  loc double precision;
  locindex integer;
  locdata jsonb;
  mshiftend float;
BEGIN
  intersection := ST_Intersection(shiftgeom, refsidezone);

  FOR intersectionpart IN SELECT t.geom FROM (SELECT (ST_Dump(intersection)).geom) t WHERE ST_GeometryType(t.geom) = 'ST_LineString'
  LOOP
    --RAISE NOTICE '%', ST_AsTExt(intersectionpart);

    locdata := '[]'::jsonb;
    locindex := 1;

    -- shiftgeom to refgeom vectors
    FOR rpt IN SELECT (t.dmp).path[1] as id, (t.dmp).geom
      FROM (
        SELECT
          ST_DumpPoints(
            CASE WHEN maxsegmentdistance IS NULL 
            THEN intersectionpart 
            ELSE ST_Segmentize(intersectionpart, maxsegmentdistance) 
            END
          ) as dmp
        ) t
      --ORDER BY (t.dmp).path[1]
    LOOP
      loc := ST_LineLocatePoint(refgeom, rpt.geom);
      vect := ST_SnapToGrid(ST_MakeLine(rpt.geom, ST_LineInterpolatePoint(refgeom, loc)), 0.00001);
      locdata := locdata || jsonb_build_object(
        'id', rpt.id,
        'mref', loc,
        'mshift', ST_LineLocatePoint(intersectionpart, rpt.geom),
        'len', ST_Length(vect)
      );
      RETURN QUERY SELECT vect WHERE ST_Length(vect) > 0.000001
      ;
    END LOOP;

    SELECT INTO rmeta 
      min(mref) as minmref, max(mref) as maxmref, array_agg(mref ORDER BY mref) locref 
    FROM (SELECT DISTINCT * FROM jsonb_to_recordset(locdata) as x(mref float)) t;

    -- add refgeom vertices
    -- for each refgeom part
    FOR r IN 
      SELECT ST_M((dmp).geom) as measure, ST_Force2D((dmp).geom) as geom 
      FROM (
        SELECT (ST_DumpPoints(mrefgeom)) as dmp
      ) t
      WHERE ST_M((dmp).geom) > rmeta.minmref AND ST_M((dmp).geom) < rmeta.maxmref
      ORDER BY (dmp).path[1]
    LOOP

      -- find first current vector with measure >= refgeom vertex
      WHILE (r.measure >= rmeta.locref[locindex]) LOOP
        locindex := locindex + 1;
      END LOOP;

      IF (r.measure - rmeta.locref[locindex-1] > 0.0000001 AND rmeta.locref[locindex] - r.measure > 0.0000001) THEN

        -- get border vectors between ref vertices which are closest
        WITH data AS (
          SELECT * 
          FROM jsonb_to_recordset(locdata) as x(id integer, mref float, mshift float, len float)
          WHERE mref IN (rmeta.locref[locindex], rmeta.locref[locindex-1])
        )
        , mstart AS (
          SELECT * FROM (
            SELECT *, min(mshift) OVER () as minmshift, max(mshift) OVER () as maxmshift
            FROM data WHERE mref = rmeta.locref[locindex-1]
          ) t
          WHERE mshift IN (minmshift, maxmshift)
        )
        , mend AS (
          SELECT * FROM (
            SELECT *, min(mshift) OVER () as minmshift, max(mshift) OVER () as maxmshift
            FROM data WHERE mref = rmeta.locref[locindex]
          ) t
          WHERE mshift IN (minmshift, maxmshift)
        )
        SELECT INTO rvect * FROM (
          SELECT 
            mstart.id as mstartid,
            mend.id as mendid,
            mstart.mshift as mstartmshift,
            mend.mshift as mendmshift,
            CASE WHEN mstart.len >= mend.len THEN mstart.id ELSE mend.id END as longvectid,
            CASE WHEN mstart.len >= mend.len THEN mstart.mshift ELSE mend.mshift END as longvectshift,
            CASE WHEN mstart.len >= mend.len THEN mstart.mref ELSE mend.mref END as longvectref
          FROM mstart, mend
          ORDER BY abs(mend.mshift - mstart.mshift)
          LIMIT 1
        ) t;

        -- get segment end for proportional distance calculation (on the side with longer vector)
        SELECT INTO mshiftend 
          mshift
        FROM jsonb_to_recordset(locdata) as x(id integer, mshift float)
        WHERE 
          id = CASE WHEN rvect.longvectid = rvect.mstartid 
               THEN rvect.mstartid + CASE WHEN rvect.mendid > rvect.mstartid THEN 1 ELSE -1 END
               ELSE rvect.mendid + CASE WHEN rvect.mendid > rvect.mstartid THEN -1 ELSE 1 END
               END;
          
        RAISE NOTICE '%, %', rvect, rvect.longvectshift + (mshiftend - rvect.longvectshift) * abs(r.measure - rmeta.locref[locindex-1])/abs(rmeta.locref[locindex] - rmeta.locref[locindex-1]);

        -- create vector for vertex on refgeom, start point is calculated on proportional distance on shiftgeom between nearby vectors
        RETURN QUERY SELECT ST_SnapToGrid(t.vector, 0.00001) FROM (
          SELECT ST_MakeLine(
            ST_LineInterpolatePoint(
              intersectionpart, 
              rvect.longvectshift
                + (mshiftend - rvect.longvectshift) 
                * (abs(
                  CASE WHEN rmeta.locref[locindex] - rvect.longvectref < 0.00001 THEN 1 ELSE 0 END 
                  - abs((r.measure - rmeta.locref[locindex-1])/(rmeta.locref[locindex] - rmeta.locref[locindex-1])))
                  )
            ),
            r.geom
          ) as vector
        ) t WHERE ST_Length(t.vector) > 0.000001;
      
      END IF;
    END LOOP;
  END LOOP;

END;
$function$
;