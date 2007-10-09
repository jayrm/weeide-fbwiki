#include once "windows.bi"
#include once "common.bi"

#include once "weeide.bi"
#include once "weeide_about.bi"

function CAboutDialog.DialogProc( _
		byval hwnd as HWND, _
		byval uMsg as UINT, _
		byval wParam_ as WPARAM, _
		byval lParam_ as LPARAM _ 
	) as BOOL

	dim as CAboutDialog ptr _this

	if( uMsg = WM_INITDIALOG ) then
	
		'' attach a pointer to our class in the window's user data
		SetWindowLong( hwnd, DWL_USER, lParam_ )

		SendMessage( _
			GetDlgItem( hwnd, IDC_ABOUT_ICON ), _
			STM_SETIMAGE, _
			IMAGE_ICON, _
			cast(LPARAM, LoadIcon( GetModuleHandle(NULL), MAKEINTRESOURCE( IDI_WEEIDE_LARGE ) )) _
			)

		'' TODO: Set title font and
		'' set control contents from Application, string resource
		'' or other.

		return TRUE
	
	end if

	_this = cast(CAboutDialog ptr, GetWindowLong( hwnd, DWL_USER ))

	select case uMsg
	case WM_ACTIVATE:
		Application.SetActiveDlgHwnd( hwnd, wParam_ )
		return TRUE

	case WM_COMMAND:
		EndDialog( hwnd, FALSE )
		return TRUE

	end select

	return FALSE

end function

function CAboutDialog.Show( byval hwndParent as HWND ) as BOOL

	'' Dialog is modal
	return	DialogBoxParam( _
		GetModuleHandle(NULL), _
		MAKEINTRESOURCE(IDD_ABOUT), _
		hwndParent, _
		cast(DLGPROC, procptr( CAboutDialog.DialogProc )), _
		cast(LPARAM, @this ) _
	)

	'' TODO: so this is the same as some of the other classes
	'' it should probably have a static InitInstance() method
	'' also
end function