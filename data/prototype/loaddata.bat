@echo off
call ../../m1/config.bat

SET PGCONN="dbname=%PGDATABASE% user=%PGUSER% password=%PGPASSWORD%"

%PGBIN%\psql -x -f ./loaddata.sql

for /R %~dp0 %%i IN (*.shp) do (
  echo %%~ni
  
  %OGRBIN%\ogr2ogr -overwrite -f PostgreSQL PG:%PGCONN% -nlt GEOMETRY -nln data.temp_elements^
  -lco OVERWRITE=YES^
  --config PG_USE_COPY YES^
  -sql "SELECT znacka as elt_id, objectid AS source_id, znacka as source_elt_id FROM %%~ni" %%i
  
  %PGBIN%\psql -x -c "INSERT INTO data.elements_in (elt_id, source_id, source_elt_id, geom) SELECT elt_id::varchar, source_id, source_elt_id::varchar, ST_SetSrid(wkb_geometry, 0) FROM data.temp_elements"
  %PGBIN%\psql -x -c "DROP TABLE data.temp_elements"

)
%PGBIN%\psql -x -c "VACUUM FULL ANALYZE data.elements_in"
%PGBIN%\psql -x -c "SELECT m1.gen_topo_update();"

