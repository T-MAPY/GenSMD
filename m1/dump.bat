@echo off
call config.bat
%PGBIN%\psql -x -c "select m1.gen_topo_register()"
%PGBIN%\psql -x -c "select utils.dumpobjects(array['data','m1','tests','utils'],'%SRCDIR%')"
