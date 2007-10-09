#ifndef __UTILS_INCLUDE__
#define __UTILS_INCLUDE__

declare function IsCharAnySpace( byval s as WCHAR ) as BOOL
declare function IsCharWhiteSpace( byval s as WCHAR ) as BOOL
declare function IsCharLineBreak( byval s as WCHAR ) as BOOL
declare function IsCharDelimiter( byval s as WCHAR ) as BOOL
declare function IsCharSymbol( byval s as WCHAR ) as BOOL
declare function IsCharPunct( byval s as WCHAR ) as BOOL
declare function IsCharInString( byval s as WCHAR, byval lst as WCHAR ptr ) as BOOL

declare function CreateFixedFont( byval size as integer ) as HFONT
declare function CreateSwissFont( byval size as integer ) as HFONT

#endif

