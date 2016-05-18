@echo off
call %~dp0config.bat
%PGBIN%\psql -x -c "select m1.gen_topo_register()"
%PGBIN%\psql -x -c "select admin.dumpobjects(array['m1_data','m1','m1_model','m1_tests','m1_utils'],'%SRCDIR%','%PGDUMP%')"
