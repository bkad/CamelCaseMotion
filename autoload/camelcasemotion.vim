" camelcasemotion.vim: Motion through CamelCaseWords and underscore_notation. 
"
" DEPENDENCIES:
"   - Requires Vim 7.0 or higher. 
"
" Copyright: (C) 2007-2009 by Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'. 
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
" REVISION	DATE		REMARKS 
"   1.50.001	05-May-2009	Do not create mappings for select mode;
"				according to|Select-mode|, printable character
"				commands should delete the selection and insert
"				the typed characters. 
"				Moved functions from plugin to separate autoload
"				script. 
"   				file creation

"- functions ------------------------------------------------------------------"
function! s:Move( direction, count, mode )
    " Note: There is no inversion of the regular expression character class
    " 'keyword character' (\k). We need an inversion "non-keyword" defined as
    " "any non-whitespace character that is not a keyword character" (e.g.
    " [!@#$%^&*()]). This can be specified via a non-whitespace character in
    " whose place no keyword character matches (\k\@!\S). 

    "echo "count is " . a:count
    let l:i = 0
    while l:i < a:count
	if a:direction == 'e'
	    " "Forward to end" motion. 
	    "call search( '\>\|\(\a\|\d\)\+\ze_', 'We' )
	    " end of ...
	    " number | ACRONYM followed by CamelCase or number | CamelCase | underscore_notation | non-keyword | word
	    call search( '\d\+\|\u\+\ze\%(\u\l\|\d\)\|\u\l\+\|\%(\a\|\d\)\+\ze_\|\%(\k\@!\S\)\+\|\%(_\@!\k\)\+\>', 'We' )
	    " Note: word must be defined as '\k\>'; '\>' on its own somehow
	    " dominates over the previous branch. Plus, \k must exclude the
	    " underscore, or a trailing one will be incorrectly moved over:
	    " '\%(_\@!\k\)'. 
	    if a:mode == 'o'
		" Note: Special additional treatment for operator-pending mode
		" "forward to end" motion. 
		" The difference between normal mode, operator-pending and visual
		" mode is that in the latter two, the motion must go _past_ the
		" final "word" character, so that all characters of the "word" are
		" selected. This is done by appending a 'l' motion after the
		" search for the next "word". 
		"
		" In operator-pending mode, the 'l' motion only works properly
		" at the end of the line (i.e. when the moved-over "word" is at
		" the end of the line) when the 'l' motion is allowed to move
		" over to the next line. Thus, the 'l' motion is added
		" temporarily to the global 'whichwrap' setting. 
		" Without this, the motion would leave out the last character in
		" the line. I've also experimented with temporarily setting
		" "set virtualedit=onemore" , but that didn't work. 
		let l:save_ww = &whichwrap
		set whichwrap+=l
		normal! l
		let &whichwrap = l:save_ww
	    endif
	else
	    " Forward (a:direction == '') and backward (a:direction == 'b')
	    " motion. 

	    let l:direction = (a:direction == 'w' ? '' : a:direction)

	    " CamelCase: Jump to beginning of either (start of word, Word, WORD,
	    " 123). 
	    " Underscore_notation: Jump to the beginning of an underscore-separated
	    " word or number. 
	    "call search( '\<\|\u', 'W' . l:direction )
	    "call search( '\<\|\u\(\l\+\|\u\+\ze\u\)\|\d\+', 'W' . l:direction )
	    "call search( '\<\|\u\(\l\+\|\u\+\ze\u\)\|\d\+\|_\zs\(\a\|\d\)\+', 'W' . l:direction )
	    " beginning of ...
	    " word | empty line | non-keyword after whitespaces | non-whitespace after word | number | ACRONYM followed by CamelCase or number | CamelCase | underscore followed by ACRONYM, Camel, lowercase or number
	    call search( '\<\D\|^$\|\%(^\|\s\)\+\zs\k\@!\S\|\>\S\|\d\+\|\u\+\ze\%(\u\l\|\d\)\|\u\l\+\|_\zs\%(\u\+\|\u\l\+\|\l\+\|\d\+\)', 'W' . l:direction )
	    " Note: word must be defined as '\<\D' to avoid that a word like
	    " 1234Test is moved over as [1][2]34[T]est instead of [1]234[T]est
	    " because \< matches with zero width, and \d\+ will then start
	    " matching '234'. To fix that, we make \d\+ be solely responsible
	    " for numbers by taken this away from \< via \<\D. (An alternative
	    " would be to replace \d\+ with \D\%#\zs\d\+, but that one is more
	    " complex.) All other branches are not affected, because they match
	    " multiple characters and not the same character multiple times. 
	endif
	let l:i = l:i + 1
    endwhile
