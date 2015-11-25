CamelCaseMotion.vim
====================

Created By [Ingo Karkat](https://github.com/inkarkat)

Description
-----------
Vim provides many built-in motions, e.g. to move to the next word, or end of
the current word. Most programming languages use either CamelCase
("anIdentifier") or underscore_notation ("an_identifier") naming conventions
for identifiers. The best way to navigate inside those identifiers using Vim
built-in motions is the [count]f{char} motion, i.e. f{uppercase-char} or f_,
respectively. But we can make this easier:

This script defines motions similar to `w`, `b`, `e` which do not move
word-wise (forward/backward), but Camel-wise; i.e. to word boundaries and
uppercase letters. The motions also work on underscore notation, where words
are delimited by underscore ('_') characters. From here on, both CamelCase
and underscore_notation entities are referred to as "words" (in double quotes).
Just like with the regular motions, a [count] can be prepended to move over
multiple "words" at once. Outside of "words" (e.g. in non-keyword characters
like / or ;), the new motions move just like the regular motions.

Vim provides a built-in `iw` text object called 'inner word', which works in
operator-pending and visual mode. Analog to that, this script defines inner
"word" motions which select the "word" (or multiple "words" if a [count] is
given) where the cursor is located.

Usage
======
To use the default mappings, add the following to your vimrc:

```vim
call camelcasemotion#CreateMotionMappings('<leader>')
```

If you want to use different mappings, map your keys to the
<Plug>CamelCaseMotion_? mapping targets your vimrc).

EXAMPLE: Map to w, b and e mappings:

```vim
map <silent> w <Plug>CamelCaseMotion_w
map <silent> b <Plug>CamelCaseMotion_b
map <silent> e <Plug>CamelCaseMotion_e
map <silent> ge <Plug>CamelCaseMotion_ge
sunmap w
sunmap b
sunmap e
sunmap ge
```

EXAMPLE: Map iw, ib and ie motions:

```vim
omap <silent> iw <Plug>CamelCaseMotion_iw
xmap <silent> iw <Plug>CamelCaseMotion_iw
omap <silent> ib <Plug>CamelCaseMotion_ib
xmap <silent> ib <Plug>CamelCaseMotion_ib
omap <silent> ie <Plug>CamelCaseMotion_ie
xmap <silent> ie <Plug>CamelCaseMotion_ie
```

Most commonly motions are `<leader>w`, `<leader>b` and `<leader>e`, all of which can
be used in normal mode, operator-pending mode (cp. `:help operator`), and visual
mode. For example, type `bc<leader>w` to change 'Camel' in 'CamelCase' to
something else.

The `<leader>` string is defined with the `mapleader` variable in vim, and
defaults to the backslash character (`\`). Therefore, the motions defined by
this plugin would resolve to `\w`, `\b` and `\e`. Some vim users prefer to use
the comma key (`,`), which you may have already defined in your vimrc. To
check your current mapleader, execute:

```vim
:let mapleader
```

If you get an error, you are still using the default (`\`). If you wish to
define a new mapleader, try:

```vim
:let mapleader = "your_new_mapleader_string"
```

Drop the `:` if you are defining the mapleader in your vimrc. For more
information about mapleader, check out:

```vim
:help mapleader
```

Motions Example
---------------

Given the following CamelCase identifiers in a source code fragment:

```
set Script31337PathAndNameWithoutExtension11=%~dpn0
set Script31337PathANDNameWITHOUTExtension11=%~dpn0
```

and the corresponding identifiers in underscore_notation:

```
set script_31337_path_and_name_without_extension_11=%~dpn0
set SCRIPT_31337_PATH_AND_NAME_WITHOUT_EXTENSION_11=%~dpn0
```

<leader>w moves to ([x] is cursor position): [s]et, [s]cript, [3]1337, [p]ath,
[a]nd, [n]ame, [w]ithout, [e]xtension, [1]1, [d]pn0, dpn[0], [s]et

<leader>b moves to: [d]pn0, [1]1, [e]xtension, [w]ithout, ...

<leader>e moves to: se[t], scrip[t], 3133[7], pat[h], an[d], nam[e], withou[t],
extensio[n], 1[1], dpn[0]

Inner Motions Example
---------------------
Given the following identifier, with the cursor positioned at [x]:

```
script_31337_path_and_na[m]e_without_extension_11
```

v3i<leader>w selects script_31337_path_and_[name_without_extension_]11

v3i<leader>b selects script_31337_[path_and_name]_without_extension_11

v3i<leader>e selects script_31337_path_and_[name_without_extension]_11

Instead of visual mode, you can also use c3i<leader>w to change, d3i<leader>w
to delete, gU3i<leader>w to upper-case, and so on.

Source
------

Based on [Moving through camel case words](http://vim.wikia.com/wiki/Moving_through_camel_case_words) by Anthony Van Ham.

Installation
------------
If you're using [Vundle](https://github.com/VundleVim/Vundle.vim),
just add `Plugin 'bkad/CamelCaseMotion'` to your .vimrc and run `:PluginInstall`.

If you're using [pathogen](https://github.com/tpope/vim-pathogen),
add this repo to your bundle directory.

Dependencies
------------

Requires Vim 7.0 or higher.
