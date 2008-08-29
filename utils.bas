#include "windows.bi"
#include "common.bi"

#include "utils.bi"

static shared as WCHAR ptr whitespace = @WSTR(!" \t")
static shared as WCHAR ptr linebreaks = @WSTR(!"\r\n")
static shared as WCHAR ptr delimiters = @WSTR(!"`~!$%^&*()-=+[]{};:'\",.<>/?|\\")
static shared as WCHAR ptr extrasymbs = @WSTR(!"_@#")

'' We don't have this in win*.bi
declare function GetStringTypeW alias "GetStringTypeW" ( byval as DWORD, byval as LPCWSTR, byval as integer, byval as LPWORD) as BOOL
declare function GetStringTypeA alias "GetStringTypeA" ( byval locale as LCID, byval as DWORD, byval as LPCSTR, byval as integer, byval as LPWORD) as BOOL

private function UtilGetStringType _
	( _
		byval dwInfoType as DWORD, _
		byval lpSrcStr as LPCWSTR , _
		byval cchSrc as integer, _
		byval lpCharType as LPWORD _
	) as BOOL

	static as BOOL isInited = FALSE, isWin9x = FALSE

	if( isInited = FALSE ) then

		dim as OSVERSIONINFO ver = ( sizeof( OSVERSIONINFO ) )
		if( GetVersionEx( @ver ) ) then
		
			if( ver.dwPlatformId = VER_PLATFORM_WIN32_WINDOWS ) then
				isWin9x = TRUE
			end if

		end if

		isInited = TRUE
	
	end if

	if( isWin9x ) then

		'' Windows 9x, our RichEdit control returns Unicode, but GetStringTypeW won't work.
		'' So instead we call it as though it is ascii.

		return GetStringTypeA( _
			MAKELCID( MAKELANGID( LANG_NEUTRAL, SUBLANG_DEFAULT ), SORT_DEFAULT ), _
			dwInfoType, cast(CHAR ptr, lpSrcStr), cchSrc, lpCharType )

	else

		'' Windows NT - the wide char version is implemented
		return GetStringTypeW( dwInfoType, lpSrcStr, cchSrc, lpCharType )
	
	end if

end function

function IsCharAnySpace( byval s as WCHAR ) as BOOL

	dim as WORD result
	UtilGetStringType( CT_CTYPE1, @s, 1, @result )
	return iif( result and C1_SPACE, TRUE, FALSE )

end function

function IsCharWhiteSpace( byval s as WCHAR ) as BOOL

	return IsCharInString( s, whitespace )

end function

function IsCharLineBreak( byval s as WCHAR ) as BOOL

	return IsCharInString( s, linebreaks )

end function

function IsCharDelimiter( byval s as WCHAR ) as BOOL

	return IsCharInString( s, delimiters )

end function

function IsCharSymbol( byval s as WCHAR ) as BOOL

	dim as WORD result

	if( IsCharInString( s, extrasymbs )) then
		return TRUE
	end if

	UtilGetStringType( CT_CTYPE1, @s, 1, @result )
	return iif( (result and ( C1_ALPHA or C1_DIGIT )), TRUE, FALSE )

end function

function IsCharPunct( byval s as WCHAR ) as BOOL

	dim as WORD result

	UtilGetStringType( CT_CTYPE1, @s, 1, @result )
	return iif( ( result and ( C1_PUNCT )), TRUE, FALSE )

end function

function IsCharInString( byval s as WCHAR, byval lst as WCHAR ptr ) as BOOL

	if( lst ) then
		while ( *lst )
			if( s = *lst ) then
				return TRUE
			end if
			lst += 1
		wend
	end if

	return FALSE

end function

'' --------------------------------------------------------

function CreateFixedFont( byval size as integer ) as HFONT

	dim as HFONT _fnt = NULL

	'' Fixed spacing font
	dim as LOGFONT lf
	lf.lfHeight = -11
	lf.lfWidth = 0
	lf.lfEscapement = 0
	lf.lfOrientation = 0
	lf.lfWeight = FW_NORMAL
	lf.lfItalic = FALSE
	lf.lfUnderline = FALSE
	lf.lfStrikeOut = FALSE
	lf.lfCharSet = ANSI_CHARSET
	lf.lfOutPrecision = OUT_DEFAULT_PRECIS
	lf.lfClipPrecision = CLIP_DEFAULT_PRECIS
	lf.lfQuality = DEFAULT_QUALITY
	lf.lfPitchAndFamily = FIXED_PITCH or FF_MODERN
	lstrcpy(lf.lfFaceName, TEXT("Courier New") ) 
	'' lf.lfFaceName[LF_FACESIZE]

	_fnt = CreateFontIndirect(@lf)

	function = _fnt
	
end function

function CreateSwissFont( byval size as integer ) as HFONT

	dim as HFONT _fnt = NULL

	'' Fixed spacing font
	dim as LOGFONT lf
	lf.lfHeight = -11
	lf.lfWidth = 0
	lf.lfEscapement = 0
	lf.lfOrientation = 0
	lf.lfWeight = FW_NORMAL
	lf.lfItalic = FALSE
	lf.lfUnderline = FALSE
	lf.lfStrikeOut = FALSE
	lf.lfCharSet = ANSI_CHARSET
	lf.lfOutPrecision = OUT_DEFAULT_PRECIS
	lf.lfClipPrecision = CLIP_DEFAULT_PRECIS
	lf.lfQuality = DEFAULT_QUALITY
	lf.lfPitchAndFamily = VARIABLE_PITCH or FF_MODERN
	lstrcpy(lf.lfFaceName, TEXT("Arial") ) 
	'' lf.lfFaceName[LF_FACESIZE]

	_fnt = CreateFontIndirect(@lf)

	function = _fnt

end function
