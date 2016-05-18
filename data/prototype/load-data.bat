@echo off
call %~dp0../../admin/config.bat

SET PGCONN="dbname=%PGDATABASE% user=%PGUSER% password=%PGPASSWORD%"

%PGBIN%\psql -x -c "TRUNCATE data.elements CASCADE;"
%PGBIN%\psql -x -c "ALTER SEQUENCE data.elements_elm_id_seq RESTART WITH 1;"

for /R %~dp0\shp %%i IN (*.shp) do (
  echo %%~ni
  
  %OGRBIN%\ogr2ogr -overwrite -f PostgreSQL PG:%PGCONN% -nlt GEOMETRY -nln data.temp_elements^
  -lco OVERWRITE=YES^
  --config PG_USE_COPY YES^
  -sql "SELECT objectid AS id, znacka as elt_id FROM %%~ni" %%i
  
  %PGBIN%\psql -x -c "INSERT INTO data.elements (source_id, source_elt_id, source_geom, target_elt_id, target_geom) SELECT id::varchar, elt_id::varchar, ST_SetSrid(wkb_geometry, 0), elt_id::varchar, ST_SetSrid(wkb_geometry, 0) FROM data.temp_elements"
  %PGBIN%\psql -x -c "DROP TABLE data.temp_elements"

)
%PGBIN%\psql -x -c "VACUUM FULL ANALYZE data.elements"

