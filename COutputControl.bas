#include once "windows.bi"
#include once "win/richedit.bi"
#include once "win/commdlg.bi"
#include once "common.bi"

#include once "weeide.bi"
#include once "TString.bi"
#include once "COutputControl.bi"
#include once "utils.bi"

#define MYCLASSNAME TEXT( "Output" )

static shared as WNDPROC _orgeditproc = NULL
static shared as integer _orgeditcbbytes

#define GetOutputControlPtr( hwnd ) _
	(cast(COutputControl ptr, CWindowInfo.GetWindowPtr( hwnd )))

''
constructor COutputControl()
	_hwnd = NULL
	_hInstance = NULL
	_fnt = NULL
	_LogPrintMutex = MutexCreate()
end constructor

destructor COutputControl()
	if( _fnt ) then
		DeleteObject( _fnt )
		_fnt = NULL
	end if
	if( _LogPrintMutex ) then
		MutexDestroy _LogPrintMutex
		_LogPrintMutex = NULL
	end if
end destructor


''
operator COutputControl.Cast() as HWND
	return _hwnd
end operator

function COutputControl.HideSelection( byval fHide as BOOL, byval fChangeStyle as BOOL ) as BOOL 
	return SendMessage( _hwnd, EM_HIDESELECTION, fHide, fChangeStyle )
end function

'' --------------------------------------------------------
'' The superclasses edit procedure
'' --------------------------------------------------------
function COutputControl.EditProc _
	( _
		byval hwnd as HWND, _
		byval uMsg as UINT, _
		byval wParam as WPARAM, _
		byval lParam as LPARAM _
	) as LRESULT

	'' We are superclassing the Rich Edit Control, so we can use COutputControl	
	dim as COutputControl ptr _this = GetOutputControlPtr( hwnd )

	'' call the original window proc
	return CallWindowProc( _orgeditproc, hwnd, uMsg, wParam, lParam )

end function

function COutputControl.SelfRegister() as BOOL

	static as BOOL bClassRegistered = FALSE

	dim as WNDCLASS wcls

	if( bClassRegistered = FALSE ) then
	
		'' superclass the richedit control
		if( GetClassInfo( _hInstance, TEXT( "EDIT" ), @wcls ) = FALSE ) then
			Application.ErrorMessage( GetLastError(), TEXT( "Unable to superclass the edit control." ))
			return NULL
		end if

		'' save this, we'll need it later.
		_orgeditproc = wcls.lpfnWndProc
		_orgeditcbbytes = wcls.cbWndExtra

		wcls.lpfnWndProc   = procptr( COutputControl.EditProc )
		wcls.hInstance     = _hInstance
		wcls.lpszMenuName  = NULL
		wcls.lpszClassName = @MYCLASSNAME

		'' Register the superclassed richedit class     
		if( RegisterClass( @wcls ) = FALSE ) then
			Application.ErrorMessage( GetLastError(), TEXT( "Could not register the Output class" ))
			return NULL
		end if

		bClassRegistered = TRUE
	end if

	return bClassRegistered

end function

function COutputControl.Create _
	( _
		byval wordwrap as BOOL, _
		byval rc as RECT ptr, _
		byval hwndParent as HWND, _
		byval id as integer _
	) as BOOL

	dim as DWORD styles

	'' must have a parent
	if( hwndParent = NULL ) then
		return FALSE
	end if

	_hInstance = cast(HINSTANCE, GetWindowLong( hwndParent, GWL_HINSTANCE ))

	'' make sure our class is registered
	if( SelfRegister() = FALSE ) then
		return FALSE
	end if

	styles = WS_VISIBLE or WS_CHILD or ES_MULTILINE or ES_SAVESEL _
				or ES_WANTRETURN or WS_VSCROLL or ES_AUTOHSCROLL or ES_AUTOVSCROLL

	if( wordwrap = FALSE ) then
		styles or= WS_HSCROLL 
	end if

	dim as RECT tmprc = (0,0,0,0)
	if( rc = NULL ) then
		rc = @tmprc
	end if

	'' Create the superclassed edit control for the window
	_hwnd = CreateWindowEx( WS_EX_CLIENTEDGE, _
				MYCLASSNAME, NULL, _
				styles, _
				0, 0, rc->right-rc->left, rc->bottom-rc->top, _
				hwndParent, 0, _hInstance, NULL )

	'' Initialize the edit control
	if( _hwnd ) then

		_info.SetWindowInfo( _hwnd, @this )

		'' Set read-only
		'' SendMessage( _hwnd, EM_SETREADONLY, TRUE, 0 );

		_fnt = CreateFixedFont( -11 )
		SendMessage( _hwnd, WM_SETFONT, cast(WPARAM, _fnt), TRUE )

		return TRUE
	end if

	return FALSE

end function

''
function COutputControl.LogPrint( byval s as LPCTSTR ) as BOOL

	'' We are assuming 's' will never exceed the max size allowed by
	'' the edit control.

	'' cheap (and slow) message log sync
	MutexLock _LogPrintMutex
	
	dim as DWORD startpos = 0, endpos = 0
	dim as DWORD editsize = GetWindowTextLength( _hwnd )
	dim as DWORD length = lstrlen( s )
	SendMessage( _hwnd, EM_GETSEL, cast(WPARAM, @startpos), cast(LPARAM, @endpos ) )

	SendMessage( _hwnd, WM_SETREDRAW, FALSE, 0 )

	if( editsize + length > 32000 ) then

		'' Need to remove some text
		SendMessage( _hwnd, EM_SETSEL, 0, length )
		SendMessage( _hwnd, EM_REPLACESEL, FALSE, cast(LPARAM, @TEXT( "" )) )
		editsize -= length
		'' !!! TODO: clean to EOL
	
	end if

	SendMessage( _hwnd, EM_SETSEL, editsize, editsize )
	SendMessage( _hwnd, EM_REPLACESEL, FALSE, cast(LPARAM, s ) )
	SendMessage( _hwnd, EM_SETSEL, editsize + length, editsize + length )

	SendMessage( _hwnd, WM_SETREDRAW, TRUE, 0 )
	InvalidateRect( _hwnd, NULL, TRUE )

	SendMessage( _hwnd, EM_SCROLLCARET, 0, 0 )

	MutexUnlock _LogPrintMutex

	return TRUE

end function

''
function COutputControl.LogClear() as BOOL
	SendMessage( _hwnd, EM_SETSEL, 0, -1 )
	SendMessage( _hwnd, EM_REPLACESEL, 0, cast(LPARAM, @TEXT( "" )) )
	return TRUE
end function
