@echo off
if "%1" == "" goto HELP

cd ..

echo making directories

mkdir .\weeide.fb\dist\%1

echo Removing previous files

del   .\weeide.fb\dist\%1\*.zip

echo making distribution

zip .\weeide.fb\dist\%1\weeide-%1-src.zip @weeide.fb\dist_src.lst
zip .\weeide.fb\dist\%1\weeide-%1-win32.zip @weeide.fb\dist_win.lst

cd weeide.fb

goto END
:HELP
echo.mkdist yyyy.mm.dd
echo.writes zip files 
echo .\weeide.fb\dist\yyyy.mm.dd\weeide-yyyy.mm.dd-src.zip
echo .\weeide.fb\dist\yyyy.mm.dd\weeide-yyyy.mm.dd-win32.zip
:END
