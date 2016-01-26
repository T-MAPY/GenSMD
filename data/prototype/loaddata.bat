@echo off
call ../../m1/config.bat
SET PGCONN="dbname=%PGDATABASE% user=%PGUSER% password=%PGPASSWORD%"
%OGRBIN%\ogrinfo -ro PG:%PGCONN% -sql "TRUNCATE data.features"
for /R %~dp0 %%i IN (*.shp) do (
  echo %%~ni
  
  %OGRBIN%\ogr2ogr -overwrite -f PostgreSQL PG:%PGCONN% -nlt GEOMETRY -nln data.temp_features^
  -lco OVERWRITE=YES^
  --config PG_USE_COPY YES^
  -sql "SELECT objectid AS feature_id, '%%~ni' as src_tbl, objectid as src_id, znacka as symbol FROM %%~ni" %%i
  
  %OGRBIN%\ogrinfo -ro PG:%PGCONN%^
  -sql "INSERT INTO data.features (feature_id, src_tbl, src_id, symbol, geom) SELECT feature_id, src_tbl, src_id, symbol, ST_SetSrid(wkb_geometry, 0) FROM data.temp_features"
  
  %OGRBIN%\ogrinfo -ro PG:%PGCONN%^
  -sql "DROP TABLE data.temp_features"
  
)

