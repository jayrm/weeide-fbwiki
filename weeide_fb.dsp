# Microsoft Developer Studio Project File - Name="weeide_fb" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 5.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) External Target" 0x0106

CFG=weeide_fb - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "weeide_fb.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "weeide_fb.mak" CFG="weeide_fb - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "weeide_fb - Win32 Release" (based on "Win32 (x86) External Target")
!MESSAGE "weeide_fb - Win32 Debug" (based on "Win32 (x86) External Target")
!MESSAGE 

# Begin Project
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""

!IF  "$(CFG)" == "weeide_fb - Win32 Release"

# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release"
# PROP BASE Intermediate_Dir "Release"
# PROP BASE Cmd_Line "NMAKE /f weeide_fb.mak"
# PROP BASE Rebuild_Opt "/a"
# PROP BASE Target_File "weenyide.exe"
# PROP BASE Bsc_Name "weenyide.bsc"
# PROP BASE Target_Dir ""
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release"
# PROP Intermediate_Dir "Release"
# PROP Cmd_Line "e:\fb\fbtools\weeide.fb\mk.bat"
# PROP Rebuild_Opt ""
# PROP Target_File "e:\fb\fbtools\weeide.fb\weeide.exe"
# PROP Bsc_Name ""
# PROP Target_Dir ""

!ELSEIF  "$(CFG)" == "weeide_fb - Win32 Debug"

# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug"
# PROP BASE Intermediate_Dir "Debug"
# PROP BASE Cmd_Line "NMAKE /f weeide_fb.mak"
# PROP BASE Rebuild_Opt "/a"
# PROP BASE Target_File "weeide.exe"
# PROP BASE Bsc_Name "weenyide.bsc"
# PROP BASE Target_Dir ""
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Debug"
# PROP Intermediate_Dir "Debug"
# PROP Cmd_Line "e:\fb\fbdocs\weeide.fb\mk.bat"
# PROP Rebuild_Opt ""
# PROP Target_File "e:\fb\fbdocs\weeide.fb\weeide.exe"
# PROP Bsc_Name ""
# PROP Target_Dir ""

!ENDIF 

# Begin Target

# Name "weeide_fb - Win32 Release"
# Name "weeide_fb - Win32 Debug"

!IF  "$(CFG)" == "weeide_fb - Win32 Release"

!ELSEIF  "$(CFG)" == "weeide_fb - Win32 Debug"

!ENDIF 

# Begin Group "res"

# PROP Default_Filter ""
# Begin Group "icons"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\res\document.ico
# End Source File
# Begin Source File

SOURCE=.\res\document_large.ico
# End Source File
# Begin Source File

SOURCE=.\res\document_small.ico
# End Source File
# Begin Source File

SOURCE=.\res\weeide.ico
# End Source File
# Begin Source File

SOURCE=.\res\weeide_large.ico
# End Source File
# Begin Source File

SOURCE=.\res\weeide_small.ico
# End Source File
# End Group
# Begin Source File

SOURCE=.\resource.bi
# End Source File
# Begin Source File

SOURCE=.\resource.h
# End Source File
# Begin Source File

SOURCE=.\res\weeide.exe.manifest
# End Source File
# Begin Source File

SOURCE=.\weeide.rc2
# End Source File
# Begin Source File

SOURCE=.\weeide_fb.rc
# End Source File
# Begin Source File

SOURCE=.\weeide_resource.bi
# End Source File
# Begin Source File

SOURCE=.\weeide_resource.h
# End Source File
# End Group
# Begin Group "build"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\dist_src.lst
# End Source File
# Begin Source File

SOURCE=.\dist_win.lst
# End Source File
# Begin Source File

SOURCE=.\makefile
# End Source File
# Begin Source File

SOURCE=.\makefile.jef
# End Source File
# Begin Source File

SOURCE=.\mk.bat
# End Source File
# Begin Source File

SOURCE=.\mkdist.bat
# End Source File
# Begin Source File

SOURCE=.\notes.txt
# End Source File
# Begin Source File

SOURCE=.\readme.txt
# End Source File
# Begin Source File

SOURCE=.\weeide.ini
# End Source File
# Begin Source File

SOURCE=.\weeide.ini.org
# End Source File
# End Group
# Begin Group "src"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\mkwiki.bas
# End Source File
# Begin Source File

SOURCE=.\mkwiki.bi
# End Source File
# Begin Source File

SOURCE=.\mkwiki_getindex.bas
# End Source File
# Begin Source File

SOURCE=.\mkwiki_login.bas
# End Source File
# Begin Source File

SOURCE=.\mkwiki_login.bi
# End Source File
# Begin Source File

