#include "windows.bi"
#include "common.bi"

#include "utils.bi"

static shared as WCHAR ptr whitespace = @WSTR(!" \t")
static shared as WCHAR ptr linebreaks = @WSTR(!"\r\n")
static shared as WCHAR ptr delimiters = @WSTR(!"`~!$%^&*()-=+[]{};:'\",.<>/?|\\")
static shared as WCHAR ptr extrasymbs = @WSTR(!"_@#")

'' We don't have this in win*.bi
declare function GetStringTypeW alias "GetStringTypeW" (byval as DWORD, byval as LPCWSTR, byval as integer, byval as LPWORD) as BOOL

function IsCharAnySpace( byval s as WCHAR ) as BOOL
	dim as WORD result
	GetStringTypeW( CT_CTYPE1, @s, 1, @result )
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
	GetStringTypeW( CT_CTYPE1, @s, 1, @result )
	return iif( (result and ( C1_ALPHA or C1_DIGIT )), TRUE, FALSE )
end function

function IsCharPunct( byval s as WCHAR ) as BOOL
	dim as WORD result
	GetStringTypeW( CT_CTYPE1, @s, 1, @result )
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
