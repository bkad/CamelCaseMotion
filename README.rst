====================
CamelCaseMotion.vim
====================

Created By Ingo Karkat (https://github.com/inkarkat)

Description
============
Vim provides many built-in motions, e.g. to move to the next word, or end of
the current word. Most programming languages use either CamelCase
("anIdentifier") or underscore_notation ("an_identifier") naming conventions
for identifiers. The best way to navigate inside those identifiers using Vim
built-in motions is the [count]f{char} motion, i.e. f{uppercase-char} or f\_,
respectively. But we can make this easier:

This script defines motions ',w', ',b' and ',e' (similar to 'w', 'b', 'e'),
which do not move word-wise (forward/backward), but Camel-wise; i.e. to word
boundaries and uppercase letters. The motions also work on underscore notation,
where words are delimited by underscore ('_') characters. From here on, both
CamelCase and underscore_notation entities are referred to as "words" (in double
quotes). Just like with the regular motions, a [count] can be prepended to move
over multiple "words" at once. Outside of "words" (e.g. in non-keyword
characters like // or ;), the new motions move just like the regular motions.

Vim provides a built-in 'iw' text object called 'inner word', which works in
operator-pending and visual mode. Analog to that, this script defines inner
"word" motions 'i,w', 'i,b' and 'i,e', which select the "word" (or multiple
"words" if a [count] is given) where the cursor is located.

Usage
======
Use the new motions ',w', ',b' and ',e' in normal mode, operator-pending mode (cp.
:help operator), and visual mode. For example, type 'bc,w' to change 'Camel' in
'CamelCase' to something else.

**Motions Example**

Given the following CamelCase identifiers in a source code fragment::

    set Script31337PathAndNameWithoutExtension11=%~dpn0
    set Script31337PathANDNameWITHOUTExtension11=%~dpn0

and the corresponding identifiers in underscore_notation::

    set script_31337_path_and_name_without_extension_11=%~dpn0
    set SCRIPT_31337_PATH_AND_NAME_WITHOUT_EXTENSION_11=%~dpn0

,w moves to ([x] is cursor position): [s]et, [s]cript, [3]1337, [p]ath,
[a]nd, [n]ame, [w]ithout, [e]xtension, [1]1, [d]pn0, dpn[0], [s]et

,b moves to: [d]pn0, [1]1, [e]xtension, [w]ithout, ...

,e moves to: se[t], scrip[t], 3133[7], pat[h], an[d], nam[e], withou[t],
extensio[n], 1[1], dpn[0]

**Inner Motions Example**
Given the following identifier, with the cursor positioned at [x]::

    script_31337_path_and_na[m]e_without_extension_11

v3i,w selects script_31337_path_and_[name_without_extension\_]11

v3i,b selects script_31337_[path_and_name]_without_extension_11

v3i,e selects script_31337_path_and_[name_without_extension]_11

Instead of visual mode, you can also use c3i,w to change, d3i,w to delete,
gU3i,w to upper-case, and so on.

**Source**

Based on http://vim.wikia.com/wiki/Moving_through_camel_case_words by Anthony Van Ham.

Installation
=============
This script is packaged as a vimball. If you have the "gunzip" decompressor
in your PATH, simply edit the \*.vba.gz package in Vim; otherwise, decompress
the archive first, e.g. using WinZip. Inside Vim, install by sourcing the
vimball or via the ``:UseVimball`` command.

::

    vim camelcasemotion.vba.gz
    :so %

To uninstall, use the ``:RmVimball`` command.

**Dependencies**

Requires Vim 7.0 or higher.

**Configuration**

If you want to use different mappings, map your keys to the
``<Plug>CamelCaseMotion_?`` mapping targets _before_ sourcing this script (e.g. in
your .vimrc).

**Example**: Use 'W', 'B' and 'E'::

    map <S-W> <Plug>CamelCaseMotion_w
    map <S-B> <Plug>CamelCaseMotion_b
    map <S-E> <Plug>CamelCaseMotion_e

**Example**: Replace the default 'w', 'b' and 'e' mappings instead of defining
additional mappings ',w', ',b' and ',e'::

    map <silent> w <Plug>CamelCaseMotion_w
    map <silent> b <Plug>CamelCaseMotion_b
    map <silent> e <Plug>CamelCaseMotion_e
    sunmap w
    sunmap b
    sunmap e

**Example**: Replace default 'iw' text-object and define 'ib' and 'ie'
motions::

    omap <silent> iw <Plug>CamelCaseMotion_iw
    xmap <silent> iw <Plug>CamelCaseMotion_iw
    omap <silent> ib <Plug>CamelCaseMotion_ib
    xmap <silent> ib <Plug>CamelCaseMotion_ib
    omap <silent> ie <Plug>CamelCaseMotion_ie
    xmap <silent> ie <Plug>CamelCaseMotion_ie
