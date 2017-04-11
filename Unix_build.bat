@ECHO OFF
SETLOCAL
chcp 866>nul

:: start
REM ПРИМЕР ИСПОЛЬЗОВАНИЯ


SET GOPATH=%CD%

REM Запус программы
SET GOROOT=C:\GO
SET PATH=%GOROOT%\BIN;%PATH%;

SET GOOS=linux
SET GOARCH=amd64
SET CGO_ENABLED=0


REM Build project
REM пакует в папку "prod_unix" проект
revel build bars prod_unix

REM делает архив из готового проекта
REM revel package bars



pause
