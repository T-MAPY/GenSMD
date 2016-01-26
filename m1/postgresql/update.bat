@echo off
call config.bat
%PGBIN%\psql < src/utils/functions/glob.sql
%PGBIN%\psql < src/utils/functions/loadfile.sql
%PGBIN%\psql < src/utils/functions/restoreobjects.sql
%PGBIN%\psql -x -c "select utils.restoreobjects(array['m1'],'%SRCDIR%')"