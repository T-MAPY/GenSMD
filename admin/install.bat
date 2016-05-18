@echo off
call %~dp0config.bat
%PGBIN%\psql -x -c "CREATE EXTENSION postgis"
%PGBIN%\psql -x -c "CREATE EXTENSION postgis_topology"
%PGBIN%\psql -x -c "CREATE EXTENSION plpython3u"
%PGBIN%\psql -x -c "CREATE SCHEMA admin"
%PGBIN%\psql -x -f %SRCDIR%/admin/functions/glob.sql
%PGBIN%\psql -x -f %SRCDIR%/admin/functions/loadfile.sql
%PGBIN%\psql -x -f %SRCDIR%/admin/functions/restoreobjects.sql

SET PGOPTIONS=--client-min-messages=warning
call %~dp0restore.bat