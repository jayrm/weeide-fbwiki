#include once "windows.bi"
#include once "win/richedit.bi"
#include once "common.bi"

#include once "weeide.bi"
#include once "weeide_find.bi"

'' --------------------------------------------------------
constructor CFindDialog()

	_hwnd = NULL
	_hwndParent = NULL
	_sFind.Clear()
	ZeroMemory( @_data, sizeof( FINDCTX ))

end constructor

destructor CFindDialog()
end destructor

'' --------------------------------------------------------
function CFindDialog.IsVisible() as BOOL
	return IsWindowVisible( _hwnd )
end function

function CFindDialog.SetFindText( byval txt as TCHAR ptr ) as BOOL
	_sFind = txt
	return TRUE
end function

function CFindDialog.GetFindText() as TCHAR ptr
	return _sFind.GetPtr()
end function

'' --------------------------------------------------------
'' COMMANDS
'' --------------------------------------------------------
function CFindDialog.Show() as BOOL
	if( _hwnd ) then

		if( IsWindowVisible( _hwnd ) = FALSE ) then
			LoadData()
		end if

		ShowWindow( _hwnd, SW_SHOW )
		SetFocus( GetDlgItem( _hwnd, IDC_FIND ))
		return TRUE

	end if

	return FALSE

end function

function CFindDialog.Hide() as BOOL
	if( _hwnd ) then
		ShowWindow( _hwnd, SW_HIDE )
		return TRUE
	end if
	return FALSE
end function

function CFindDialog.SaveData() as BOOL
	
	dim as integer length = GetWindowTextLength( GetDlgItem( _hwnd, IDC_FIND ))

	if( length <= 0 ) then
		return FALSE
	end if

	_sFind.SetSize( length )
	GetDlgItemText( _hwnd, IDC_FIND, _
		_sFind.GetPtr(), _sFind.GetSize() )
	_data.sFind = _sFind.GetPtr()

	if( IsDlgButtonChecked( _hwnd, IDC_SEARCHALL )) then
		_data.flags or= FINDFLAG_SEARCHOPENDOCS
	else
		_data.flags and= not FINDFLAG_SEARCHOPENDOCS
	end if

	if( IsDlgButtonChecked( _hwnd, IDC_MATCHCASE )) then
		_data.flags or= FINDFLAG_MATCHCASE
	else
		_data.flags and= not FINDFLAG_MATCHCASE
	end if

	if( IsDlgButtonChecked( _hwnd, IDC_MATCHWORD )) then
		_data.flags or= FINDFLAG_WHOLEWORD
	else
		_data.flags and= not FINDFLAG_WHOLEWORD
	end if

	if( IsDlgButtonChecked( _hwnd, IDC_DIRECTION_UP )) then
		_data.flags or= FINDFLAG_UP
	else
		_data.flags and= not FINDFLAG_UP
	end if

	return TRUE

end function

function CFindDialog.LoadData() as BOOL

	SetDlgItemText( _hwnd, IDC_FIND, _sFind )

	if( _data.flags and FINDFLAG_SEARCHOPENDOCS ) then
		CheckDlgButton( _hwnd, IDC_SEARCHALL, BST_CHECKED )
	else
		CheckDlgButton( _hwnd, IDC_SEARCHALL, BST_UNCHECKED )
	end if

	if( _data.flags and FINDFLAG_MATCHCASE ) then
		CheckDlgButton( _hwnd, IDC_MATCHCASE, BST_CHECKED )
	else
		CheckDlgButton( _hwnd, IDC_MATCHCASE, BST_UNCHECKED )
	end if

	if( _data.flags and FINDFLAG_WHOLEWORD ) then
		CheckDlgButton( _hwnd, IDC_MATCHWORD, BST_CHECKED )
	else
		CheckDlgButton( _hwnd, IDC_MATCHWORD, BST_UNCHECKED )
	end if

	if( _data.flags and FINDFLAG_UP ) then
		CheckRadioButton( _hwnd, IDC_DIRECTION_UP, IDC_DIRECTION_DOWN, IDC_DIRECTION_UP )
	else
		CheckRadioButton( _hwnd, IDC_DIRECTION_UP, IDC_DIRECTION_DOWN, IDC_DIRECTION_DOWN )
	end if

	return TRUE

end function

function CFindDialog.FindNext() as BOOL
	return SendMessage( _hwndParent, WM_APP_FINDTEXT, 0, cast(LPARAM, @_data ))
end function

'' --------------------------------------------------------
'' WM_COMMAND
'' --------------------------------------------------------
function CFindDialog.OnCommand( byval wParam as WPARAM, byval lParam as LPARAM ) as BOOL

	select case LOWORD( wParam )
	case IDOK:
		if( SaveData() ) then
			FindNext()
			return TRUE
		end if

	case IDCANCEL:
		EndDialog( _hwnd, FALSE )
		return TRUE

	case else:
		return FALSE

	end select

	return FALSE

end function

'' --------------------------------------------------------
'' The FindWindow's DLGPROC
'' --------------------------------------------------------
function CFindDialog.DialogProc( _
		byval hwnd as HWND, _
		byval uMsg as UINT, _
		byval wParam as WPARAM, _
		byval lParam as LPARAM _
	) as BOOL

	dim as CFindDialog ptr _this

	if( uMsg = WM_INITDIALOG ) then
		'' attach a pointer to our class in the window's user data
		SetWindowLong( hwnd, DWL_USER, lParam )
		return FALSE
	end if

	_this = cast(CFindDialog ptr, GetWindowLong( hwnd, DWL_USER ))

	select case ( uMsg )
	case WM_ACTIVATE:
		Application.SetActiveDlgHwnd( _this->_hwnd, wParam )
		SetFocus( GetDlgItem( hwnd, IDC_FIND ))
		return TRUE

	case WM_COMMAND:
		return _this->OnCommand( wParam, lParam )

	case else
		return FALSE

	end select

end function

'' --------------------------------------------------------
'' Create the find window
'' --------------------------------------------------------
function CFindDialog.InitInstance( byval hwndParent as HWND ) as CFindDialog ptr

	dim as CFindDialog ptr _this

	'' must have a parent
	if( hwndParent = NULL ) then
		return NULL
	end if

	'' create our class
	_this = new CFindDialog
	if( _this = NULL ) then
		return NULL
	end if

	_this->_hwnd = CreateDialogParam( _
				GetModuleHandle(NULL), _
				MAKEINTRESOURCE(IDD_FIND), _
				hwndParent, _
				cast(DLGPROC, procptr( CFindDialog.DialogProc)), _
				cast(LONG, _this ) _
			)

	if( _this->_hwnd.IsNull() ) then
		delete _this
		return NULL
	end if

	_this->_hwndParent = hwndParent

	return _this
end function
