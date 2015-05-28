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

" end of ...
" bol
let s:pattern_end = '^'
" eol
let s:pattern_end .= '\|$'
" Anything followed by whitespace
" let s:pattern_end .= '\|\S\%(\s\|$\)\@='
"  number
let s:pattern_end .= '\|\d\+'
" ACRONYM followed by CamelCase or number
let s:pattern_end .= '\|\u\%(\u\l\)\@='
" ACRONYM followed by non alpha
let s:pattern_end .= '\|\u\%(\a\)\@!'
" lower case followed by non lower-case (this also takes care of CamelCase)
let s:pattern_end .= '\|\l\%(\l\)\@!'
" symbol of at least 2 chars
let s:pattern_end .= '\|[[:punct:]]\{2,}'
" single char of non-keyword prefixed by whitespace
"let s:pattern_begin .= '\%(\s\|$\)\zs\S'

" long stretches of whitespaces.
" This is useful for indents and trailing whitespaces.
" This is a separate inclusive pattern for the edge case,
" when the cursor is at the bol and there is two whitespaces before a word/keyword
let s:pattern_inclusive = '\s\s\{2,}'

" beginning of ...
" bol
let s:pattern_begin = '^'
" eol |
let s:pattern_begin .= '\|$'
" single char followed by whitespace
let s:pattern_begin .= '\|\%(^\|\s\)\zs\S\ze\%(\s\|$\)'
" number |
let s:pattern_begin .= '\|\d\+'
" CamelCase (May be after an acronymn)
let s:pattern_begin .= '\|\u\l'
" ACRONYM |
" First uppercase : edge case of ACRONYM[B]efore to avoid matching at cursor
let s:pattern_begin .= '\|\u\@<!\u'
" symbol of at least 2 chars
let s:pattern_begin .= '\|[[:punct:]]\{2,}'
" lowercase after a nonalpha, ie not in Camel
"let s:pattern_begin .= '\|[[:punct:][:blank:]]\zs\a'
let s:pattern_begin .= '\|\a\@<!\l'
" anything prefixed by whitespace
"let s:pattern_begin .= '\|\%(\s\|$\)\zs\S'
let s:pattern_begin .= '\|\S\@<!\S'
"echom s:pattern_begin

"- functions ------------------------------------------------------------------"
function! s:GetClosest(direction, line1, col1, line2, col2)
    let l:line0 = line('.')
    let l:col0 = col('.')

    "echom  l:line0 . ":" .  l:col0 . " " . a:line1 . ":" .  a:col1 . " " . a:line2 . ":" .  a:col2
    " if line2/col2 has actually moved from ther cursor
    if [a:line2, a:col2] != [0, 0] && (a:col2 != l:col0 || a:line2 != l:line0)
        if a:direction == ''
            if a:line2 < a:line1 || (a:col2 < a:col1 && a:line2 == a:line1)
                return [a:line2, a:col2]
            endif
        else
            if a:line2 > a:line1 || (a:col2 > a:col1 && a:line2 == a:line1)
                return [a:line2, a:col2]
            endif
        endif
    endif
    return [a:line1, a:col1]
endfunction

function! s:Move( direction, count, mode )
    " Note: There is no inversion of the regular expression character class
    " 'keyword character' (\k). We need an inversion "non-keyword" defined as
    " "any non-whitespace character that is not a keyword character" (e.g.
    " [!@#$%^&*()]). This can be specified via a non-whitespace character in
    " whose place no keyword character matches (\k\@!\S). 

    "echo "count is " . a:count
    let l:i = 0
    while l:i < a:count
	if a:direction == 'e' || a:direction == 'ge'
	    let l:direction = (a:direction == 'e' ? '' : 'b')
	    " "Forward to end" motion. 
	    "call search( '\>\|\(\a\|\d\)\+\ze_', 'We' )
	    let [l:line1, l:col1] = searchpos(s:pattern_end, 'Wen' . l:direction )
	    " Note: word must be defined as '\k\>'; '\>' on its own somehow
	    " dominates over the previous branch. Plus, \k must exclude the
	    " underscore, or a trailing one will be incorrectly moved over:
	    " '\%(_\@!\k\)'.

        let [l:line2, l:col2] = searchpos(s:pattern_inclusive, 'Wenc' . l:direction )
        let [l:line1, l:col1] = s:GetClosest(l:direction, l:line1, l:col1, l:line2, l:col2)

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
		let l:col1 = l:col1 + 1
	    endif
	else
	    " Forward (a:direction == '') and backward (a:direction == 'b')
	    " motion. 
	    let l:direction = (a:direction == 'w' ? '' : 'b')
	    " CamelCase: Jump to beginning of either (start of word, Word, WORD,
	    " 123). 
	    " Underscore_notation: Jump to the beginning of an underscore-separated
	    " word or number. 
	    "call search( '\<\|\u', 'W' . l:direction )
	    "call search( '\<\|\u\(\l\+\|\u\+\ze\u\)\|\d\+', 'W' . l:direction )
	    "call search( '\<\|\u\(\l\+\|\u\+\ze\u\)\|\d\+\|_\zs\(\a\|\d\)\+', 'W' . l:direction )
	    let [l:line1, l:col1] = searchpos(s:pattern_begin, 'Wn' . l:direction )
	    " Note: word must be defined as '\<\D' to avoid that a word like
	    " 1234Test is moved over as [1][2]34[T]est instead of [1]234[T]est
	    " because \< matches with zero width, and \d\+ will then start
	    " matching '234'. To fix that, we make \d\+ be solely responsible
	    " for numbers by taken this away from \< via \<\D. (An alternative
	    " would be to replace \d\+ with \D\%#\zs\d\+, but that one is more
	    " complex.) All other branches are not affected, because they match
	    " multiple characters and not the same character multiple times. 
        let [l:line2, l:col2] = searchpos(s:pattern_inclusive, 'Wnc' . l:direction )
        let [l:line1, l:col1] = s:GetClosest(l:direction, l:line1, l:col1, l:line2, l:col2)
	endif

    " Searching for newline returns inconsistent col unless it's the only search, so
    " repeat it here.
    " NB. Searching backwards for '$' with 'Wneb' will match on current cursor, use 'Wnb'
    " NB. Searching forwards for '$' requires 'c', ie 'Wnc'
    if l:direction == ''
        let [l:line2, l:col2] = searchpos('$', 'Wnc')
    else
        let [l:line2, l:col2] = searchpos('$', 'Wnb')
    endif
    let [l:line1, l:col1] = s:GetClosest(l:direction, l:line1, l:col1, l:line2, l:col2)

	call cursor(l:line1, l:col1)
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
"   a:direction	one of 'w', 'b', 'e', 'ge'
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

    call s:Move( a:direction, a:count, a:mode )

    if a:mode == 'v' || a:mode == 'iv'
	" Note: 'selection' setting. 
	if &selection == 'exclusive' && a:direction == 'e'
	    " When set to 'exclusive', the "forward to end" motion (',e') does not
	    " include the last character of the moved-over "word". To include that, an
	    " additional 'l' motion is appended to the motion; similar to the
	    " special treatment in operator-pending mode. 
	    normal! l
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
    if a:direction == 'b' || a:direction == 'ge'
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
	call camelcasemotion#Motion( 'e', a:count, 'iv' )
    endif
endfunction

" vim: set sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
