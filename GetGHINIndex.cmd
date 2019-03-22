@echo off
REM ###########################################
REM # Name: GetGHINindex,cmd
REM #
REM # Input: c:\projects\golf\users.txt 
REM #        each line in file is a GHIN#
REM #
REM ###########################################
c:
cd c:\Projects\Golf

powershell C:\Projects\Golf\GetGHINIndex.ps1
