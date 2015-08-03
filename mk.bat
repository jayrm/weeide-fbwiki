call c:\batch\setpath.bat FBWIN
e:
cd \fb\fbdocs\weeide.fb
REM make clean
cd webctrl 
make DEBUG=1
cd ..
make -f makefile.jef DEBUG=1 FBDOCDIR=d:/fb.git/doc/libfbdoc
copy weeide.exe  e:\fb\fbdocs\manual\weeide.exe