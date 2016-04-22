@echo off
call config.bat
%PGBIN%\psql -x -c "select utils.restoreobjects(array['utils'],'%SRCDIR%')"
%PGBIN%\psql -x -c "select utils.restoreobjects(array['m1','model','data','tests'],'%SRCDIR%', true)"