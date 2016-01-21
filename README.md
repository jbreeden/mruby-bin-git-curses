git-curses
----------

![screenshot](/screenshot.png?raw=true)

Usage
-----

```
[!505 jbreeden ~/projects/mruby-bin-git-curses] git curses -h
Usage: git curses COMMAND [OPTIONS...]

COMMAND(s)
  blame - Perform an interactive git blame
```

```
[!506 jbreeden ~/projects/mruby-bin-git-curses] git curses blame -h
Usage: git-curses blame [<rev>] <file>

Commands
  All commands are essentially ruby method calls, and follow ruby syntax.
  Ex: `blame "HEAD^"` would blame the parent commit of HEAD.
  
  blame sha [, file] 
    Blame the given sha from the current file, or the `file` arg.
    (aliases: b)
  
  blame_prev
    Blame the commit prior to the one that last changed the current line.
    (aliases: bp)
  
  blame_line
    Blame the commit that last changed the current line.
    (aliases: bl)
  
  blame_head
    Blame the HEAD revision of the current file.
    (aliases: bh)
  
  pagedown
    Move one page down.
    (aliases: pd)
  
  pageup
    Move one page up.
    (aliases: pu)
  
  pagestart
    Go to page start.
    (aliases: ps, top, first)
  
  pageend
    Go to page end.
    (aliases: pe, bottom, last)
    
  goto line
    Go to the given line number.
    
  show
    Shows the commit that last changed the current line.
    This is performed by suspending the current blame and executing
    the `git show ...` command in the shell.
  
  help
    Show this help text
    
  quit
    Exit the application. Could also send ctrl-C.
    (aliases: q, exit)
```

Building
--------

Standard mruby build, just include [mruby-apr](https://github.com/jbreeden/mruby-apr) and [mruby-curses](https://github.com/jbreeden/mruby-curses) before mruby-bin-git-curses in your `build_config.rb` file.
