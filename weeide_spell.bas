#include once "windows.bi"
#include once "win/richedit.bi"
#include once "common.bi"

#include once "weeide.bi"
#include once "weeide_spell.bi"
#include once "spellcheck.bi"

'' --------------------------------------------------------
constructor CSpellCheckDialog()

	_hwnd = NULL
	_hwndParent = NULL
	_sWord.Clear()
	ZeroMemory( @_data, sizeof( SPELLCTX ))

end constructor

destructor CSpellCheckDialog()
end destructor

'' --------------------------------------------------------
function CSpellCheckDialog.IsVisible() as BOOL
	return IsWindowVisible( _hwnd )
end function

function CSpellCheckDialog.SetCheckText( byval txt as TCHAR ptr ) as BOOL
	_sWord = txt
	LoadData()
	return TRUE
end function

function CSpellCheckDialog.GetCheckText() as TCHAR ptr
	return _sWord.GetPtr()
end function

'' --------------------------------------------------------
'' COMMANDS
'' --------------------------------------------------------
function CSpellCheckDialog.Show() as BOOL
	if( _hwnd ) then

		if( IsWindowVisible( _hwnd ) = FALSE ) then
			LoadData()
		end if

		ShowWindow( _hwnd, SW_SHOW )
		SetFocus( GetDlgItem( _hwnd, IDC_SPELL_WORD_EDIT ))
		return TRUE

	end if

	return FALSE

end function

function CSpellCheckDialog.Hide() as BOOL
	
	if( _hwnd ) then
		ShowWindow( _hwnd, SW_HIDE )
		return TRUE
	end if

	return FALSE
end function

function CSpellCheckDialog.SaveData() as BOOL

	return TRUE

end function

function CSpellCheckDialog.LoadData() as BOOL

	SetDlgItemText( _hwnd, IDC_SPELL_WORD_EDIT, _sWord )

	dim as integer i, n
	dim as HWND ctl
	dim as string s

	n = SpellCheck_GetWordCount()
	ctl = GetDlgItem( _hwnd, IDC_SPELL_SUGGEST_LIST )

	SendMessage(ctl, LB_RESETCONTENT, 0, 0)

	for i = 0 to n - 1
		s = SpellCheck_GetWord( i )
		SendMessage(ctl, LB_ADDSTRING, 0, cast(LPARAM,strptr(s)))
	next

	return TRUE

end function

function CSpellCheckDialog.CheckNext() as BOOL
	return SendMessage( _hwndParent, WM_APP_SPELLTEXT, 0, cast(LPARAM, @_data ))
end function

'' --------------------------------------------------------
private function GetListItem( byval ctl as HWND ) as TString

	dim as TString ret
	dim as integer i, size

	'' !!! TODO: we should really have a CListBox

	if ( ctl ) then
	
		i = SendMessage( ctl, LB_GETCURSEL, 0, 0 )
		if( i >= 0 ) then
		
			size = SendMessage(ctl, LB_GETTEXTLEN, i, 0)
			ret.SetSize( size )
			if( size > 0 ) then
				SendMessage(ctl, LB_GETTEXT, i, cast(LPARAM, ret.GetPtr()))
			end if

		end if

	end if

	return ret
end function


'' --------------------------------------------------------
'' WM_COMMAND
'' --------------------------------------------------------
function CSpellCheckDialog.OnCommand( byval wParam as WPARAM, byval lParam as LPARAM ) as BOOL

	select case LOWORD( wParam )
	case IDC_SPELL_IGNORE:
		_data.sWord = _sWord
		_data.cmd = SPELLCMD_IGNORE
		CheckNext()
		return TRUE

	case IDC_SPELL_IGNORE_ALL:
		_data.sWord = _sWord
		_data.cmd = SPELLCMD_IGNORE_ALL
		CheckNext()
		return TRUE
	
	case IDC_SPELL_ADD:
		_data.sWord = _sWord
		_data.cmd = SPELLCMD_ADD
		CheckNext()
		return TRUE
	
	case IDC_SPELL_CHANGE:
		_data.sWord = _sWord
		_data.cmd = SPELLCMD_CHANGE
		CheckNext()
		return TRUE
	
	case IDC_SPELL_CHANGE_ALL:
		_data.sWord = _sWord
		_data.cmd = SPELLCMD_CHANGE_ALL
		CheckNext()
		return TRUE

	case IDC_SPELL_SUGGEST_LIST:
        select case (HIWORD(wParam))
		case LBN_SELCHANGE:
			_sWord = GetListItem( GetDlgItem( _hwnd, IDC_SPELL_SUGGEST_LIST ) )
		case LBN_DBLCLK:
			_sWord = GetListItem( GetDlgItem( _hwnd, IDC_SPELL_SUGGEST_LIST ) )
			_data.sWord = _sWord
			_data.cmd = SPELLCMD_CHANGE
			CheckNext()
		end select
		return TRUE

	case IDCANCEL:
		EndDialog( _hwnd, FALSE )
		return TRUE

	case else:
		return FALSE

	end select

	return FALSE

end function

'' --------------------------------------------------------
'' The Spell Check Window's DLGPROC
'' --------------------------------------------------------
function CSpellCheckDialog.DialogProc( _
		byval hwnd as HWND, _
		byval uMsg as UINT, _
		byval wParam as WPARAM, _
		byval lParam as LPARAM _
	) as BOOL

	dim as CSpellCheckDialog ptr _this

	if( uMsg = WM_INITDIALOG ) then
		'' attach a pointer to our class in the window's user data
		SetWindowLong( hwnd, DWL_USER, lParam )
		return FALSE
	end if

	_this = cast(CSpellCheckDialog ptr, GetWindowLong( hwnd, DWL_USER ))

	select case ( uMsg )
	case WM_ACTIVATE:
		Application.SetActiveDlgHwnd( _this->_hwnd, wParam )
		SetFocus( GetDlgItem( hwnd, IDC_SPELL_IGNORE ))
		return TRUE

	case WM_COMMAND:
		return _this->OnCommand( wParam, lParam )

	case else
		return FALSE

	end select

end function

'' --------------------------------------------------------
'' Create the spell check window
'' --------------------------------------------------------
function CSpellCheckDialog.InitInstance( byval hwndParent as HWND ) as CSpellCheckDialog ptr

	dim as CSpellCheckDialog ptr _this

	'' must have a parent
	if( hwndParent = NULL ) then
		return NULL
	end if

	'' create our class
	_this = new CSpellCheckDialog
	if( _this = NULL ) then
		return NULL
	end if

	_this->_hwnd = CreateDialogParam( _
				GetModuleHandle(NULL), _
				MAKEINTRESOURCE(IDD_SPELLCHECK), _
				hwndParent, _
				cast(DLGPROC, procptr( CSpellCheckDialog.DialogProc)), _
				cast(LONG, _this ) _
			)

	if( _this->_hwnd.IsNull() ) then
		delete _this
		return NULL
	end if

	_this->_hwndParent = hwndParent

	return _this
end function
