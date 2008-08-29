#include once "windows.bi"
#include once "win/richedit.bi"
#include once "win/commctrl.bi"
#include once "common.bi"

#include once "CCodeEditControl.bi"

#include once "weeide.bi"
#include once "weeide_menu.bi"
#include once "weeide_about.bi"
#include once "weeide_edit.bi"
#include once "weeide_code.bi"
#include once "weeide_wiki.bi"
#include once "weeide_html.bi"
#include once "weeide_main.bi"
#include once "utils.bi
#include once "spellcheck.bi"

#include once "mkwiki.bi"

#define MYCLASSNAME TEXT( "WEEIDE" )

type MDICHILDCBINFO
	as HWND hwndParent
	as MainWindow ptr frmMain
	as BOOL bCancel
end type

'' --------------------------------------------------------
'' The main window needs to be able to call similar methods
'' in different child windows.  Rather than get too exotic
'' with pseudo derived types, vtables, polymorphism, etc...
'' we just check the window type assigned to each child
'' window and call the appropriate methods using a
'' SELECT CASE.  It's not very elegant but it is simple
'' and this is the only module we need to do it in.
'' --------------------------------------------------------

function WeeIdeChild_OnQueryCommand( byval hwnd as HWND, byval menuid as UINT, byval state as UINT ptr ) as BOOL

	select case( CWindowInfo.GetWindowType( hwnd ) )
	
	case WID_CODEWINDOW:
	
		dim as CodeWindow ptr frm = GetCodeWindowPtr( hwnd )
		if( frm ) then
			return frm->OnQueryCommand( menuid, state )
		end if

	case WID_WIKIWINDOW:
	
		dim as WikiWindow ptr frm = GetWikiWindowPtr( hwnd )
		if( frm ) then
			return frm->OnQueryCommand( menuid, state )
		end if

	end select

	return FALSE

end function

function WeeIdeChild_FindNext( byval hwnd as HWND, byval fnd as FINDCTX ptr ) as BOOL

	select case( CWindowInfo.GetWindowType( hwnd ) )
	
	case WID_CODEWINDOW:
	
		dim as CodeWindow ptr frm =GetCodeWindowPtr( hwnd )
		if( frm ) then
			return frm->FindNext( fnd )
		end if
	
	case WID_WIKIWINDOW:
	
		dim as WikiWindow ptr frm = GetWikiWindowPtr( hwnd )
		if( frm ) then
			return frm->FindNext( fnd )
		end if
	
	end select

	return FALSE

end function

function WeeIdeChild_GetText( byval hwnd as HWND ) as TString

	select case( CWindowInfo.GetWindowType( hwnd ) )
	
	case WID_CODEWINDOW:
	
		dim as CodeWindow ptr frm = GetCodeWindowPtr( hwnd )
		if( frm ) then
			return frm->GetText()
		end if
	
	case WID_WIKIWINDOW:
	
		dim as WikiWindow ptr frm = GetWikiWindowPtr( hwnd )
		if( frm ) then
			return frm->GetText()
		end if
	
	end select

	return TEXT( "" )

end function

function WeeIdeChild_GetSelText( byval hwnd as HWND ) as TString

	select case( CWindowInfo.GetWindowType( hwnd ) )
	
	case WID_CODEWINDOW:
	
		dim as CodeWindow ptr frm = GetCodeWindowPtr( hwnd )
		if( frm ) then
			return frm->GetSelText()
		end if
	
	case WID_WIKIWINDOW:
	
		dim as WikiWindow ptr frm = GetWikiWindowPtr( hwnd )
		if( frm ) then
			return frm->GetSelText()
		end if
	
	end select

	return TEXT( "" )

end function

function WeeIdeChild_ReplaceSel( byval hwnd as HWND, byref s as TString ) as BOOL

	select case( CWindowInfo.GetWindowType( hwnd ) )
	
	case WID_CODEWINDOW:
	
		dim as CodeWindow ptr frm = GetCodeWindowPtr( hwnd )
		if( frm ) then
			return frm->ReplaceSel( s )
		end if
	
	case WID_WIKIWINDOW:
	
		dim as WikiWindow ptr frm = GetWikiWindowPtr( hwnd )
		if( frm ) then
			return frm->ReplaceSel( s )
		end if
	
	end select

	return TRUE

end function

function WeeIdeChild_NextWord( byval hwnd as HWND ) as BOOL

	select case( CWindowInfo.GetWindowType( hwnd ) )
	
	case WID_WIKIWINDOW:
	
		dim as WikiWindow ptr frm = GetWikiWindowPtr( hwnd )
		if( frm ) then
			return frm->NextWord()
		end if
	
	end select

	return FALSE

end function

