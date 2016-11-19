vim-repl
========

[VERSION: 0.1]

Overview
--------

A neovim specific means of sending data off to a terminal. I wanted easy
mappings to load up a terminal (or reopen a used terminal) to send bits of code
to. While other options exist, [neoterm](https://github.com/kassio/neoterm) was
not as extendible as I liked and
[vim-slime](https://github.com/jpalardy/vim-slime) required almost as much code
to revise in my ideal workstyle as it did to simply create this plugin.

Installation
------------

I prefer using [vim-plug](https://github.com/junegunn/vim-plug) for plugin
management as follows:

```vim
Plug 'jrpotter/vim-highlight'
```

Follow use according to plugin manager you use or optionally copy
the directories from this repo into ```$VIM_DIR```.

Usage
-----

Currently, opening a new terminal is done horizontally by ```<Leader>ss``` and
vertically by ```<Leader>sv```. To send data to the terminal defaults to using
```<C-c><C-c>``` while in normal or visual mode, or by sending the entire buffer
contents to the terminal via ```<C-c><C-f>```. The REPLs that are open can be
completely restarted via ```<C-c><C-r>```.

To define which REPLs open depending on the buffer entered, modify the
```g:repl_targets``` variable. This is a dictionary of filetypes to a list of
binaries to be attempted to open in order. For instance, the ```python```
filetype defaults to ```['ipython', 'python3']``` and as such, ```ipython``` is
attempted first and ```python3``` if ```ipython``` doesn't exist.

If all fallback programs fail, ```g:repl_default_command``` is open instead
(which, if undefined, is ```$SHELL -d -f```.

