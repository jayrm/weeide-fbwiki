#ifndef __WEEIDE_SPELL_INCLUDE__
#define __WEEIDE_SPELL_INCLUDE__

#include once "win/commdlg.bi"

type CSpellCheckDialog

	private:
		as CWindow _hwnd
		as CWindow _hwndParent
		as TString _sWord
		as SPELLCTX _data

	public:
		declare constructor ()
		declare destructor ()

		declare static function InitInstance( byval hwndParent as HWND ) as CSpellCheckDialog ptr

		declare static function DialogProc( _
			byval hwnd as HWND, _
			byval uMsg as UINT, _
			byval wParam as WPARAM, _
			byval lParam as LPARAM _
			) as LRESULT

		declare function OnCommand( byval wParam as WPARAM, byval lParam as LPARAM ) as BOOL

		declare function IsVisible() as BOOL

		declare function SetCheckText( byval txt as TCHAR ptr ) as BOOL
		declare function GetCheckText() as TCHAR ptr
		
		declare function CheckNext() as BOOL

		declare function Show() as BOOL
		declare function Hide() as BOOL
		declare function SaveData() as BOOL
		declare function LoadData() as BOOL
end type

#endif
