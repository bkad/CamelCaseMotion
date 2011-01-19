" camelcasemotion.vim: Motion through CamelCaseWords and underscore_notation. 
"
" DEPENDENCIES:
"   - Requires Vim 7.0 or higher. 
"
" Copyright: (C) 2007-2009 by Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'. 
"
" Source: Based on vimtip #1016 by Anthony Van Ham. 
" Maintainer:	Ingo Karkat <ingo@karkat.de>
" REVISION	DATE		REMARKS 
"   1.50.019	05-May-2009	Do not create mappings for select mode;
"				according to|Select-mode|, printable character
"				commands should delete the selection and insert
"				the typed characters. 
"   				Moved functions from plugin to separate autoload
"				script. 
"   				Split off documentation into separate help file. 
"   				Now cleaning up Create...Mappings functions. 
"   1.40.018	30-Jun-2008	Minor: Removed unnecessary <script> from
"				mappings. 
"   1.40.017	19-May-2008	BF: Now using :normal! to be independent from
"				any user mappings. Thanks to Neil Walker for the
"				patch. 
"   1.40.016	28-Apr-2008	BF: Wrong forward motion stop at the second
"				digit if a word starts with multiple numbers
"				(e.g. 1234.56789). Thanks to Wasim Ahmed for
"				reporting this. 
"   1.40.015	24-Apr-2008	ENH: Added inner "word" text objects 'i,w' etc.
"				that work analogous to the built-in 'iw' text
"				object. Thanks to David Kotchan for this
"				suggestion. 
"   1.30.014	20-Apr-2008	The motions now also stop at non-keyword
"				boundaries, just like the regular motions. This
"				has no effect inside a CamelCaseWord or inside
"				underscore_notation, but it makes the motions
"				behave like the regular motions (which is
"				important if you replace the default motions). 
"				Thanks to Mun Johl for reporting this. 
"				Now using non-capturing parentheses \%() in the
"				patterns. 
"   1.30.013	09-Apr-2008	Refactored away s:VisualCamelCaseMotion(). 
"				Allowing users to use mappings different than
"				,w ,b ,e by defining <Plug>CamelCaseMotion_?
"				target mappings. This can even be used to
"				replace the default 'w', 'b' and 'e' mappings,
"				as suggested by Mun Johl. 
"				Mappings are now created in a generic function. 
"				Now requires Vim 7.0 or higher. 
"   1.20.012	02-Jun-2007	BF: Corrected motions through mixed
"				CamelCase_and_UnderScore words by re-ordering
"				and narrowing the search patterns.  
"   1.20.011	02-Jun-2007	Thanks again to Joseph Barker for discussing the
"				complicated visual mode mapping on the vim-dev
"				mailing list and coming up with a great
"				simplification:
"				Removed s:CheckForChangesToTheSelectionSetting().
"				Introduced s:VisualCamelCaseMotion(), which
"				handles the differences depending on the
"				'selection' setting. 
"				Visual mode mappings now directly map to the
"				s:VisualCamelCaseMotion() function; no mark is
"				clobbered, the complex mapping with the inline
"				expression has been retired. 
"   1.20.010	29-May-2007	BF: The operator-pending and visual mode ,e
"				mapping doesn't work properly when it reaches
"				the end of line; the final character of the
"				moved-over "word" remains. Fixed this problem
"				unless the "word" is at the very end of the
"				buffer. 
"				ENH: The visual mode motions now also (mostly)
"				work with the (default) setting
"				'set selection=inclusive', instead of selecting
"				one character too much. 
"				ENH: All mappings will check for changes to the
"				'selection' setting and remap the visual mode
"				mappings via function
"				s:SetupVisualModeMappings(). We cannot rely on
"				the setting while sourcing camelcasemotion.vim
"				because the mswin.vim script may be sourced
"				afterwards, and its 'behave mswin' changes
"				'selection'. 
"				Refactored the arguments of function 
"				s:CamelCaseMotion(...). 
"   1.10.009	28-May-2007	BF: Degenerate CamelCaseWords that consist of
"				only a single uppercase letter (e.g. "P" in
"				"MapPRoblem") are skipped by all motions. Thanks
"				to Joseph Barker for reporting this. 
"				BF: In CamelCaseWords that consist of uppercase
"				letters followed by decimals (e.g.
"				"MyUPPER123Problem", the uppercase "word" is
"				skipped by all motions. 
"   1.10.008	28-May-2007	Incorporated major improvements and
"				simplifications done by Joseph Barker:
"				Operator-pending and visual mode motions now
"				accept [count] of more than 9. 
"				Visual selections can now be extended from
"				either end. 
"				Instead of misusing the :[range], the special
"				variable v:count1 is used. Custom commands are
"				not needed anymore. 
"				Operator-pending and visual mode mappings are
"				now generic: There's only a single mapping for
"				,w that can be repeated, rather than having a
"				separate mapping for 1,w 2,w 3,w ...
"   1.00.007	22-May-2007	Added documentation for publication. 
"	006	20-May-2007	BF: visual mode [1,2,3],e on pure CamelCase
"				mistakenly marks [2,4,6] words. If the cursor is
"				on a uppercase letter, the search pattern
"				'\u\l\+' doesn't match at the cursor position,
"				so another match won. Changed search pattern
"				from '\l\+', 
"	005	16-May-2007	Added support for underscore notation. 
"				Added support for "forward to end of word"
"				(',e') motion. 
"	004	16-May-2007	Improved search pattern so that
"				UppercaseWORDSInBetween and digits are handled,
"				too. 
"	003	15-May-2007	Changed mappings from <Leader>w to ,w; 
"				other \w mappings interfere here, because it's
"				irritating when the cursor jump doesn't happen
"				immediately, because Vim waits whether the
"				mapping is complete. ,w is faster to type that
"				\w (and, because of the left-right touch,
"				preferred over gw). 
"				Added visual mode mappings. 
"	0.02	15-Feb-2006	BF: missing <SID> for omaps. 
"	0.01	11-Oct-2005	file creation

