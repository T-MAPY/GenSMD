@echo off
call %~dp0config.bat
%PGBIN%\psql -c "SELECT * FROM m1_utils.runtests() ORDER BY result DESC, test, name"