#ifndef __WEEIDE_MAIN_INCLUDE__
#define __WEEIDE_MAIN_INCLUDE__

#include once "CWindow.bi"
#include once "CWindowInfo.bi"
#include once "COutputControl.bi"
#include once "weeide_find.bi"
#include once "weeide_spell.bi"

type MainWindow

	private:
		as HINSTANCE _hInstance
		as CWindow _hwnd
		as CWindow _hwndMDI
		as HMENU _hmenuMDI
		as HACCEL _haccelTable
		as CFindDialog ptr frmFind
		as CWindow _hwndFilter
		as CWindow _hwndList
		as COutputControl _hwndOutput
		as HFONT _fixedfnt
		as HFONT _swissfnt
		as CWindowInfo _info
		as CSpellCheckDialog ptr frmSpell

		declare function SelfRegister() as BOOL

	private:
		declare constructor ()
		declare destructor ()

	public:
		declare static function InitInstance( byval hInstance as HINSTANCE ) as MainWindow ptr

		declare static function WindowProc _
			( _
				byval hwnd as HWND, _
				byval uMsg as UINT, _
				byval wParam as WPARAM, _
				byval lParam as LPARAM _
			) as LRESULT

		declare function GetHwnd() as HWND
		declare function GetHwndMDI() as HWND
		declare function GetActiveChild() as HWND
		declare function InitMainMenu() as BOOL
		declare function GetAccelTable() as HACCEL

		'' EVENTS
		declare function OnInitMenuPopup( byval wParam as WPARAM, byval lParam as LPARAM ) as BOOL
		declare function OnQueryCommand( byval menuid as UINT, byval state as UINT ptr ) as BOOL
		declare function OnCommand( byval wParam as WPARAM, byval lParam as LPARAM ) as BOOL
		declare function OnFindNext( byval wParam as WPARAM, byval lParam as LPARAM ) as BOOL
		declare function OnSpellNext( byval wParam as WPARAM, byval lParam as LPARAM ) as BOOL
		declare function OnPageIndexCompleted( byval wParam as WPARAM, byval lParam as LPARAM ) as BOOL
		declare function OnSize( byval nWidth as integer, byval nHeight as integer ) as BOOL
		declare function OnClose() as BOOL

		'' COMMANDS - returns TRUE if completed successfully
		declare function CmdNew() as BOOL
		declare function CmdOpen( byref filename as TString ) as BOOL
		declare function CmdOpen() as BOOL
		'' declare function CmdSave( byref filename as TString ) as BOOL
		declare function CmdSave( byval child as HWND = NULL, byval bForcePrompt as BOOL = FALSE ) as BOOL
		declare function CmdSaveAs( byval child as HWND = NULL ) as BOOL
		declare function CmdSaveAll() as BOOL
		declare function CmdClose( byval hwnd as HWND = NULL ) as BOOL
		declare function CmdQueryCloseAll() as BOOL
		declare function CmdCloseAll() as BOOL
		declare function CmdExit() as BOOL
		declare function CmdFind( byval bNext as BOOL ) as BOOL
		declare function CmdHelpAbout() as BOOL

		declare function GetWikiListItem() as TString
		declare function CmdWikiLogin() as BOOL
		declare function CmdWikiPageList( byval bForce as BOOL ) as BOOL
		declare function CmdWikiOpen( byref pagename as TString ) as BOOL
		declare function CmdWikiPreview() as BOOL
		declare function CmdWikiSpellCheck( byval bNext as BOOL ) as BOOL
		
		'' FILTER
		declare function OnFilterChange() as BOOL

		'' LIST
		declare function OnListDblClick() as BOOL
		
		'' MISC
		declare function LogClear() as BOOL
		declare function LogPrint( byval text as LPCTSTR ) as BOOL

end type

#define GetMainWindowPtr( hwnd ) _
	(cast(MainWindow ptr, CWindowInfo.GetWindowPtr( hwnd )))

#endif