endfunction

function! camelcasemotion#Motion( direction, count, mode )
"*******************************************************************************
"* PURPOSE:
"   Perform the motion over CamelCaseWords or underscore_notation. 
"* ASSUMPTIONS / PRECONDITIONS:
"   none
"* EFFECTS / POSTCONDITIONS:
"   Move cursor / change selection. 
"* INPUTS:
"   a:direction	one of 'w', 'b', 'e'
"   a:count	number of "words" to move over
"   a:mode	one of 'n', 'o', 'v', 'iv' (latter one is a special visual mode
"		when inside the inner "word" text objects. 
"* RETURN VALUES: 
"   none
"*******************************************************************************
    " Visual mode needs special preparations and postprocessing; 
    " normal and operator-pending mode breeze through to s:Move(). 

    if a:mode == 'v'
	" Visual mode was left when calling this function. Reselecting the current
	" selection returns to visual mode and allows to call search() and issue
	" normal mode motions while staying in visual mode. 
	normal! gv
    endif
    if a:mode == 'v' || a:mode == 'iv'

	" Note_1a:
	if &selection != 'exclusive' && a:direction == 'w'
	    normal! l
	endif
    endif

    call s:Move( a:direction, a:count, a:mode )

    if a:mode == 'v' || a:mode == 'iv'
	" Note: 'selection' setting. 
	if &selection == 'exclusive' && a:direction == 'e'
	    " When set to 'exclusive', the "forward to end" motion (',e') does not
	    " include the last character of the moved-over "word". To include that, an
	    " additional 'l' motion is appended to the motion; similar to the
	    " special treatment in operator-pending mode. 
	    normal! l
	elseif &selection != 'exclusive' && a:direction != 'e'
	    " Note_1b:
	    " The forward and backward motions move to the beginning of the next "word".
	    " When 'selection' is set to 'inclusive' or 'old', this is one character too far. 
	    " The appended 'h' motion undoes this. Because of this backward step,
	    " though, the forward motion finds the current "word" again, and would
	    " be stuck on the current "word". An 'l' motion before the CamelCase
	    " motion (see Note_1a) fixes that. 
	    normal! h
	endif
    endif
endfunction

function! camelcasemotion#InnerMotion( direction, count )
    " If the cursor is positioned on the first character of a CamelWord, the
    " backward motion would move to the previous word, which would result in a
    " wrong selection. To fix this, first move the cursor to the right, so that
    " the backward motion definitely will cover the current "word" under the
    " cursor. 
    normal! l
    
    " Move "word" backwards, enter visual mode, then move "word" forward. This
    " selects the inner "word" in visual mode; the operator-pending mode takes
    " this selection as the area covered by the motion. 
    if a:direction == 'b'
	" Do not do the selection backwards, because the backwards "word" motion
	" in visual mode + selection=inclusive has an off-by-one error. 
	call camelcasemotion#Motion( 'b', a:count, 'n' )
	normal! v
	" We decree that 'b' is the opposite of 'e', not 'w'. This makes more
	" sense at the end of a line and for underscore_notation. 
	call camelcasemotion#Motion( 'e', a:count, 'iv' )
    else
	call camelcasemotion#Motion( 'b', 1, 'n' )
	normal! v
	call camelcasemotion#Motion( a:direction, a:count, 'iv' )
    endif
endfunction

" vim: set sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
