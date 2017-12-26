'' --------------------------------------------------------------------------
'' Wee IDE - for FreeBASIC
'' --------------------------------------------------------------------------
'' Windows gui version
'' --------------------------------------------------------------------------

#include once "windows.bi"
#include once "win/commctrl.bi"
#include once "win/ole2.bi"
#include once "common.bi"

#include once "weeide.bi"
#include once "weeide_menu.bi"
#include once "weeide_main.bi"
#include once "weeide_ini.bi"

#include once "mkwiki.bi"

'' Globals 
dim shared Application as CApplication
dim shared Docs as CDocuments

'' -----------------------------------------------------------------------
'' WinMain
'' -----------------------------------------------------------------------

function WinMain stdcall alias "WinMain" _
	( _
		byval hInstance as HINSTANCE, _
		byval hPrevInstance as HINSTANCE, _
		byval lpCmdLine as LPSTR, _
		byval nCmdShow as integer _
	) as integer

	dim as MainWindow ptr frmMain

	dim as BOOL ret
	dim as MSG wMsg

	Application.Name = TEXT( "WEEIDE" )
	Application.Title = TEXT( "Wee IDE" )

	'' make sure we can read the ini file
	weeide_ini_set_filename( "weeide.ini" )

	if( weeide_ini_loadfile() = false ) then
		Application.ErrorMessage( 0, TEXT( "Unable to read 'weeide.ini'" ))
		return -1
	end if

	if( OleInitialize( NULL ) <> S_OK ) then
		return -1
	end if

	if( mkwiki_Create() = FALSE ) then
		OleUninitialize( )
		return -1
	end if

	'' make sure we are using the correct styles
	InitCommonControls()

	'' Make sure we can load RichEdit control
	if( NULL = LoadLibrary( TEXT( "riched20.dll" ))) then
		dim as DWORD result = GetLastError()
		Application.ErrorMessage( result, TEXT( "Could not load riched20.dll" ))
		mkwiki_Destroy()
		OleUninitialize( )
		return result
	end if

	if( GetAppMenu( APPMENUID_MAIN ) = FALSE ) then
		Application.ErrorMessage( 0, TEXT( "Unable to initialize one or more menus" ))
	end if

	if( CreateAppAccelTables() = FALSE ) then
		Application.ErrorMessage( 0, TEXT( "Unable to initialize one or more accelerator tables" ))
	end if

	'' Initialize the application
	frmMain = MainWindow.InitInstance( hInstance )
	if( frmMain = NULL ) then
		Application.ErrorMessage( 0, TEXT( "Unable to initialize main window" ))
		mkwiki_Destroy()
		OleUninitialize( )
		return 1
	end if

	mkwiki_HookPrintLogger( frmMain )

	'' Show the main window
	ShowWindow( frmMain->GetHwnd(), nCmdShow )
	UpdateWindow( frmMain->GetHwnd() )

	frmMain->CmdWikiPageList( FALSE )

	'' ///
	'' !!! TODO: check html path
	HtmlPreview_Init( weeide_ini_getopt( "manual_dir", exepath() & "/" ) )

	/'
	'' create a new window 
	frmMain->CmdNew();
	'/

	/'
	'' load the user name's wiki page
	dim as TString f 
	f = weeide_ini_getopt( "web_username", "" )
	if( f.GetLength() > 0 ) then
		frmMain->CmdWikiOpen( f )
	end if
	'/

	while( TRUE )
		ret = GetMessage( @wMsg, NULL, 0, 0 )
		if( ret = 0 ) then
			exit while

		elseif( ret = - 1) then
			'' Error occured
			exit while

		else

			ret = FALSE

			'' Check for active modeless dialog messages
			if( NULL <> Application.GetActiveDlgHwnd() ) then
				if( IsDialogMessage( Application.GetActiveDlgHwnd(), @wMsg )) then
					ret = TRUE
				end if
			end if

			if( FALSE = ret ) then
			if( FALSE = TranslateMDISysAccel( frmMain->GetHwndMDI(), @wMsg )) then
			if( FALSE = TranslateAccelerator( frmMain->GetHwnd(), frmMain->GetAccelTable(), @wMsg )) then
				TranslateMessage( @wMsg )
				DispatchMessage( @wMsg )
			end if
			end if
			end if

		end if
	wend
	
	mkwiki_UnHookPrintLogger()

	'' Remove the application menu
	SetMenu( frmMain->GetHwnd(), NULL )

	DestroyAppMenus()
	DestroyAppAccelTables()

	mkwiki_Destroy()
	
	if( ret = -1 ) then
		Application.ErrorMessage( wMsg.wParam, NULL )
	end if

	OleUninitialize( )

	return wMsg.wParam
	
end function

'' end WinMain( GetModuleHandle(0), NULL, GetCommandLine(), SW_SHOW )