SOURCE=.\mkwiki_preview.bas
# End Source File
# Begin Source File

SOURCE=.\spellcheck.bas
# End Source File
# Begin Source File

SOURCE=.\spellcheck.bi
# End Source File
# Begin Source File

SOURCE=.\weeide.bas
# End Source File
# Begin Source File

SOURCE=.\weeide.bi
# End Source File
# Begin Source File

SOURCE=.\weeide_about.bas
# End Source File
# Begin Source File

SOURCE=.\weeide_about.bi
# End Source File
# Begin Source File

SOURCE=.\weeide_code.bas
# End Source File
# Begin Source File

SOURCE=.\weeide_code.bi
# End Source File
# Begin Source File

SOURCE=.\weeide_edit.bas
# End Source File
# Begin Source File

SOURCE=.\weeide_edit.bi
# End Source File
# Begin Source File

SOURCE=.\weeide_find.bas
# End Source File
# Begin Source File

SOURCE=.\weeide_find.bi
# End Source File
# Begin Source File

SOURCE=.\weeide_html.bas
# End Source File
# Begin Source File

SOURCE=.\weeide_html.bi
# End Source File
# Begin Source File

SOURCE=.\weeide_ini.bas
# End Source File
# Begin Source File

SOURCE=.\weeide_ini.bi
# End Source File
# Begin Source File

SOURCE=.\weeide_main.bas
# End Source File
# Begin Source File

SOURCE=.\weeide_main.bi
# End Source File
# Begin Source File

SOURCE=.\weeide_menu.bas
# End Source File
# Begin Source File

SOURCE=.\weeide_menu.bi
# End Source File
# Begin Source File

SOURCE=.\weeide_spell.bas
# End Source File
# Begin Source File

SOURCE=.\weeide_spell.bi
# End Source File
# Begin Source File

SOURCE=.\weeide_wiki.bas
# End Source File
# Begin Source File

SOURCE=.\weeide_wiki.bi
# End Source File
# End Group
# Begin Group "classes"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\CApplication.bas
# End Source File
# Begin Source File

SOURCE=.\CApplication.bi
# End Source File
# Begin Source File

SOURCE=.\CCodeEditControl.bas
# End Source File
# Begin Source File

SOURCE=.\CCodeEditControl.bi
# End Source File
# Begin Source File

SOURCE=.\CDocuments.bas
# End Source File
# Begin Source File

SOURCE=.\CDocuments.bi
# End Source File
# Begin Source File

SOURCE=.\CList.bas
# End Source File
# Begin Source File

SOURCE=.\CList.bi
# End Source File
# Begin Source File

SOURCE=.\common.bi
# End Source File
# Begin Source File

SOURCE=.\COutputControl.bas
# End Source File
# Begin Source File

SOURCE=.\COutputControl.bi
# End Source File
# Begin Source File

SOURCE=.\CWindow.bas
# End Source File
# Begin Source File

SOURCE=.\CWindow.bi
# End Source File
# Begin Source File

SOURCE=.\CWindowInfo.bas
# End Source File
# Begin Source File

SOURCE=.\CWindowInfo.bi
# End Source File
# Begin Source File

SOURCE=.\CWindowProps.bas
# End Source File
# Begin Source File

SOURCE=.\CWindowProps.bi
# End Source File
# Begin Source File

SOURCE=.\TString.bas
# End Source File
# Begin Source File

SOURCE=.\TString.bi
# End Source File
# Begin Source File

SOURCE=.\utils.bas
# End Source File
# Begin Source File

SOURCE=.\utils.bi
# End Source File
# End Group
# Begin Group "webctrl"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\webctrl\CBrowser.bas
# End Source File
# Begin Source File

SOURCE=.\webctrl\CBrowser.bi
# End Source File
# Begin Source File

SOURCE=.\webctrl\CClientSite.bas
# End Source File
# Begin Source File

SOURCE=.\webctrl\CClientSite.bi
# End Source File
# Begin Source File

SOURCE=.\webctrl\CInPlaceFrame.bas
# End Source File
# Begin Source File

SOURCE=.\webctrl\CInPlaceFrame.bi
# End Source File
# Begin Source File

SOURCE=.\webctrl\CInPlaceSite.bas
# End Source File
# Begin Source File

SOURCE=.\webctrl\CInPlaceSite.bi
# End Source File
# Begin Source File

SOURCE=.\webctrl\Common.bi
# End Source File
# Begin Source File

SOURCE=.\webctrl\Makefile
# End Source File
# Begin Source File

SOURCE=.\webctrl\webctrl.bas
# End Source File
# Begin Source File

SOURCE=.\webctrl\webctrl.bi
# End Source File
# End Group
# End Target
# End Project
