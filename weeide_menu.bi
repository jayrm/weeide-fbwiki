#ifndef __WEEIDE_MENU_INCLUDE__
#define __WEEIDE_MENU_INCLUDE__

	''
	declare function GetAppAccelTable() as HACCEL 

	declare function CreateAppAccelTables() as BOOL
	declare function DestroyAppAccelTables() as BOOL

	''
	enum APPMENUIDS
	
		APPMENUID_MAIN,
		
		APPMENUID_FILE,
		APPMENUID_EDIT,
		APPMENUID_WIKI,
		APPMENUID_WINDOW,
		APPMENUID_HELP,

		APPMENUID_COUNT

	end enum

	declare function GetAppMenu( byval id as APPMENUIDS ) as HMENU
	declare function DestroyAppMenus() as BOOL

#endif
