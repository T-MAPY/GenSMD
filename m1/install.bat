@echo off
call config.bat
%PGBIN%\psql -x -c "CREATE SCHEMA utils"
%PGBIN%\psql -x -c "CREATE SCHEMA work"
%PGBIN%\psql -x -c "CREATE EXTENSION postgis"
%PGBIN%\psql -x -c "CREATE EXTENSION postgis_topology"
%PGBIN%\psql -x -c "CREATE EXTENSION plpython3u"
%PGBIN%\psql -x -f %SRCDIR%/utils/functions/glob.sql
%PGBIN%\psql -x -f %SRCDIR%/utils/functions/loadfile.sql
%PGBIN%\psql -x -f %SRCDIR%/utils/functions/restoreobjects.sql
call restore.bat