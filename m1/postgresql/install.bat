@echo off
call config.bat
%PGBIN%\psql -x -c "CREATE SCHEMA utils"
%PGBIN%\psql -x -c "CREATE EXTENSION plpython3u"
call update.bat