" Avoid installing twice or when in compatible mode
if exists('g:loaded_camelcasemotion') || (v:version < 700)
    finish
endif
let g:loaded_camelcasemotion = 1

"- mappings -------------------------------------------------------------------
" The count is passed into the function through the special variable 'v:count1',
" which is easier than misusing the :[range] that :call supports. 
" <C-U> is used to delete the unused range. 
" Another option would be to use a custom 'command! -count=1', but that doesn't
" work with the normal mode mapping: When a count is typed before the mapping,
" the ':' will convert a count of 3 into ':.,+2MyCommand', but ':3MyCommand'
" would be required to use -count and <count>. 
"
" We do not provide the fourth "backward to end" motion (,E), because it is
" seldomly used. 

function! s:CreateMotionMappings()
    " Create mappings according to this template:
    " (* stands for the mode [nov], ? for the underlying motion [wbe].) 
    "
    " *noremap <Plug>CamelCaseMotion_? :<C-U>call camelcasemotion#Motion('?',v:count1,'*')<CR>
    " if ! hasmapto('<Plug>CamelCaseMotion_?', '*')
    "	  *map <silent> ,? <Plug>CamelCaseMotion_?
    " endif

    for l:mode in ['n', 'o', 'v']
	for l:motion in ['w', 'b', 'e']
	    let l:targetMapping = '<Plug>CamelCaseMotion_' . l:motion
	    execute l:mode . 'noremap ' . l:targetMapping . ' :<C-U>call camelcasemotion#Motion(''' . l:motion . ''',v:count1,''' . l:mode . ''')<CR>'
	    if ! hasmapto(l:targetMapping, l:mode)
		execute (l:mode ==# 'v' ? 'x' : l:mode) . 'map <silent> ,' . l:motion . ' ' . l:targetMapping 
	    endif
	endfor
    endfor
endfunction

" To create a text motion, a mapping for operator-pending mode needs to be
" defined. This mapping should move the cursor according to the implemented
" motion, or mark the covered text via a visual selection. As inner text motions
" need to mark both to the left and right of the cursor position, the visual
" selection needs to be used. 
"
" Vim's built-in inner text objects also work in visual mode; they have
" different behavior depending on whether visual mode has just been entered or
" whether text has already been selected. 
" We deviate from that and always override the existing selection. 
function! s:CreateInnerMotionMappings()
    " Create mappings according to this template:
    " (* stands for the mode [ov], ? for the underlying motion [wbe].) 
    "
    " *noremap <Plug>CamelCaseMotion_i? :<C-U>call camelcasemotion#InnerMotion('?',v:count1)<CR>
    " if ! hasmapto('<Plug>CamelCaseInnerMotion_i?', '*')
    "	  *map <silent> i,? <Plug>CamelCaseInnerMotion_i?
    " endif

    for l:mode in ['o', 'v']
	for l:motion in ['w', 'b', 'e']
	    let l:targetMapping = '<Plug>CamelCaseMotion_i' . l:motion
	    execute l:mode . 'noremap ' . l:targetMapping . ' :<C-U>call camelcasemotion#InnerMotion(''' . l:motion . ''',v:count1)<CR>'
	    if ! hasmapto(l:targetMapping, l:mode)
		execute (l:mode ==# 'v' ? 'x' : l:mode) . 'map <silent> i,' . l:motion . ' ' . l:targetMapping 
	    endif
	endfor
    endfor
endfunction

call s:CreateMotionMappings()
call s:CreateInnerMotionMappings()

delfunction s:CreateMotionMappings
delfunction s:CreateInnerMotionMappings

" vim: set sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
