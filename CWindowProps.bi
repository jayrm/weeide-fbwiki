#ifndef __CWINDOWPROPS_INCLUDE__
#define __CWINDOWPROPS_INCLUDE__

#include once "TString.bi"
#include once "CWindow.bi"

type CWindowProps

	private:
		as CWindow _hwnd
		as TString _title
		as TString _filename
		as BOOL _changed

		declare sub UpdateDisplayTitle()

	public:
		declare constructor()
		declare destructor()

		declare function GetHwnd() as HWND
		declare sub SetHwnd( byval hwnd as HWND )

		declare function GetFileName() as TString
		declare sub SetFileName( byref filename as TString )
		declare sub SetFileName( byval filename as TCHAR ptr )
		declare function GetHasFileName() as BOOL

		declare function GetTitle() as TString
		declare sub SetTitle( byref title as TString )
		declare function GetDisplayTitle() as TString
		declare sub SetDisplayTitle( byref title as TString )
	
		declare function GetModify() as BOOL
		declare sub SetModify( byval flag as BOOL )

end type

#endif