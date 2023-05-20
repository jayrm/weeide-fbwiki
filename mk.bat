call c:\batch\setpath.bat fbgit32
e:
cd \fb\fbdocs\weeide.fb
REM make clean
cd webctrl 
make DEBUG=1 FBC=fbc-win32.exe
cd ..

make -f makefile.jef FBC=fbc-win32.exe DEBUG=1 FBDOCDIR=d:/fb.git/doc/libfbdoc

