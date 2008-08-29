@echo off
if "%1" == "" goto HELP

cd ..

mkdir h:\upload\weeide\dist\%1
del h:\upload\weeide\dist\%1\*.zip

wzzip -ex -P @weeide.fb\dist_win.lst h:\upload\weeide\dist\%1\weeide-%1-win.zip
wzzip -ex -P @weeide.fb\dist_src.lst h:\upload\weeide\dist\%1\weeide-%1-src.zip

cd weeide.fb

goto END
:HELP
echo mkdist yyyy.mm.dd
:END
