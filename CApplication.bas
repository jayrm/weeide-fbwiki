#include once "windows.bi"
#include once "win/commdlg.bi"
#include once "common.bi"

#include once "TString.bi"
#include once "CWindow.bi"
#include once "CApplication.bi"

''
static shared as TCHAR ptr filterAllFiles = @ _
	TEXT( "All Files (*.*)\0*.*\0" ) _
	TEXT( "\0" )

static shared as TCHAR ptr filterBasicFiles = @ _
	TEXT( "Basic Files (.bas.bi.rc)\0*.bas;*.bi;*.rc\0" ) _
	TEXT( "Text Files (.ini.txt)\0*.ini;*.txt\0" ) _
	TEXT( "All Files (*.*)\0*.*\0" ) _
	TEXT( "\0" )

''
constructor CApplication()
	_hwnd = NULL
	_hwndDlg = NULL
end constructor

''
destructor CApplication()
end destructor

''
function CApplication.GetHwnd() as HWND
	return _hwnd
end function

''
sub CApplication.SetHwnd( byval newHwnd as HWND )
	_hwnd = newHwnd
end sub

''
function CApplication.PromptOpenFile _
	( _
		byval hwnd as HWND, _
		byref filename as TString _
	) as BOOL

	dim as OPENFILENAME ofn

	static as TCHAR buffer(0 to MAX_PATH)
	static as DWORD flags = OFN_PATHMUSTEXIST or OFN_EXPLORER or OFN_LONGNAMES
	static as TCHAR ptr title = @ TEXT( "Open File ..." )

	ZeroMemory( @ofn, sizeof( ofn ) )

	ofn.lStructSize = sizeof( OPENFILENAME )
	ofn.hwndOwner = hwnd
	ofn.hInstance = GetModuleHandle( NULL )
	ofn.lpstrFilter = filterBasicFiles
	ofn.lpstrCustomFilter = NULL
	ofn.nMaxCustFilter = 0
	ofn.nFilterIndex = 1
	ofn.lpstrFile = @buffer(0)
	ofn.nMaxFile = MAX_PATH
	ofn.lpstrFileTitle = NULL
	ofn.nMaxFileTitle = 0
	ofn.lpstrInitialDir = NULL
	ofn.lpstrTitle = title
	ofn.Flags = flags

	if( GetOpenFileName( @ofn ) ) then
		filename = @buffer(0)
		return TRUE
	endif

	return FALSE

end function

''
function CApplication.PromptSaveFile _
	( _
		byval hwnd as HWND, _
		byref filename as TString _
	) as BOOL

	dim as OPENFILENAME ofn

	static as TCHAR buffer(0 to MAX_PATH)
	static as DWORD flags = OFN_PATHMUSTEXIST or OFN_EXPLORER or OFN_LONGNAMES
	static as TCHAR ptr title = @ TEXT( "Save File As" )

	ZeroMemory( @ofn, sizeof( ofn ) )

	'' !!! TODO: initialize lpstrFile with filename;

	ofn.lStructSize = sizeof( OPENFILENAME )
	ofn.hwndOwner = hwnd
	ofn.hInstance = GetModuleHandle( NULL )
	ofn.lpstrFilter = filterBasicFiles
	ofn.lpstrCustomFilter = NULL
	ofn.nMaxCustFilter = 0
	ofn.nFilterIndex = 1
	ofn.lpstrFile = @buffer(0)
	ofn.nMaxFile = MAX_PATH
	ofn.lpstrFileTitle = NULL
	ofn.nMaxFileTitle = 0
	ofn.lpstrInitialDir = NULL
	ofn.lpstrTitle = title
	ofn.Flags = flags

	if( GetSaveFileName( @ofn ) ) then
		filename = @buffer(0)
		return TRUE
	end if

	return FALSE

end function

'' 
function CApplication.GetFileID as integer
	static as integer counter = 0
	counter += 1
	return counter
end function

''

function CApplication.GetActiveDlgHwnd() as HWND
	return _hwndDlg
end function

function CApplication.SetActiveDlgHwnd( byval hwnd as HWND, byval fActivate as BOOL )as BOOL

	if( fActivate ) then
		_hwndDlg = hwnd
	else
		_hwndDlg = NULL
	end if
	return TRUE

end function

function CApplication.ErrorMessage( byval errcode as DWORD, byval errmsg as LPTSTR, byval style as DWORD ) as integer

	dim as TCHAR ptr lpMsgBuf
	dim as TString msg

	if( errmsg ) then
		msg = errmsg
	end if

	if( errcode ) then
	
		if( FormatMessage( _
			FORMAT_MESSAGE_ALLOCATE_BUFFER or FORMAT_MESSAGE_FROM_SYSTEM, _
			NULL, _
			errcode, _
			MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), _
			cast(LPTSTR, @lpMsgBuf), _
			0, _
			NULL _
			) ) then

			msg += lpMsgBuf

			'' Free the buffer.
			LocalFree( lpMsgBuf )
		
		else

			'' Error displaying a message, Display fallback message
			msg += TEXT( "Error ")
			msg += TString.ToStr( errcode )

		end if

	end if

	'' Show the message
	style or= MB_ICONERROR or MB_TASKMODAL
	return ..MessageBox( _hwnd, msg, Title, style )

end function

function CApplication.MessageBox( byval msg as LPTSTR, byval style as DWORD ) as integer
	style or= MB_TASKMODAL
	return ..MessageBox( _hwnd, msg, Title, style )
end function
