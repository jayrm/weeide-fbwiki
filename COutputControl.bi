#ifndef __COUTPUTCONTROL_INCLUDE__
#define __COUTPUTCONTROL_INCLUDE__

#include once "CWindow.bi"
#include once "CWindowInfo.bi"
#include once "TString.bi"

type COutputControl

	private:
		'' Extends CWindow, must be first
		as CWindow _hwnd
		as HINSTANCE _hInstance
		as HFONT _fnt
		as any ptr _LogPrintMutex
		as CWindowInfo _info

		declare function SelfRegister() as BOOL

	public:
		declare constructor ()
		declare destructor ()

		declare operator cast() as HWND

		declare function HideSelection( byval fHide as BOOL, byval fChangeStyle as BOOL ) as BOOL

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

		declare function LogClear() as BOOL
		declare function LogPrint( byval text as LPCTSTR ) as BOOL

end type

#endif
