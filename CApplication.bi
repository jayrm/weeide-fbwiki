#ifndef __CAPPLICATION_INCLUDE__
#define __CAPPLICATION_INCLUDE__

#include once "TString.bi"
#include once "CWindow.bi"

type CApplication

	private:
		as CWindow _hwnd
		as CWindow _hwndDlg

	public:
		declare constructor ()
		declare destructor ()

		as TString Name
		as TString Title
		as TString Description
		as TString Version

		declare function GetHwnd() as HWND 
		declare sub SetHwnd( byval hwnd as HWND )

		declare function PromptOpenFile _
			( _
				byval hwnd as HWND, _
				byref filename as TString _
			) as BOOL 

		declare function PromptSaveFile _
			( _
				byval hwnd as HWND, _
				byref filename as TString _
			) as BOOL 

		declare function GetFileID() as integer

		declare function GetActiveDlgHwnd() as HWND
		declare function SetActiveDlgHwnd( byval hwnd as HWND, byval fActivate as BOOL ) as BOOL

		declare function ErrorMessage( byval errcode as DWORD, byval errmsg as LPTSTR, byval style as DWORD = MB_OK ) as integer
		declare function MessageBox(byval msg as LPTSTR, byval style as DWORD = MB_OK ) as integer

end type

#endif