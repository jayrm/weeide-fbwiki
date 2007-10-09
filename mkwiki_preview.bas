#include once "fbdoc_defs.bi"

#include once "CWiki2Chm.bi"
#include once "fbdoc_lang.bi"
#include once "fbdoc_cache.bi"
#include once "fbdoc_buildtoc.bi"
#include once "fbdoc_templates.bi"
#include once "fbdoc_keywords.bi"
#include once "printlog.bi"

#include once "vbcompat.bi"

#inclib "pcre"

using fb
using fbdoc

dim shared sOutputDir as string 

function HtmlPreview_Init _
	( _
		byref sPrefixDir as string _
	) as integer

	static done as integer = FALSE
	if done = TRUE then
		return done
	end if
	done = TRUE

	dim sLangFile as string

	'' Load language options
	sLangFile = sPrefixDir + "templates/default/lang/en/common.ini"
	if( Lang.LoadOptions( sLangFile ) = FALSE ) then
		printlog "Unable to load language file '" + sLangFile + "'"
		return FALSE
	end if

	'' Load Keywords
	fbdoc_loadkeywords( sPrefixDir + "templates/default/keywords.lst" )

	dim sTemplateDir as string

	sTemplateDir = sPrefixDir + "templates/default/code/"

	Templates.Clear()
	Templates.LoadFile( "chm_idx", sTemplateDir + "chm_idx.tpl.html" )
	Templates.LoadFile( "chm_prj", sTemplateDir + "chm_prj.tpl.html" )
	Templates.LoadFile( "chm_toc", sTemplateDir + "chm_toc.tpl.html" )
	Templates.LoadFile( "chm_def", sTemplateDir + "chm_def.tpl.html" )
	Templates.LoadFile( "htm_toc", sTemplateDir + "htm_toc.tpl.html" )
	Templates.LoadFile( "chm_doctoc", sTemplateDir + "chm_doctoc.tpl.html" )

	sOutputDir = sPrefixDir & "html/"

	function = TRUE

end function

function HtmlPreview_Generate _
	( _
		byref sPage as string _
	) as integer

	Lang.SetOption("fb_docinfo_date", Format( Now(), Lang.GetOption("fb_docinfo_dateformat")))
	Lang.SetOption("fb_docinfo_time", Format( Now(), Lang.GetOption("fb_docinfo_timeformat")))

	dim as CPageList ptr paglist, toclist

	FBDoc_BuildSinglePage( sPage, sPage, @paglist, @toclist, FALSE )

	'' Generate HTML
	dim as CWiki2Chm ptr chm
	chm = new CWiki2Chm( @"", 1, sOutputDir, paglist, toclist )
	chm->Emit()
	delete chm

	delete toclist
	delete paglist

	return 0

end function