function WeeIdeChild_HideSelection( byval hwnd as HWND, byval fHide as BOOL, byval fChangeStyle as BOOL ) as BOOL

	select case( CWindowInfo.GetWindowType( hwnd ) )
	
	case WID_CODEWINDOW:
	
		dim as CodeWindow ptr frm =GetCodeWindowPtr( hwnd )
		if( frm ) then
			return frm->HideSelection( fHide, fChangeStyle )
		end if
	
	case WID_WIKIWINDOW:
	
		dim as WikiWindow ptr frm = GetWikiWindowPtr( hwnd )
		if( frm ) then
			return frm->HideSelection( fHide, fChangeStyle )
		end if
	
	end select

	return FALSE

end function

function WeeIdeChild_SaveFile( byval hwnd as HWND, byval bForcePrompt as BOOL ) as BOOL

	select case( CWindowInfo.GetWindowType( hwnd ) )
	
	case WID_CODEWINDOW:
		
		dim as CodeWindow ptr frm = GetCodeWindowPtr( hwnd )
		if( frm ) then
			return frm->SaveFile( bForcePrompt )
		end if
	
	case WID_WIKIWINDOW:
	
		dim as WikiWindow ptr frm = GetWikiWindowPtr( hwnd )
		if( frm ) then
			return frm->SaveFile( bForcePrompt )
		end if
	
	end select

	return FALSE

end function

function WeeIdeChild_GetModify( byval hwnd as HWND ) as BOOL

	select case( CWindowInfo.GetWindowType( hwnd ) )
	
	case WID_CODEWINDOW:
	
		dim as CodeWindow ptr frm =GetCodeWindowPtr( hwnd )
		if( frm ) then
			return frm->GetModify()
		end if
	
	case WID_WIKIWINDOW:
	
		dim as WikiWindow ptr frm = GetWikiWindowPtr( hwnd )
		if( frm ) then
			return frm->GetModify()
		end if
	
	end select

	return FALSE

end function

'' --------------------------------------------------------
'' MainWindow
'' --------------------------------------------------------
constructor MainWindow()
	_hInstance = NULL
	_hwnd = NULL
	_hwndMDI = NULL
	_hmenuMDI = NULL
	_haccelTable = NULL
	frmFind = NULL
	_hwndList = NULL
	_fixedfnt = NULL
	_swissfnt = NULL
	frmSpell = NULL
end constructor

destructor MainWindow()
	
	if( frmFind ) then
		delete frmFind
	end if

	if( frmSpell ) then
		delete frmSpell
	end if

	if( _fixedfnt ) then
		DeleteObject( _fixedfnt )
		_fixedfnt = NULL
	end if

	if( _swissfnt ) then
		DeleteObject( _swissfnt )
		_swissfnt = NULL
	end if

	SpellCheck_Exit()

end destructor

'' --------------------------------------------------------
function MainWindow.GetHwnd() as HWND
	return _hwnd
end function

'' --------------------------------------------------------
function MainWindow.GetHwndMDI() as HWND
	return _hwndMDI
end function

'' --------------------------------------------------------
function MainWindow.GetActiveChild() as HWND
	dim as BOOL maximized
	return cast(HWND, SendMessage( _hwndMDI, WM_MDIGETACTIVE, 0, cast(LPARAM, @maximized )))
end function

'' --------------------------------------------------------
function MainWindow.GetAccelTable() as HACCEL
	return _haccelTable
end function

'' --------------------------------------------------------
private function MainWindow.SelfRegister() as BOOL

	static as BOOL bClassRegistered = FALSE
	dim as WNDCLASS wcls

	if( bClassRegistered = FALSE ) then
	
		'' Setup window class
		wcls.style         = CS_HREDRAW or CS_VREDRAW
		wcls.lpfnWndProc   = procptr( MainWindow.WindowProc )
		wcls.cbClsExtra    = 0
		wcls.cbWndExtra    = 0
		wcls.hInstance     = _hInstance
		wcls.hIcon         = LoadIcon( _hInstance, MAKEINTRESOURCE( IDI_WEEIDE ))
		wcls.hCursor       = LoadCursor( NULL, IDC_ARROW )
		wcls.hbrBackground = cast(HBRUSH, COLOR_BTNFACE + 1)
		wcls.lpszMenuName  = NULL
		wcls.lpszClassName = @MYCLASSNAME

		'' Register the window class     
		if( RegisterClass( @wcls ) = FALSE ) then
			Application.ErrorMessage( GetLastError(), TEXT( "Could not register the window class" ))
			return NULL
		end if

		bClassRegistered = TRUE
	end if

	return bClassRegistered

end function

