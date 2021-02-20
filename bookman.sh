#!/bin/sh

BOOKMAN_DIR="$HOME"/.local/share/bookman
CONFIG_DIR="$HOME"/.config/bookman/bookman.conf
WEB_BROWSER="firefox"

usage () { printf %s "\
Bookman - bookmark manager

-a [name] add an entry
-r [name] remove an entry
-s [name] search for an entry or list all
-u [name] open the bookmark in a web browser(defaults to firefox)

Web browser can be changed by writing WEB_BROWSER=[browser] to
    ~/.config/bookman/bookman.conf
"
exit 1
}

die () {
    printf '%s.\n' "$1" >&2
    exit 1
}

get_entry() {
    printf %s "$1" | sed 's/.*\///'
}

get_dir() {
    printf %s "./$(printf %s "$1" | sed "s/\/$(get_entry "$1").*//")"
}

add_ent() {
    mkdir -p "$(get_dir "$1")"
    printf 'what is the url: ' 
    read -r URL
    printf %s "$URL" > "./$1"
}

remove_ent () {
    [ -e "./$1" ] || die "$1 does not exist"
    rm "$(find -L . -path "./$1")"
    DIR="$(get_dir "$1")"
    [ -z "$(ls "$DIR")" ] && rmdir "$DIR"
}

search () {
    find -L . -type f | sed 's/..//' | grep "$1"
}

use() {
    FILE=$(find -L . -path "./$1")
    [ -e "$FILE" ] || die "$1 does not exist"
    "$WEB_BROWSER" "$(cat "$FILE")" 
}

main() {
    mkdir -p "$BOOKMAN_DIR" || die "Couldn't create bookmark directory"
    cd "$BOOKMAN_DIR" || die "Couldn't access bookmark directory"
    # It's a config file for one var that has a default value
    # shellcheck source=/dev/null
    [ -e "$CONFIG_DIR" ] && . "$CONFIG_DIR"

    case $1 in
        "-a" ) add_ent "$2"     ;;
        "-r" ) remove_ent "$2"  ;;
        "-s" ) search "$2"      ;;
        "-u" ) use "$2"         ;;
           * ) usage            ;;
    esac
}

main "$@"
