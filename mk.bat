call c:\batch\setpath.bat FBWIN
e:
cd \fb\fbtools\weeide.fb
REM make clean
make -f makefile.jef DEBUG=1