'' --------------------------------------------------------
'' Create the main application window
'' --------------------------------------------------------
function MainWindow.InitInstance( byval hInstance as HINSTANCE ) as MainWindow ptr

	dim as MainWindow ptr _this

	'' create our class
	_this = new MainWindow
	if( _this = NULL ) then
		return NULL
	end if

	_this->_hInstance = hInstance

	'' make sure our class is registered
	if( _this->SelfRegister() = FALSE ) then
		delete _this
		return NULL
	end if

	'' create the actual window
	_this->_hwnd = CreateWindowEx( 0, _
		@MYCLASSNAME, Application.Title, _
		WS_OVERLAPPEDWINDOW or WS_CLIPCHILDREN, _
		CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, _
		NULL, NULL,	_this->_hInstance,	NULL )

	if( _this->_hwnd.IsNull() ) then
		Application.ErrorMessage( GetLastError(), TEXT( "Unable to create main window" ) )
		delete _this
		return NULL
	end if

	_this->_info.SetWindowInfo( _this->_hwnd, _this, WID_MAINWINDOW )

	'' Set-up the menu
	SetMenu( _this->_hwnd, GetAppMenu(APPMENUID_MAIN) )
	_this->_hmenuMDI = GetAppMenu(APPMENUID_WINDOW)

	'' Create an MDI client area
	dim as CLIENTCREATESTRUCT ccs = ( _this->_hmenuMDI, IDM_WINDOW_FIRSTCHILD )

	if( _this->_hwnd.IsNull() ) then
		return NULL
	end if

	_this->_hwndMDI = CreateWindowEx( WS_EX_CLIENTEDGE, TEXT( "MDICLIENT" ), cast(LPCTSTR, NULL), _
		WS_VISIBLE or WS_CHILD or WS_CLIPCHILDREN or WS_VSCROLL or WS_HSCROLL, _
		0, 0, 0, 0, _this->_hwnd, NULL, _this->_hInstance, cast(LPVOID, @ccs))

	if( _this->_hwndMDI.IsNull() ) then
		Application.ErrorMessage( GetLastError(), TEXT( "Unable to create MDI client area" ))
		DestroyWindow( _this->_hwnd )
		return NULL
	end if

	_this->_fixedfnt = CreateFixedFont( -11 )
	_this->_swissfnt = CreateSwissFont( -11 )

	'' Listbox for showing wiki pages
	_this->_hwndList = CreateWindowEx( WS_EX_CLIENTEDGE, "LISTBOX", cast(LPCTSTR, NULL), _
		WS_VISIBLE or WS_CHILD or WS_HSCROLL or WS_VSCROLL or LBS_NOINTEGRALHEIGHT or LBS_NOTIFY, _
		0, 0, 0, 0, _this->_hwnd, cast(HMENU, IDC_MAIN_LIST), _this->_hInstance, NULL )
	SendMessage( _this->_hwndList, WM_SETFONT, cast( WPARAM, _this->_swissfnt), TRUE )
	
	_this->_hwndOutput.Create( FALSE, NULL, _this->_hwnd, IDC_MAIN_OUTPUT )

	'' Create the accelerator table
	if( _this->_haccelTable = NULL ) then
		_this->_haccelTable = GetAppAccelTable()
	end if

	return _this

end function

'' --------------------------------------------------------
'' COMMANDS
'' --------------------------------------------------------
function MainWindow.CmdNew() as BOOL

	dim as TString title 
	title = TEXT( "Untitled" )
	title += TString.ToStr( Application.GetFileID() )

	dim as CodeWindow ptr frm = CodeWindow.InitInstance( _hwndMDI, title )
	if( frm ) then
		return TRUE
	end if

	return FALSE

end function

'' --------------------------------------------------------
function MainWindow.CmdOpen( byref filename as TString ) as BOOL

	'' Is file already opened?
	dim as CDocumentItem ptr doc = Docs.FindByName( filename )

	if( doc ) then
		SetFocus( doc->GetHwnd() )
		return TRUE
	else
		dim as CodeWindow ptr frm = CodeWindow.InitInstance( _hwndMDI, filename )
		if( frm ) then
			if( frm->OpenFile( filename )) then
				return TRUE
			endif

			DestroyWindow( frm->GetHwnd() )
		end if
	end if

	return FALSE

end function

function MainWindow.CmdOpen() as BOOL

	dim as TString filename

	if( Application.PromptOpenFile( _hwnd, filename )) then
		return CmdOpen( filename )	
	end if

	return FALSE

end function

'' --------------------------------------------------------
function MainWindow.CmdSave( byval child as HWND, byval bForcePrompt as BOOL ) as BOOL

	if( child = NULL ) then
		child = GetActiveChild()
	end if

	return WeeIdeChild_SaveFile( child, bForcePrompt )

end function

function MainWindow.CmdSaveAs( byval child as HWND ) as BOOL

	if( child = NULL ) then
		child = GetActiveChild()
	end if

	if( child ) then
		return CmdSave( child, TRUE )
	end if

	return FALSE

end function

