@echo off
call %~dp0config.bat
%PGBIN%\psql -x -c "select admin.restoreobjects(array['admin'],'%SRCDIR%')"
%PGBIN%\psql -x -c "select admin.restoreobjects(array['data'],'%SRCDIR%', true)"