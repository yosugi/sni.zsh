# sni - One line snippet manager for zsh

## Abstract

One line snippet manager for zsh.
This command will paste your command line selected snippet.
So, It uses not only command but also hostname, path, etc.

## Description

- select snippet via fzf
- selected snippet paste on shell prompt
- edit snippets by editor
- use comment
- surrounded '/* ... */' will be ignore

For Example.
 /path/to/dir /* #tag1 #tag2 */

## Usage

```
sni - One line snippet manager for zsh

Usage:
    sni [command]
    sni [option]

Commands:
    s, select select & paste snippet (default command)
    e, edit    edit snippet file (needs xargs -o)
    i, init    initialize snippet file
    f, file    show snippet file path
    h, help    show this message
    v, version print the version

Options:
    -h, --help    show this message
    -v, --version print the version

Version:
    0.1.1
```

## Installation

```
$ git clone https://github.com/yosugi/sni.zsh
$ mv sni.zsh/ ~/.sni.zsh/
$ echo '[ -f ~/.sni.zsh/sni.zsh ] && source ~/.sni.zsh/sni.zsh' >> ~/.zshrc
$ source ~/.zshrc
$ sni init
```

## Configuration

* $SNI_DIR
* $SNI_FILENAME
* $SNI_EDITOR
    * vim, emacs, nano...
* $SNI_FINDER
    * peco, fzf, gof...

## License

[MIT License](LICENSE)