function SaveAll_cb( byval hwnd as HWND, byval mmci as MDICHILDCBINFO ptr ) as BOOL

	if( mmci->hwndParent = GetParent( hwnd )) then

		if( WeeIdeChild_GetModify( hwnd )) then
			if( mmci->frmMain->CmdSave( hwnd ) = FALSE ) then
				mmci->bCancel = TRUE
				return FALSE
			end if
		end if
	end if

	return TRUE

end function

function MainWindow.CmdSaveAll() as BOOL

	dim as MDICHILDCBINFO mcci

	mcci.hwndParent = _hwndMDI
	mcci.frmMain = @this
	mcci.bCancel = FALSE
	EnumChildWindows( _hwndMDI, cast(WNDENUMPROC, procptr(SaveAll_cb)), cast(LPARAM, @mcci ) )

	return iif(mcci.bCancel,FALSE,TRUE)

end function

'' --------------------------------------------------------
function CloseAll_cb( byval hwnd as HWND, byval mmci as MDICHILDCBINFO ptr ) as BOOL

	if( mmci->hwndParent = GetParent( hwnd )) then
		if( SendMessage( hwnd, WM_QUERYENDSESSION, 0, 0 ) = FALSE ) then
			mmci->bCancel = TRUE
			return FALSE
		else
			SendMessage( GetParent( hwnd ), WM_MDIDESTROY, cast(WPARAM, hwnd), 0 )
		end if
	end if

	return TRUE
end function

function MainWindow.CmdClose( byval hwnd_ as HWND ) as BOOL

	dim child as HWND
	
	if( hwnd_ = NULL ) then
		child = GetActiveChild()
	end if

	if( child = NULL ) then
		return FALSE
	end if

	if( GetParent( child ) <> _hwndMDI ) then
		return FALSE
	end if

	SendMessage( child, WM_CLOSE, 0, 0 )

	return TRUE	

end function

function MainWindow.CmdCloseAll() as BOOL

	dim as MDICHILDCBINFO mcci

	mcci.hwndParent = _hwndMDI
	mcci.frmMain = @this
	mcci.bCancel = FALSE
	EnumChildWindows( _hwndMDI, cast(WNDENUMPROC, procptr(CloseAll_cb)), cast(LPARAM, @mcci) )
	return iif(mcci.bCancel, FALSE, TRUE )

end function

function QueryCloseAll_cb( byval hwnd_ as HWND, byval mmci as MDICHILDCBINFO ptr ) as BOOL

	if( mmci->hwndParent = GetParent( hwnd_ )) then
		if( SendMessage( hwnd_, WM_QUERYENDSESSION, 0, 0 ) = FALSE ) then
			mmci->bCancel = TRUE
			return FALSE
		end if
	end if

	return TRUE

end function

function MainWindow.CmdQueryCloseAll() as BOOL

	dim as MDICHILDCBINFO mcci

	mcci.hwndParent = _hwndMDI
	mcci.bCancel = FALSE
	EnumChildWindows( _hwndMDI, cast(WNDENUMPROC, procptr(QueryCloseAll_cb)), cast(LPARAM, @mcci) )
	return iif(mcci.bCancel, FALSE, TRUE )

end function

'' --------------------------------------------------------
function MainWindow.CmdExit() as BOOL

	return SendMessage( _hwnd, WM_CLOSE, 0, 0 )

end function

'' --------------------------------------------------------
function MainWindow.CmdFind( byval bNext as BOOL ) as BOOL

	if( frmFind = NULL ) then
		frmFind = CFindDialog.InitInstance( _hwnd )
		bNext = FALSE
	end if

	if( frmFind = NULL ) then
		return FALSE
	end if

	dim as CWindow child = GetActiveChild()

	if( child.IsNull() ) then
		return FALSE
	end if

	if( CWindowInfo.GetWindowType( child ) = 0 ) then
		return FALSE
	end if

	if( bNext ) then
	
		dim as TString f = frmFind->GetFindText()
		if( f.GetLength() > 0 ) then
		
			'' CFindDialog will send a WM_APP_FINDTEXT to the application, which then
			'' gets handled by our OnFindNext() procedure
			frmFind->FindNext()
			return TRUE
		
		end if

	end if

	'' Show CFindDialog set with the highlighted text in the active child window (frm)
	dim as TString s = WeeIdeChild_GetSelText( child )

	if( s.GetLength() > 0 ) then
		frmFind->SetFindText( s )
	end if

	frmFind->Show()
	WeeIdeChild_HideSelection( child, FALSE, FALSE )

	return TRUE

end function

