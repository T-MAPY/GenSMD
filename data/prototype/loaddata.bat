@echo off
call ../../m1/config.bat
SET PGCONN="dbname=%PGDATABASE% user=%PGUSER% password=%PGPASSWORD%"

%OGRBIN%\ogrinfo -ro PG:%PGCONN% -sql "TRUNCATE data.element_types CASCADE"
%OGRBIN%\ogrinfo -ro PG:%PGCONN% -sql "INSERT INTO data.element_types (elt_id, geom_type, priority, footprint_params, clearance_category, topology_participant) VALUES (1720000,2,1,'{\"buffer\":{\"radius\":0.2}}',1,true)"
REM cesta
%OGRBIN%\ogrinfo -ro PG:%PGCONN% -sql "INSERT INTO data.element_types (elt_id, geom_type, priority, footprint_params, clearance_category, topology_participant) VALUES (2470000,2,1,'{\"buffer\":{\"radius\":1}}',1,true)"
%OGRBIN%\ogrinfo -ro PG:%PGCONN% -sql "INSERT INTO data.element_types (elt_id, geom_type, priority, footprint_params, clearance_category, topology_participant) VALUES (2480001,2,1,'{\"buffer\":{\"radius\":1}}',1,true)"
%OGRBIN%\ogrinfo -ro PG:%PGCONN% -sql "INSERT INTO data.element_types (elt_id, geom_type, priority, footprint_params, clearance_category, topology_participant) VALUES (2480006,2,1,'{\"buffer\":{\"radius\":1}}',1,true)"
%OGRBIN%\ogrinfo -ro PG:%PGCONN% -sql "INSERT INTO data.element_types (elt_id, geom_type, priority, footprint_params, clearance_category, topology_participant) VALUES (2490101,2,1,'{\"buffer\":{\"radius\":0.75}}',1,true)"
%OGRBIN%\ogrinfo -ro PG:%PGCONN% -sql "INSERT INTO data.element_types (elt_id, geom_type, priority, footprint_params, clearance_category, topology_participant) VALUES (2490200,2,1,'{\"buffer\":{\"radius\":3, \"cap\": \"flat\"}}',1,true)"

REM vodni tok
%OGRBIN%\ogrinfo -ro PG:%PGCONN% -sql "INSERT INTO data.element_types (elt_id, geom_type, priority, footprint_params, clearance_category, topology_participant) VALUES (3020100,2,1,'{\"buffer\":{\"radius\":0.75}}',1,false)"
REM vodni kanal
%OGRBIN%\ogrinfo -ro PG:%PGCONN% -sql "INSERT INTO data.element_types (elt_id, geom_type, priority, footprint_params, clearance_category, topology_participant) VALUES (3030000,2,1,'{\"buffer\":{\"radius\":1.2}}',1,true)"
%OGRBIN%\ogrinfo -ro PG:%PGCONN% -sql "INSERT INTO data.element_types (elt_id, geom_type, priority, footprint_params, clearance_category, topology_participant) VALUES (3040000,2,1,'{\"buffer\":{\"radius\":1.2}}',1,false)"
REM brehovka
%OGRBIN%\ogrinfo -ro PG:%PGCONN% -sql "INSERT INTO data.element_types (elt_id, geom_type, priority, footprint_params, clearance_category, topology_participant) VALUES (3060000,2,1,'{\"buffer\":{\"radius\":0.75}}',1,true)"
REM vodni plocha
%OGRBIN%\ogrinfo -ro PG:%PGCONN% -sql "INSERT INTO data.element_types (elt_id, geom_type, priority, footprint_params, clearance_category, topology_participant) VALUES (3330000,3,1,'{\"buffer\":{\"radius\":0.75}}',1,true)"
REM zelen
%OGRBIN%\ogrinfo -ro PG:%PGCONN% -sql "INSERT INTO data.element_types (elt_id, geom_type, priority, footprint_params, clearance_category, topology_participant) VALUES (4120000,2,1,'{\"buffer\":{\"radius\":6}}',1,false)"
REM hr. uzivani
%OGRBIN%\ogrinfo -ro PG:%PGCONN% -sql "INSERT INTO data.element_types (elt_id, geom_type, priority, footprint_params, clearance_category, topology_participant) VALUES (5210100,2,1,'{\"buffer\":{\"radius\":0.75}}',1,true)"
REM terenni stupen
%OGRBIN%\ogrinfo -ro PG:%PGCONN% -sql "INSERT INTO data.element_types (elt_id, geom_type, priority, footprint_params, clearance_category, topology_participant) VALUES (6060100,2,1,'{\"buffer\":{\"radius\":3.75}}',1,false)" 

%OGRBIN%\ogrinfo -ro PG:%PGCONN% -sql "TRUNCATE data.elements_in CASCADE"
for /R %~dp0 %%i IN (*.shp) do (
  echo %%~ni
  
  %OGRBIN%\ogr2ogr -overwrite -f PostgreSQL PG:%PGCONN% -nlt GEOMETRY -nln data.temp_elements^
  -lco OVERWRITE=YES^
  --config PG_USE_COPY YES^
  -sql "SELECT znacka as elt_id, objectid AS source_id, znacka as source_elt_id FROM %%~ni" %%i
  
  %OGRBIN%\ogrinfo -ro PG:%PGCONN%^
  -sql "INSERT INTO data.elements_in (elt_id, source_id, source_elt_id, geom) SELECT elt_id, source_id, source_elt_id, ST_SetSrid(wkb_geometry, 0) FROM data.temp_elements"
  
  %OGRBIN%\ogrinfo -ro PG:%PGCONN%^
  -sql "VACUUM FULL ANALYZE data.temp_elements"
  
  %OGRBIN%\ogrinfo -ro PG:%PGCONN%^
  -sql "DROP TABLE data.temp_elements"
  
)

