@echo off
cd %~dp0
heat dir ..\..\build\ -cg Package -gg -sfrag -template:fragment -out temp.wxs