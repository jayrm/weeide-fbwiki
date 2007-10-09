#include once "windows.bi"
#include once "common.bi"

#include once "weeide.bi"
#include once "CWindow.bi"
#include once "mkwiki_login.bi"

function CLoginDialog.SaveData() as BOOL

	dim as integer n
	dim as TString u
	dim as TString p
	dim as CWindow ctl

	ctl = GetDlgItem( _hwnd, IDC_LOGIN_USER )
	u = ctl.GetText()

	ctl = GetDlgItem( _hwnd, IDC_LOGIN_PWD )
	p = ctl.GetText()

	if( u.GetLength() > 0 and p.GetLength() > 0 ) then
		username = u
		password = p
		return TRUE
	end if

	'' TODO: Add error message/setfocus

	return FALSE

end function

function CLoginDialog.DialogProc( _
		byval hwnd as HWND, _
		byval uMsg as UINT, _
		byval wParam_ as WPARAM, _
		byval lParam_ as LPARAM _ 
	) as BOOL

	dim as CLoginDialog ptr _this

	if( uMsg = WM_INITDIALOG ) then
		'' attach a pointer to our class in the window's user data
		SetWindowLong( hwnd, DWL_USER, lParam_ )
	end if

	_this = cast(CLoginDialog ptr, GetWindowLong( hwnd, DWL_USER ))

	select case uMsg
	case WM_INITDIALOG:
		_this->_hwnd = hwnd
		return TRUE

	case WM_ACTIVATE:
		Application.SetActiveDlgHwnd( hwnd, wParam_ )
		return TRUE

	case WM_COMMAND:
		if( wParam_ = IDOK ) then
			if( _this->SaveData() ) then
				EndDialog( hwnd, TRUE )
				return TRUE
			end if
		elseif( wParam_ = IDCANCEL ) then
			EndDialog( hwnd, FALSE )
			return TRUE
		end if

	end select

	return FALSE

end function

function CLoginDialog.Show( byval hwndParent as HWND ) as BOOL

	'' Dialog is modal
	return	DialogBoxParam( _
		GetModuleHandle(NULL), _
		MAKEINTRESOURCE(IDD_Login), _
		hwndParent, _
		cast(DLGPROC, procptr( CLoginDialog.DialogProc )), _
		cast(LPARAM, @this ) _
	)

	'' TODO: so this is the same as some of the other classes
	'' it should probably have a static InitInstance() method
	'' also
end function
