#include once "windows.bi"
#include once "common.bi"

#include once "weeide.bi"
#include once "weeide_menu.bi"

'' --------------------------------------------------------
'' Accelerator Tables
''     all MDI children will use this also
'' --------------------------------------------------------

#define NUM_APP_SHORTCUTS 8

static shared as ACCEL app_shortcuts(0 to NUM_APP_SHORTCUTS - 1) = _
{ _
	( FCONTROL or FVIRTKEY, asc("N")  , IDM_FILE_NEW ), _
	( FCONTROL or FVIRTKEY, asc("O")  , IDM_FILE_OPEN ), _
	( FCONTROL or FVIRTKEY, asc("S")  , IDM_FILE_SAVE ), _
	( FVIRTKEY            , VK_F3     , IDM_EDIT_FINDNEXT ), _
	( FCONTROL or FVIRTKEY, asc("F")  , IDM_EDIT_FIND ), _
	( FCONTROL or FVIRTKEY, asc("R")  , IDM_EDIT_REPLACE ), _
	( FCONTROL or FVIRTKEY, asc("V")  , IDM_EDIT_PASTE ), _
	( FVIRTKEY            , VK_F5     , IDM_WIKI_PREVIEW ) _
}

static shared as HACCEL app_accel = NULL

function GetAppAccelTable() as HACCEL

	if( app_accel = NULL ) then
		app_accel = CreateAcceleratorTable( @app_shortcuts(0), NUM_APP_SHORTCUTS )
	end if
	return app_accel
end function

function CreateAppAccelTables() as BOOL

	dim as BOOL ret = TRUE

	if( GetAppAccelTable() = NULL ) then
		ret = FALSE
	end if

	return ret
end function

function DestroyAppAccelTables() as BOOL

	if( app_accel ) then
		DestroyAcceleratorTable( app_accel )
	end if

	return TRUE
end function

'' --------------------------------------------------------
'' Create the main menu 
''     all MDI children will use this also
'' --------------------------------------------------------

declare function CreateAppFileMenu() as HMENU
declare function CreateAppEditMenu() as HMENU
declare function CreateAppWindowMenu() as HMENU
declare function CreateAppWikiMenu() as HMENU
declare function CreateAppHelpMenu() as HMENU

declare function CreateAppMainMenu() as HMENU

type APPMENUINFO
	hmenu as HMENU
	CreateProc as function() as HMENU
end type

static shared as APPMENUINFO AppMenus( 0 to APPMENUID_COUNT - 1 ) = _
{ _
	( NULL, @CreateAppMainMenu ), _
	( NULL, @CreateAppFileMenu ), _
	( NULL, @CreateAppEditMenu ), _
	( NULL, @CreateAppWindowMenu ), _
	( NULL, @CreateAppWikiMenu ), _
	( NULL, @CreateAppHelpMenu ) _
}

function GetAppMenu( byval id as APPMENUIDS ) as HMENU

	if( (id < 0) or (id >= APPMENUID_COUNT) ) then
		return NULL
	end if

	if( NULL = AppMenus(id).hmenu ) then
		AppMenus(id).hmenu = AppMenus(id).CreateProc()
	end if

	return AppMenus(id).hmenu

end function

#define MENUBARSTYLE	cast(UINT, MF_ENABLED or MF_STRING or MF_POPUP)
#define MENUITEMSTYLE	cast(UINT, MF_ENABLED or MF_STRING)

#define AMC_		dim menu as HMENU = CreatePopupMenu()
#define AMB_(m,t)	AppendMenu( menu, MENUBARSTYLE, cast(UINT, GetAppMenu(m)), t )
#define AMI_(i,t)	AppendMenu( menu, MENUITEMSTYLE, i, t )
#define AMR_		return menu

