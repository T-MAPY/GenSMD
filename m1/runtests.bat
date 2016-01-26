@echo off
call config.bat
%PGBIN%\psql -c "SELECT * FROM utils.runtests() ORDER BY result DESC, test, name"