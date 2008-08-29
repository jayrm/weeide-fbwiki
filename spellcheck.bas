#include once "windows.bi"
#include once "common.bi"

#include once "weeide.bi"

#include once "aspell.bi"

#define FALSE 0
#define TRUE 1
#define NULL 0

#define MAX_WORDS 100

dim shared as AspellConfig ptr spell_config = NULL
dim shared as AspellSpeller ptr spell_checker = NULL
dim shared as string wordlist(0 to MAX_WORDS - 1)
dim shared as integer wordcount = 0

#define MAX_WIKIWORDS 3

dim shared wikiwords( 0 to MAX_WIKIWORDS - 1 ) as zstring ptr = { _
	@"fbdoc", _
	@"FreeBASIC", _
	@"freebasic" _
}

''
sub WORDS_Clear()
	wordcount = 0
end sub

''
sub WORDS_Add( byref word as string )
	if( wordcount < MAX_WORDS ) then
		wordlist( wordcount ) = word
		wordcount += 1
	end if
end sub

''
function SpellCheck_Init() as integer

	dim as AspellCanHaveError ptr possible_err

	function = FALSE

	spell_config = new_aspell_config()
	aspell_config_replace( spell_config, "lang", "en_US" )
	possible_err = new_aspell_speller( spell_config ) 

	if( aspell_error_number(possible_err) <> 0 ) then
		Application.MessageBox( aspell_error_message( possible_err ) )
		exit function

	else
		spell_checker = to_aspell_speller( possible_err )

	end if

	' *** Not sure about this block
	'dim as AspellConfig ptr spell_config2 = aspell_config_clone(spell_config)
	'aspell_config_replace(spell_config2, "lang","nl")
	'possible_err = new_aspell_speller(spell_config2)
	'delete_aspell_config(spell_config2)

	for i as integer = 0 to MAX_WIKIWORDS - 1
		aspell_speller_add_to_session( spell_checker, wikiwords(i), len(*wikiwords(i) ) )
	next

	function = TRUE

end function

''
function SpellCheck_Exit() as integer

	if( spell_checker ) then
		delete_aspell_speller( spell_checker )
	end if

	function = TRUE
	
end function

''
function SpellCheck_Word( byref input_word as string ) as integer

	dim as integer correct
	dim as AspellWordList ptr suggestions
	dim as AspellStringEnumeration ptr elements
	dim as zstring ptr word

	function = FALSE

	WORDS_Clear()

	if( len(input_word) = 0 ) then
		exit function
	end if

	if( spell_checker = NULL ) then
		SpellCheck_Init()
	end if

	if( spell_checker = NULL ) then
		exit function
	end if

	correct = aspell_speller_check(spell_checker, strptr(input_word), len(input_word))

	if( correct <> 0 ) then
		function = TRUE
		exit function
	end if

	suggestions = aspell_speller_suggest(spell_checker, strptr(input_word), len(input_word))
	elements = aspell_word_list_elements(suggestions)

	do
		word = aspell_string_enumeration_next(elements)
		if word = NULL then
			exit do
		end if
		WORDS_Add( *word )
	loop

	delete_aspell_string_enumeration(elements)

	' - Report the replacement
	'aspell_speller_store_repl(spell_checker, misspelled_word, size,
	'                          correctly_spelled_word, size);

	' - Add to session or personal dictionary
	'aspell_speller_add_to_session|personal(spell_checker, word, size)

end function

''
function SpellCheck_GetWordCount() as integer
	function = wordcount
end function

''
function SpellCheck_GetWord( byval index as integer ) as string
	if( index >= 0 and index <= wordcount ) then
		function = wordlist( index )
	else
		function = ""
	end if
end function