function CreateAppFileMenu() as HMENU

	AMC_

	AMI_( IDM_FILE_NEW         , TEXT( "&New\tCtrl+N" ))
	AMI_( MF_SEPARATOR         , NULL )
	AMI_( IDM_FILE_OPEN        , TEXT( "&Open\tCtrl+O" ))
	AMI_( IDM_FILE_SAVE        , TEXT( "&Save\tCtrl+S" ))
	AMI_( IDM_FILE_SAVE_AS     , TEXT( "Save &As..." ))
	AMI_( IDM_FILE_SAVE_ALL    , TEXT( "Save A&ll" ))
	AMI_( MF_SEPARATOR         , NULL )
	AMI_( IDM_FILE_CLOSE       , TEXT( "&Close" ))
	AMI_( MF_SEPARATOR         , NULL )
	AMI_( IDM_FILE_RECENT      , TEXT( "Recent &Files" ))
	AMI_( MF_SEPARATOR         , NULL )
	AMI_( IDM_FILE_EXIT        , TEXT( "E&xit" ))

	AMR_

end function

function CreateAppEditMenu() as HMENU

	AMC_

	AMI_( IDM_EDIT_UNDO      , TEXT( "&Undo\tCtrl+Z" ))
	AMI_( IDM_EDIT_REDO      , TEXT( "&Redo\tCtrl+Y" ))
	AMI_( MF_SEPARATOR       , NULL )
	AMI_( IDM_EDIT_CUT       , TEXT( "Cu&t\tCtrl+X" ))
	AMI_( IDM_EDIT_COPY      , TEXT( "&Copy\tCtrl+C" ))
	AMI_( IDM_EDIT_PASTE     , TEXT( "&Paste\tCtrl+V" ))
	AMI_( IDM_EDIT_DELETE    , TEXT( "&Delete\tDel" ))
	AMI_( MF_SEPARATOR       , NULL )
	AMI_( IDM_EDIT_SELECTALL , TEXT( "Select A&ll\tCtrl+A" ))
	AMI_( MF_SEPARATOR       , NULL )
	AMI_( IDM_EDIT_FIND      , TEXT( "&Find\tCtrl+F" ))
''	AMI_( IDM_EDIT_REPLACE   , TEXT( "&Replace\tCtrl+R" ))
	AMR_

end function

function CreateAppWindowMenu() as HMENU

	AMC_

	AMI_( IDM_WINDOW_ARRANGE_CASCADE  , TEXT( "&Cascage" ))
	AMI_( IDM_WINDOW_TILE_HORIZONTALLY, TEXT( "Tile &Horizontally" ))
	AMI_( IDM_WINDOW_TILE_VERTICALLY  , TEXT( "&Tile Vertically" ))
	AMI_( MF_SEPARATOR                , NULL )
	AMI_( IDM_WINDOW_NEXT             , TEXT( "Next" ))
	AMI_( IDM_WINDOW_PREVIOUS         , TEXT( "Previous" ))
	AMI_( MF_SEPARATOR                , NULL )
	AMI_( IDM_WINDOW_CLOSE_ALL        , TEXT( "Close All" ))

	AMR_

end function

function CreateAppWikiMenu() as HMENU

	AMC_

	AMI_( IDM_WIKI_LOGIN    , TEXT( "&Login" ))
	AMI_( IDM_WIKI_PAGELIST , TEXT( "&Refresh Page List" ))
	AMI_( IDM_WIKI_PREVIEW  , TEXT( "&Preview\tF5" ))

	AMR_

end function

function CreateAppHelpMenu() as HMENU

	AMC_

	''AMI_( MF_SEPARATOR                , NULL )
	AMI_( IDM_HELP_ABOUT   , TEXT( "&About Wee IDE" ))

	AMR_

end function


function CreateAppMainMenu() as HMENU

	dim menu as HMENU = CreateMenu()

	AMB_( APPMENUID_FILE, TEXT( "&File" ) )
	AMB_( APPMENUID_EDIT, TEXT( "&Edit" ))
	AMB_( APPMENUID_WIKI, TEXT( "Wi&ki" ))
	AMB_( APPMENUID_WINDOW, TEXT( "&Window" ))
	AMB_( APPMENUID_HELP, TEXT( "&Help" ))

	return menu

end function

function DestroyAppMenus() as BOOL

	dim i as integer 
	for i = 0 to APPMENUID_COUNT - 1
		DestroyMenu( AppMenus(i).hmenu )
		AppMenus(i).hmenu = NULL
	next

	return TRUE

end function
