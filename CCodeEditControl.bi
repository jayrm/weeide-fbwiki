#ifndef __CCODEEDITCONTROL_INCLUDE__
#define __CCODEEDITCONTROL_INCLUDE__

#include once "CWindow.bi"
#include once "CWindowInfo.bi"
#include once "TString.bi"

type CCodeEditControl

	private:
		'' Extends CWindow, must be first
		as CWindow _hwnd
		as CWindowInfo _info
		as HINSTANCE _hInstance
		as HFONT _fnt

		declare function SelfRegister() as BOOL

	public:
		declare constructor ()
		declare destructor ()

		declare function GetHwnd() as HWND
		declare operator cast() as HWND

		declare static function WordBreakProc _
			( _
				byval s as WCHAR ptr, _
				byval i as integer, _
				byval n as integer, _
				byval code as integer _
			) as integer

		declare function GetModify() as BOOL
		declare function SetModify( byval flag as BOOL ) as BOOL
		declare function GetSelText() as TString
		declare function ReplaceSel( byref s as TString ) as BOOL
		declare function GetText() as TString
		declare function SetText( byref s as TString ) as BOOL

		declare static function EditProc _
			( _
				byval hwnd as HWND, _
				byval uMsg as UINT, _
				byval wParam as WPARAM, _
				byval lParam as LPARAM  _
			) as LRESULT

		declare function Create _
			( _
				byval wordwrap as BOOL, _
				byval rc as RECT ptr, _
				byval hwndParent as HWND, _
				byval id as integer _
			) as BOOL

		declare function OpenFile( byval filename as TCHAR ptr ) as BOOL
		declare function SaveFile( byval filename as TCHAR ptr ) as BOOL
		declare function TabIndent( byval bOutdent as BOOL ) as BOOL
		declare function FindNext( byval fnd as FINDCTX ptr ) as BOOL
		declare function NextWord() as BOOL
		declare function HideSelection( byval fHide as BOOL, byval fChangeStyle as BOOL ) as BOOL

end type

#endif
