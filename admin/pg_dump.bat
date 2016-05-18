@echo off
call %~dp0config.bat
%PGBIN%\pg_dump.exe %*