'' --------------------------------------------------------
function MainWindow.GetWikiListItem() as TString
	dim as TString pagename
	dim as HWND ctl
	dim as integer i, size

	ctl = GetDlgItem( _hwnd, IDC_MAIN_LIST )
	if ( ctl ) then
	
		i = SendMessage( ctl, LB_GETCURSEL, 0, 0 )
		if( i >= 0 ) then
		
			size = SendMessage(ctl, LB_GETTEXTLEN, i, 0)
			pagename.SetSize( size )
			if( size > 0 ) then
				SendMessage(ctl, LB_GETTEXT, i, cast(LPARAM, pagename.GetPtr()))
			end if

		end if

	end if

	return pagename
end function

function MainWindow.CmdWikiOpen( byref pagename as TString ) as BOOL

	'' Is file already opened?
	dim as CDocumentItem ptr doc = Docs.FindByName( pagename )

	if( doc ) then

		SetFocus( doc->GetHwnd() )
		return TRUE

	else

		dim as WikiWindow ptr frm = WikiWindow.InitInstance( _hwndMDI, pagename )
		if( frm ) then

			if( frm->OpenFile( pagename )) then
				return TRUE
			end if

			DestroyWindow( frm->GetHwnd() )

		end if

	end if

	return FALSE

end function

function MainWindow.OnListDblClick() as BOOL

	dim as TString pagename
	pagename = GetWikiListItem()

	if( pagename.GetLength() > 0 ) then
		return CmdWikiOpen( pagename )
	else
		return FALSE
	end if

end function

'' --------------------------------------------------------
function MainWindow.CmdWikiLogin() as BOOL
	return mkwiki_Login( FALSE )
end function

function MainWindow.CmdWikiPageList( byval bForce as BOOL ) as BOOL
	'' This will complete later by sending a WM_APP_PAGEINDEX_COMPLETED
	mkwiki_RefreshPageIndex( bForce )
	return TRUE
end function

function MainWindow.CmdWikiPreview() as BOOL

	dim as HWND child = GetActiveChild()

	if( CWindowInfo.GetWindowType( child ) = WID_WIKIWINDOW ) then
		dim as WikiWindow ptr frm = GetWikiWindowPtr( child )
		dim as TString pagename, bodytext

		pagename = frm->GetFileName()
		bodytext = frm->GetText()

		if( pagename.GetLength() > 0 ) then
			if( bodytext.GetLength() > 0 ) then
				dim as string sPage, sBody
				sPage = *pagename.GetPtr()
				sBody = *bodytext.GetPtr()

				mkwiki_SavePageToCache( sPage, sBody )

				HtmlPreview_Generate( sPage )
				
				dim as TString title = pagename
				title += " - preview"

				'' Already showing this page?
				dim as CDocumentItem ptr doc = Docs.FindByName( title )
				dim as HtmlWindow ptr frmHtml

				if( doc ) then
					frmHtml = GetHtmlWindowPtr( doc->GetHwnd() )
					if( frmHtml ) then
						frmHtml->Navigate( "file://" + exepath() + "/html/" + sPage + ".html" )
						SetFocus( frmHtml->GetHwnd() )
					end if
				else
					frmHtml = HtmlWindow.InitInstance( WID_HTMLWINDOW, _hwndMDI, title )
					if( frmHtml ) then
						frmHtml->Navigate( "file://" + exepath() + "/html/" + sPage + ".html" )
					end if
				end if
			end if
		end if
	end if

	return FALSE
	
end function

function MainWindow.CmdWikiSpellCheck( byval bNext as BOOL ) as BOOL

	if( frmSpell = NULL ) then
		frmSpell = CSpellCheckDialog.InitInstance( _hwnd )
		bNext = FALSE
	end if

	if( frmSpell = NULL ) then
		return FALSE
	end if

	dim as CWindow child = GetActiveChild()

	if( child.IsNull() ) then
		return FALSE
	end if

	if( CWindowInfo.GetWindowType( child ) <> WID_WIKIWINDOW ) then
		return FALSE
	end if

	dim as TString s 
	dim word as string
	dim bHaveWord as BOOL
	dim bBad as BOOL = FALSE
	dim range as CHARRANGE
	dim as WikiWindow ptr frm = GetWikiWindowPtr( child )

	if( bNext ) then
		bHaveWord = WeeIdeChild_NextWord( child )
	else
		s = WeeIdeChild_GetSelText( child )
		if( s.GetLength() = 0 ) then
			bHaveWord = WeeIdeChild_NextWord( child )
		else
			bHaveWord = TRUE
		end if
	end if

	SendMessage( frm->GetEditHwnd(), EM_EXGETSEL, 0, cast(LPARAM,@range ))

	while( bHaveWord )

		s = WeeIdeChild_GetSelText( child )

		if( s.GetLength() > 0 ) then
			word = *cast( LPTSTR, s )

			if( SpellCheck_Word( word ) = FALSE ) then

				frmSpell->SetCheckText( s )
				frmSpell->Show()
				WeeIdeChild_HideSelection( child, FALSE, FALSE )
				bBad = TRUE

				exit while

			end if

		else
			exit while

		end if

		bHaveWord = WeeIdeChild_NextWord( child )

	wend

	if( bBad = FALSE ) then
		frmSpell->Hide()
		SendMessage( frm->GetEditHwnd(), EM_EXSETSEL, 0, cast(LPARAM,@range ))
		Application.MessageBox( TEXT( "Spell check complete" ) )
	end if

	return TRUE

