@echo off
call %~dp0config.bat
%PGBIN%\psql -x -c "select admin.dumpobjects(array['admin','data'],'%SRCDIR%','%PGDUMP%')"
