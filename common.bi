#ifndef __COMMON_INCLUDE__
#define __COMMON_INCLUDE__

#ifdef UNICODE
''#define TEXT(txt) cast(TCHAR ptr,@wstr(!##txt))
#define TEXT(txt) wstr(!##txt)
#else
''#define TEXT(txt) cast(TCHAR ptr,@!##txt)
#define TEXT(txt) !##txt
#endif



enum FINDFLAGS
	FINDFLAG_NONE = 0
	FINDFLAG_UP = 1
	FINDFLAG_MATCHCASE = 2
	FINDFLAG_WHOLEWORD = 4
	FINDFLAG_SEARCHOPENDOCS = 8
	FINDFLAG_FROMSTART = 16
	FINDFLAG_TOEND = 32
end enum

type FINDCTX
	as DWORD flags
	as TCHAR ptr sFind
end type

enum SPELLCHECKCOMMANDS
	SPELLCMD_IGNORE = 1
	SPELLCMD_IGNORE_ALL = 2
	SPELLCMD_ADD = 3
	SPELLCMD_CHANGE = 4
	SPELLCMD_CHANGE_ALL = 5
end enum

type SPELLCTX
	as DWORD cmd
	as TCHAR ptr sWord
end type

#endif