end function

'' --------------------------------------------------------
function MainWindow.CmdHelpAbout() as BOOL

	dim as CAboutDialog frm
	return frm.Show( _hwnd )

end function

'' --------------------------------------------------------
'' WM_APP_QUERYCOMMAND
'' --------------------------------------------------------
function MainWindow.OnQueryCommand( byval menuid as UINT, byval state as UINT ptr ) as BOOL

	'' result -1=don't care
	dim as integer s = -1

	select case menuid
	case IDM_FILE_NEW, IDM_FILE_OPEN, IDM_FILE_EXIT

		s = MF_ENABLED

	case IDM_FILE_SAVE, IDM_FILE_SAVE_AS

		s = MF_GRAYED
	
	case IDM_FILE_SAVE_ALL, IDM_FILE_CLOSE, _
		IDM_WINDOW_ARRANGE_CASCADE, IDM_WINDOW_TILE_HORIZONTALLY, IDM_WINDOW_TILE_VERTICALLY, _
		IDM_WINDOW_NEXT, IDM_WINDOW_PREVIOUS, IDM_WINDOW_CLOSE_ALL:

		if( GetActiveChild() ) then
			s = MF_ENABLED
		else
			s = MF_GRAYED
		end if

	case IDM_HELP_ABOUT:
		s = MF_ENABLED

	case IDM_WIKI_LOGIN:
		s = MF_ENABLED

	case IDM_WIKI_PAGELIST:
		s = MF_ENABLED

	case else
		if( (menuid >= IDM_WINDOW_FIRSTCHILD) and (menuid <= IDM_WINDOW_LASTCHILD )) then
			s = MF_ENABLED
		else
			s = MF_GRAYED
		end if

	end select
	
	if( s >= 0 ) then
		if( state ) then
			*state = s
		end if
		return TRUE
	end if

	return FALSE

end function

'' --------------------------------------------------------
'' WM_APP_PAGEINDEXCOMPLETED
'' --------------------------------------------------------
function MainWindow.OnPageIndexCompleted( byval wParam as WPARAM, byval lParam as LPARAM ) as BOOL
	'' mkwiki.bas ensures that this event is not re-entrant
	mkwiki_LoadPageIndexToList( GetDlgItem( _hwnd, IDC_MAIN_LIST ))
	return FALSE
end function

'' --------------------------------------------------------
'' WM_APP_FINDTEXT
'' --------------------------------------------------------
function MainWindow.OnFindNext( byval wParam as WPARAM, byval lParam as LPARAM ) as BOOL

	dim as CWindow firstchild = GetActiveChild()
	dim as CDocumentItem ptr doc = Docs.FindByHwnd( firstchild )
	dim as FINDCTX fnd = *(cast(FINDCTX ptr, lParam))

	if( doc = NULL ) then
		return FALSE
	end if

	if( WeeIdeChild_OnQueryCommand( doc->GetHwnd(), IDM_EDIT_FIND, NULL ) = FALSE ) then
		return FALSE
	end if

	'' Search from current to end (up or down)
	if( WeeIdeChild_FindNext( doc->GetHwnd(), @fnd ) ) then
		return TRUE
	end if

	if( (fnd.flags and FINDFLAG_SEARCHOPENDOCS) ) then
	
		fnd.flags or= FINDFLAG_FROMSTART or FINDFLAG_TOEND
		'' Loop through all the docs ( excluding the first one )
		while(1)
		
			WeeIdeChild_HideSelection( doc->GetHwnd(), TRUE, FALSE )

			doc = doc->GetNext()

			if( doc = NULL ) then
				doc = Docs.GetFirst()
			end if

			if( doc = NULL ) then
				return FALSE
			end if

			if( doc->GetHwnd() = firstchild ) then
				exit while
			end if

			if( WeeIdeChild_FindNext( doc->GetHwnd(), @fnd ) ) then
				BringWindowToTop( doc->GetHwnd() )
				UpdateWindow( doc->GetHwnd() )
				return TRUE
			end if
		wend
	
	end if

	if( doc->GetHwnd() = NULL ) then
		return FALSE
	end if

	'' Search the first doc again
	fnd.flags or= FINDFLAG_FROMSTART or FINDFLAG_TOEND
	if( WeeIdeChild_FindNext( doc->GetHwnd(), @fnd ) ) then
		return TRUE
	end if

	'' Not found, show message
	Application.MessageBox( TEXT( "Text was not found" ) )

	return FALSE

