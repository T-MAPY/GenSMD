@echo off
call config.bat
%PGBIN%\psql -x -c "CREATE SCHEMA utils"
%PGBIN%\psql -x -c "CREATE EXTENSION postgis"
%PGBIN%\psql -x -c "CREATE EXTENSION postgis_topology"
%PGBIN%\psql -x -c "CREATE EXTENSION plpython3u"
%PGBIN%\psql -x -c "CREATE EXTENSION hstore"
call update.bat