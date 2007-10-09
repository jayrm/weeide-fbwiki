'' mkwiki* is the messy glue layer between weeide and fbdoc

#include once "windows.bi"

#include once "fbdoc_defs.bi"
#include once "CWikiCon.bi"
#include once "fbdoc_cache.bi"
#include once "fbdoc_loader.bi"
#include once "printlog.bi"

#include once "TString.bi"
#include once "CWindow.bi"
#include once "mkwiki_login.bi"

'' mkwiki_getindex.bas
declare function RefreshPageIndex ( byval bForceDownload as integer ) as integer

#inclib "fbdoc"
#inclib "curl"

#include once "common.bi"

#include once "TString.bi"
#include once "CApplication.bi"
#include once "weeide.bi"
#include once "weeide_main.bi"

using fb
using fbdoc

extern wikicon as CWikiCon ptr

dim shared wikicon as CWikiCon ptr = NULL
dim shared as string wiki_url
dim shared as string sCacheDir
dim shared as any ptr PageIndexMutex

dim shared as MainWindow ptr frmMain = NULL

dim shared as integer islogged = FALSE
dim shared as string sUsername
dim shared as string sPassword

private function mkwiki_PrintLogger( byval s as zstring ptr, byval bNoCR as integer = FALSE ) as integer
	if( frmMain ) then
		frmMain->LogPrint( s )
		if( bNoCr = FALSE ) then
			frmMain->LogPrint( TEXT( "\r\n" ) )
		end if
	end if
	return TRUE
end function

function mkwiki_HookPrintLogger( byval frm as MainWindow ptr ) as integer
	frmMain = frm
	SetPrintLogFunction( procptr(mkwiki_PrintLogger) )
	return TRUE
end function

function mkwiki_UnhookPrintLogger() as integer
	frmMain = NULL
	SetPrintLogFunction( NULL )
	return TRUE
end function

function mkwiki_Create() as integer

	'' wiki_url = "http://myweb:8080/wiki/wikka.php"
	wiki_url = "http://www.freebasic.net/wiki/wikka.php"

	sCacheDir = exepath() + "/cache/"

	'' Initialize the connection (logon will happen on first post)
	wikicon = new fb.fbdoc.CWikiCon( wiki_url )
	if wikicon = NULL then
		dim as TString msg
		msg = "Unable to create connection to " 
		msg += wiki_url
		Application.ErrorMessage( 0, msg )
		return FALSE
	end if

	'' Initialize the cache used by the doc converter / preview handler
	if LocalCache_Create( sCacheDir, fb.fbdoc.CWikiCache.CACHE_REFRESH_NONE ) = FALSE then
		delete wikicon
		dim as TString msg
		msg = "Unable to use local cache dir " 
		msg += sCacheDir
		Application.ErrorMessage( 0, msg )
		return FALSE
	end if

	PageIndexMutex = MutexCreate()

	return TRUE

end function

function mkwiki_Destroy() as integer

	mkwiki_UnhookPrintLogger()

	if( wikicon ) then
		delete wikicon
		wikicon = NULL
	end if

	LocalCache_Destroy()

	if( PageIndexMutex ) then
		MutexDestroy PageIndexMutex
	end if

	return TRUE

end function

private sub RefreshPageIndexWorker ( byval id as any ptr )

	dim as integer bForce = *cast( integer ptr, id )
	dim as integer ret
	ret = RefreshPageIndex( bForce )
	SendMessage( frmMain->GetHwnd(), WM_APP_PAGEINDEXCOMPLETED, cast(WPARAM, ret), 0 )

end sub

function mkwiki_RefreshPageIndex ( byval bForceDownload as integer ) as integer
	static as integer bForce 
	MutexLock PageIndexMutex
	bForce = bForceDownload
	dim t as any ptr = threadcreate( procptr( RefreshPageIndexWorker ), @bForce )
	MutexUnlock PageIndexMutex
	return FALSE
end function

function mkwiki_LoadPageIndexToList( byval ctl as HWND ) as integer
	
	dim as string x

	MutexLock PageIndexMutex

	function = FALSE

	if ( ctl ) then

		PrintLog "Loading Page Names ... ", TRUE

		SendMessage(ctl, LB_RESETCONTENT, 0, 0)

		dim h as integer
		h = FreeFile
		if( open( "PageIndex.txt" for input access read as #h ) = 0 ) then
			while eof(h) = 0
				line input #h, x
				if x > "" then
					SendMessage(ctl, LB_ADDSTRING, 0, cast(LPARAM,strptr(x)))
				end if
			wend
			close #h

			PrintLog "OK"
			function = TRUE

		else

			PrintLog "ERROR"

		end if

	end if

	MutexUnlock PageIndexMutex

end function

function mkwiki_LoadPage( byref sPage as string, byref sBody as string ) as integer
	return wikicon->LoadPage( sPage, TRUE, TRUE, sBody )
end function

function mkwiki_Login( byval bForce as integer ) as integer
	
	if( wikicon = NULL ) then
		return FALSE
	end if

	if( isLogged = TRUE and bForce = FALSE ) then
		return TRUE
	end if
	
	dim as CLoginDialog frm

	frm.Username = sUsername
	frm.Password = TEXT( "" )

	if( frm.Show( Application.GetHwnd() )) then
	
		dim u as string
		dim p as string

		u = *frm.Username.GetPtr()
		p = *frm.Password.GetPtr()

		if( wikicon->login( u, p ) ) then
			sUsername = u
			sPassword = p

			isLogged = TRUE
			return TRUE

		end if

	end if

	return FALSE

end function

function mkwiki_SavePage _
	( _
		byref sPage as string, _
		byref sBody as string, _
		byref sNote as string _
	) as integer

	dim sBodyOld as string

	function = FALSE

	if( mkwiki_Login( FALSE ) = FALSE ) then
		PrintLog "Unable to login"
		exit function
	end if

	if( wikicon->LoadPage( sPage, TRUE, TRUE, sBodyOld ) <> FALSE ) then
		if( wikicon->GetPageID() > 0 ) then
			' %%% if( wikicon->Login( sUserName, sPassword ) ) = FALSE then
			' %%%	print "Unable to login"
			' %%% else
				PrintLog "Storing '" + sPage + "' [" + sNote + "] : ", TRUE

				if( wikicon->StorePage( sBody, sNote ) = FALSE ) then
					PrintLog "FAILED"
				else
					PrintLog "OK"
					function = TRUE
				end if
			' %%% end if
		else
			print "Unable to get existing page ID - will try to store as a new page .."
			' %%% if( wikicon->Login( sUserName, sPassword ) ) = FALSE then
			' %%% 	print "Unable to login"
			' %%% else
				PrintLog "Storing '" + sPage + "': ", TRUE
				if( wikicon->StoreNewPage( sBody, sPage ) = FALSE ) then
					PrintLog "FAILED"
				else
					PrintLog "OK"
					function = TRUE
				end if
			' %%% end if
		end if
	else
		PrintLog "Unable to get existing page"
	end if

end function

function mkwiki_SavePageToCache( byref sPage as string, byref sBody as string ) as integer
	return SavePage( sPage, sBody )
end function
