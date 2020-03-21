#!/usr/bin/env zsh
# sni - One line snippet manager for zsh

if [[ -z "${SNI_DIR+1}" ]]; then
    SNI_DIR=~/.local/share/sni
    export SNI_DIR
fi

if [[ -z "${SNI_FILENAME+1}" ]]; then
    SNI_FILENAME=sni.txt
    export SNI_FILENAME
fi

if [[ -z "${SNI_GLOBAL_FILE_PATH+1}" ]]; then
    SNI_GLOBAL_FILE_PATH="$SNI_DIR/$SNI_FILENAME"
    export SNI_GLOBAL_FILE_PATH
fi

if [[ -z "${SNI_HOSTNAME+1}" ]]; then
    SNI_HOSTNAME=localhost
    export SNI_HOSTNAME
fi

if [[ -z "${SNI_EDITOR+1}" ]]; then
    SNI_EDITOR=vim
    export SNI_EDITOR
fi

if [[ -z "${SNI_FINDER+1}" ]]; then
    SNI_FINDER=fzf
    export SNI_FINDER
fi

if [[ -z "${SNI_ENABLE_DIRECTORY_SNIPPET+1}" ]]; then
    SNI_ENABLE_DIRECTORY_SNIPPET=false
    export SNI_ENABLE_DIRECTORY_SNIPPET
fi

function sni() {
    local cmd

    cmd=""
    if (( $# >= 1 )); then
        cmd=$1
    fi

    # generate snippet file path
    local sni_root
    sni_root="$SNI_DIR/$SNI_HOSTNAME"
    local sni_files
    sni_files=$(_sni-get-local-sni-files "$sni_root" "$SNI_FILENAME" "$PWD"; echo "$SNI_GLOBAL_FILE_PATH")

    # select exists file
    sni_exists_files=$(echo "$sni_files" | _sni-select-exists-files)
    if [[ -z "$sni_exists_files" ]]; then
        echo 'snippet file is not exists.' >&2
        return
    fi

    case $cmd in
        ("s"|"select")
            echo "$sni_exists_files" | _sni-select $SNI_FINDER;;
        ("e"|"edit")
            echo "$sni_exists_files" | _sni-edit $SNI_FINDER $SNI_EDITOR;;
        ("i"|"init")
            echo "$sni_files" | _sni-init $SNI_ENABLE_DIRECTORY_SNIPPET;;
        ("f"|"file")
            echo "$sni_exists_files";;
        ("a"|"all")
            echo "$sni_files";;
        ("-h"|"--help")
            _sni-help;;
        ("-v"|"--version")
            _sni-version;;
        (*)
            if (( $# == 0 )); then
                echo "$sni_exists_files" | _sni-select $SNI_FINDER
            else
                echo "invalid command"
                _sni-help
            fi;;
    esac
}

function _sni-print-z() {
    print -z "$(cat -)"
}

function _sni-trim() {
    sed -e 's/^[ \t]*//' -e 's/[ \t]*$//'
}

function _sni-remove-comment() {
    cat - |
        perl -pe 's#^/\*.*?\*/##g' |
        perl -pe 's#(.+)/\*.*?\*/$#\1#g'
}

function _sni-select() {
    local finder

    finder=$1

    cat - |
        xargs cat |            # concatenate each snippet files
        cat -n |               # add line number
        eval "${finder}" |     # select snippet
        awk '{$1=""; print}' | # remove line number
        _sni-trim |
        _sni-remove-comment |
        _sni-trim |
        _sni-print-z
}

function _sni-select-exists-files() {
    awk '{if(system("[ -f "$1" ]") == 0) {print $1}}'
}

function _sni-edit() {
    local finder
    local editor

    finder=$1
    editor=$2

    eval "${finder}" | xargs -o "$editor"
}

function _sni-init() {
    local sni_is_enable_directory_snippet
    local sni_files
    local local_file_path
    local current_file_path

    sni_is_enable_directory_snippet=$1
    sni_files=$(cat - | sed '$d')
    local_file_path=$(echo "$sni_files" | tail -n 1)

    # local snippet
    if [[ ! -d ${local_file_path:h} ]]; then
        mkdir -p "${local_file_path:h}"
    fi

    if [[ ! -e ${local_file_path} ]]; then
        touch "${local_file_path}"
    fi

    if [[ $sni_is_enable_directory_snippet == false ]]; then
        return 0
    fi

    # directory snippet
    current_file_path=$(echo "$sni_files" | head -1)
    if [[ ! -d "${current_file_path:h}" ]]; then
        mkdir -p "${current_file_path:h}"
    fi

    if [[ ! -e "${current_file_path}" ]]; then
        touch "${current_file_path}"
    fi

    return 0
}

function _sni-get-local-sni-files() {
    local sni_root
    local sni_filename
    local current_dir

    sni_root=$1
    sni_filename=$2
    current_dir=$3

    if [[ $current_dir = "/" || $current_dir = "" ]]; then
        echo "$sni_root/$sni_filename"
        return
    fi

    echo "$sni_root$current_dir/$sni_filename"

    _sni-get-local-sni-files "$sni_root" "$sni_filename" "$(dirname "$current_dir")"
}

function _sni-version() {
    echo "0.1.0"
}

function _sni-help() {
cat - <<EOT
sni - One line snippet manager for zsh

Usage:
    sni [command]
    sni [option]

Commands:
    s, select  select & paste snippet (default command)
    e, edit    edit snippet file (needs xargs -o)
    i, init    initialize snippet file
    f, file    show snippet file path

Options:
    -h, --help    show this message
    -v, --version print the version

Version:
    $(_sni-version)
EOT
}
