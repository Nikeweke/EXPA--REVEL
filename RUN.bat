@ECHO OFF
SETLOCAL
chcp 866>nul

:: start
REM ПРИМЕР ИСПОЛЬЗОВАНИЯ
REM SET GOPATH=D:\MORION\RETHINKDB\GO


SET GOPATH=%CD%

REM Запус программы
SET GOROOT=C:\GO
SET PATH=%GOROOT%\BIN;%PATH%;

REM Создание шаблона проекта
REM revel new bars


revel run bars

REM в conf/app.conf в секции dev и prod можно указать порты или же дописывать их здесь
REM revel run bars dev
REM revel run bars dev 80
REM revel run bars prod

pause