end function

'' --------------------------------------------------------
'' WM_APP_SPELLTEXT
'' --------------------------------------------------------
function MainWindow.OnSpellNext( byval wParam as WPARAM, byval lParam as LPARAM ) as BOOL

	dim as CWindow firstchild = GetActiveChild()
	dim as CDocumentItem ptr doc = Docs.FindByHwnd( firstchild )
	dim as SPELLCTX spell = *(cast(SPELLCTX ptr, lParam))

	if( doc = NULL ) then
		return FALSE
	end if

	if( WeeIdeChild_OnQueryCommand( doc->GetHwnd(), IDM_WIKI_SPELLCHECK, NULL ) = FALSE ) then
		return FALSE
	end if

	select case spell.cmd
	case SPELLCMD_IGNORE:
		return CmdWikiSpellCheck( TRUE )

	case SPELLCMD_IGNORE_ALL:
		return CmdWikiSpellCheck( TRUE )

	case SPELLCMD_ADD:
		return CmdWikiSpellCheck( TRUE )

	case SPELLCMD_CHANGE:
		WeeIdeChild_ReplaceSel( doc->GetHwnd(), spell.sWord )
		return CmdWikiSpellCheck( TRUE )

	case SPELLCMD_CHANGE_ALL:
		WeeIdeChild_ReplaceSel( doc->GetHwnd(), spell.sWord )
		return CmdWikiSpellCheck( TRUE )

	case else
		return FALSE

	end select

	return FALSE

end function


'' --------------------------------------------------------
'' WM_INITMENUPOPUP
'' --------------------------------------------------------
function MainWindow.OnInitMenuPopup( byval wParam_ as WPARAM, byval lParam_ as LPARAM ) as BOOL

	dim as HMENU menu = cast( HMENU, wParam_ )
	if( menu ) then
		dim as HWND child = GetActiveChild()
		dim as integer count = GetMenuItemCount(menu)

		'' Iterate through each item on the menu and determine
		'' if the item should be grayed or enabled.
		'' Check with the mdi child window first, if one exists
		'' otherwise, check with the main application window.

		for i as integer = 0 to count - 1
		
			dim as UINT id = GetMenuItemID( menu, i )
			if( id <> &hFFFFFFFF ) then
			
				dim as LRESULT result = FALSE
				dim as UINT state = GetMenuState( menu, i, MF_BYPOSITION )

				'' Ask the child first
				result = WeeIdeCHild_OnQueryCommand( child, id, @state )

				'' Then ask the main window
				if( result = FALSE ) then
					result = SendMessage( _hwnd, WM_APP_QUERYCOMMAND, id, cast(LPARAM,@state) )
				end if

				'' Default to unavailable
				if( result = FALSE ) then
					state = MF_GRAYED
				end if

				EnableMenuItem( menu, i, MF_BYPOSITION or state )
			
			end if
		
		next 
	
	end if
	return FALSE

end function

'' --------------------------------------------------------
'' WM_CLOSE
'' --------------------------------------------------------
function MainWindow.OnClose() as BOOL

	return CmdCloseAll()
end function

'' --------------------------------------------------------
'' WM_COMMAND
'' --------------------------------------------------------
function MainWindow.OnCommand(  byval wParam as WPARAM, byval lParam as LPARAM  ) as BOOL

	select case LOWORD( wParam )
	case IDM_FILE_NEW:
		return CmdNew()

	case IDM_FILE_OPEN:
		return CmdOpen()

	case IDM_FILE_SAVE:
		return CmdSave()

	case IDM_FILE_SAVE_AS:
		return CmdSaveAs()

	case IDM_FILE_SAVE_ALL:
		return CmdSaveAll()

	case IDM_FILE_CLOSE:
		return CmdClose()

	case IDM_FILE_EXIT:
		return CmdExit()

	case IDM_EDIT_FIND:
		return CmdFind( FALSE )

	case IDM_EDIT_FINDNEXT:
		return CmdFind( TRUE )

	case IDM_WINDOW_ARRANGE_CASCADE:
		return SendMessage( _hwndMDI, WM_MDICASCADE, MDITILE_SKIPDISABLED, 0 )

	case IDM_WINDOW_TILE_HORIZONTALLY:
		return SendMessage( _hwndMDI, WM_MDITILE, MDITILE_HORIZONTAL or MDITILE_SKIPDISABLED, 0 )

	case IDM_WINDOW_TILE_VERTICALLY:
		return SendMessage( _hwndMDI, WM_MDITILE, MDITILE_VERTICAL or MDITILE_SKIPDISABLED, 0 )
	
	case IDM_WINDOW_CLOSE_ALL:
		return CmdCloseAll()

	case IDM_WINDOW_NEXT:
		return SendMessage( _hwndMDI, WM_MDINEXT, cast(UINT, GetActiveChild()), TRUE )
	
	case IDM_WINDOW_PREVIOUS:
		return SendMessage( _hwndMDI, WM_MDINEXT, cast(UINT, GetActiveChild()), FALSE )

	case IDM_HELP_ABOUT:
		return CmdHelpAbout()

	case IDM_WIKI_LOGIN:
		return CmdWikiLogin()

	case IDM_WIKI_PAGELIST:
		return CmdWikiPageList( TRUE )

	case IDM_WIKI_PREVIEW:
		return CmdWikiPreview()

	case IDM_WIKI_SPELLCHECK:
		return CmdWikiSpellCheck( TRUE )

	case IDC_MAIN_LIST:
		if( HIWORD( wParam ) = LBN_DBLCLK ) then
			OnListDblClick()
		end if

	case else:
		dim as HWND child = GetActiveChild()
		if( child ) then
			return SendMessage( child, WM_COMMAND, wParam, lParam )
		end if

	end select

	return FALSE '' Command failed or not processed

