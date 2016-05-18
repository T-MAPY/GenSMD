@echo off
call %~dp0config.bat
%PGBIN%\psql -x -c "select admin.restoreobjects(array['m1','m1_utils','m1_model','m1_data','m1_tests'],'%SRCDIR%', true)"