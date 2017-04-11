@ECHO OFF
SETLOCAL
chcp 866>nul

:: start
REM ПРИМЕР ИСПОЛЬЗОВАНИЯ


SET GOPATH=%CD%

REM Запус программы
SET GOROOT=C:\GO
SET PATH=%GOROOT%\BIN;%PATH%;

REM Build project
REM пакует в папку "prod" проект
revel build bars prod_win

REM делает архив из готового проекта
REM revel package bars

pause