end function

'' --------------------------------------------------------
'' WM_SIZE
'' --------------------------------------------------------
function MainWindow.OnSize( byval nWidth as integer, byval nHeight as integer ) as BOOL

	'' TODO: Add a splitter bar, and handle cases were the parent window
	'' is too small to show everything.

	/'
		+--------+----------------+
		| w1xh1  | w2xh3          |
		| (1)    | _hwndMDI       |
		|        |                |
		|        |                |
		|        |                |
		|        +----------------+
		|        | w2xh4          |
		|        | _hwndOutput    |
		+--------+----------------+
		(1) = IDC_MAIN_LIST
	'/

	dim as integer w1 = 160
	dim as integer w2 = nWidth - w1

	dim as integer h1 = nHeight

	dim as integer h4 = 80
	dim as integer h3 = nHeight - h4

	MoveWindow( _hwndList    ,  0,  0, w1, h1, TRUE )
	MoveWindow( _hwndMDI     , w1,  0, w2, h3, TRUE )
	MoveWindow( _hwndOutput  , w1, h3, w2, h4, TRUE )

	return TRUE

end function

'' --------------------------------------------------------
'' Main Application WNDPROC
'' --------------------------------------------------------
function MainWindow.WindowProc( _
			byval hwnd as HWND, _
			byval uMsg as UINT, _
			byval wParam as WPARAM, _
			byval lParam as LPARAM _
			) as LRESULT


	dim as MainWindow ptr _this = GetMainWindowPtr( hwnd )

	if( _this = NULL ) then
		return DefFrameProc( hwnd, NULL, uMsg, wParam, lParam )
	end if

	/' NOTE: Even if these are processed, they must still be passed on
		WM_COMMAND 
		WM_MENUCHAR 
		WM_SETFOCUS 
		WM_SIZE 
	'/

	select case uMsg
	case WM_INITMENUPOPUP:
		if( FALSE = HIWORD(lParam)) then
			_this->OnInitMenuPopup(wParam,lParam)
		end if

	case WM_APP_QUERYCOMMAND:
		return _this->OnQueryCommand( LOWORD(wParam), cast(UINT ptr, lParam) )

	case WM_APP_FINDTEXT:
		return _this->OnFindNext( wParam, lParam )

	case WM_APP_PAGEINDEXCOMPLETED:
		return _this->OnPageIndexCompleted( wParam, lParam )

	case WM_APP_SPELLTEXT:
		return _this->OnSpellNext( wParam, lParam )

	case WM_SIZE:
		_this->OnSize( LOWORD(lParam), HIWORD(lParam) )

		'' According to MS docs, we are supposed to pass this DefFrameProc, but if 
		'' we do, then the MDICLIENT area is automatically resized to the client 
		'' area of the parent window, and we don't want that.

		return 0

	case WM_COMMAND:
		_this->OnCommand( wParam, lParam )

	case WM_QUERYENDSESSION:
		return _this->CmdQueryCloseAll()
	
	case WM_CLOSE:
		if( _this->OnClose() ) then
		else
			return 0
		end if

	case WM_DESTROY:
		'' set our menu to NULL the menu resources will be released in WinMain
		SetMenu( hwnd, NULL )

		if( _this ) then
			delete _this
		end if

		PostQuitMessage( 0 )
		return 0

	case else

	end select

	'' Still not processed? Call the defaults
	return DefFrameProc( hwnd, _this->_hwndMDI, uMsg, wParam, lParam )

end function

''
function MainWindow.LogPrint( byval text as LPCTSTR ) as BOOL
	return _hwndOutput.LogPrint( text )
end function

''
function MainWindow.LogClear() as BOOL
	return _hwndOutput.LogClear()
end function
