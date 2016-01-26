@echo off
call %~dp0..\..\config.bat
%PGBIN%\pg_dump.exe %*
