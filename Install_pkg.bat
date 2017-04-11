@ECHO OFF
SETLOCAL
chcp 866>nul



SET GOPATH=%CD%
SET GOROOT=C:\GO
SET PATH=%GOROOT%\BIN;%PATH%;


REM Установка пакетов
go get -v -u github.com/revel/revel
go get -v -u github.com/revel/cmd/revel
go get -u -v github.com/dancannon/gorethink

pause
