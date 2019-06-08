#!/usr/bin/env bash
#
# A simple script in bash to interact
# with the Arch User Repository (AUR).
#
# usage: aur {option} [package] [arg]
# options:
#   -S, --sync           install selected package from AUR
#   -Su, --update        update installed packages from AUR
#   -Sy, --refresh       check for new package versions in AUR
#   -Sw, --download      clone repository files from AUR only
#   -Ss, --search        search for packages matching name
#   -Sc, -Scc, --clean   remove uninstalled packages
#   -R, --remove         remove a package and delete files
#   -Q, --query          check local installed packages
#   -F, --find           find and list packages in AUR
#   -w, --web            open AUR package page on web browser
#
# Requires "package-query" from AUR:
#    https://aur.archlinux.org/packages/package-query/
#
# To install it, run:
#    $ ./aur.sh package-query

# define user settings #

DIR="/home/$USER/.aur/" # default path for cloning scripts

# define vars #

ARG="$1" # argument to execute
PKG="$2" # package to sync or search

# define functions #

function help {
    head -n 17 "$0" | tail -n 12 | sed 's/# //'; }

function sync {
    if [[ "$PKG" != "" ]]; then
        [[ -d "$DIR" ]] &&   cd "$DIR"
        [[ ! -d "$PKG" ]] && download
        [[ -d "$PKG" ]] &&   cd "$PKG" &&
        makepkg -siCcfr --needed --asdeps

    else echo 'error: no target specified (use -h for help)'; fi; }

function download {
    if [[ "$PKG" = "" ]]; then
        echo 'error: missing package argument.'; exit 1

    elif [[ -d "$PKG" ]]; then
        echo "$PKG folder already exists."; exit 1

    else # download and check
        git clone "https://aur.archlinux.org/${PKG}.git"
        [[ "$(ls -1a "$PKG" | wc -l)" = 3 ]] && rm -r "$PKG"; fi; }

function refresh {
    echo ":: Checking AUR for updated packages..."
    package-query -Au; }

function update {
    [[ -d "$DIR" ]] &&
    cd "$DIR"

    echo ":: Starting AUR packages upgrade..."
    package-query -Au | tee "$DIR/.aur"
    sed -i 's:aur/::;s: .*::' "$DIR/.aur"

    [[ "$(cat "$DIR/.aur")" = "" ]] &&
    echo " there is nothing to do" && exit 1

    [[ "$UPDATE" = "" ]] &&
    printf "\nUpdate $(wc -l "$DIR/.aur" | cut -c1) packages? [Y/n] " && read UPDATE

    if [[ "${UPDATE,,}" = y ]]; then
        while read line; do
            echo -e "\nUpdating ${line}..."
            [[ -d "$line" ]] && cd "$line" && git pull
            [[ ! -d "$line" ]] && PKG="$line" && download
            [[ -d "$line" ]] && cd "$line"
            makepkg -siCcfr --noconfirm --needed --asdeps; cd ..
            done < "$DIR/.aur"
        rm -f "$DIR/.aur"; fi; }

function remove {
    [[ -d "$DIR" ]] && cd "$DIR" &&
    [[ -d "$PKG" ]] && rm -rf "$PKG"; }

function clean {
    [[ "$ARG" = "-Scc" ]] &&
    CLEAN_ALL=true ||
    echo -e "Packages to keep:\n  All locally installed packages"

    [[ -d "$DIR" ]] &&
    cd "$DIR" &&
    echo -e "\nCache directory (AUR): $DIR"

    printf ":: Do you want to remove $([[ $CLEAN_ALL = true ]] && echo 'ALL' || echo 'all other') files from cache? [Y/n] " &&
    read CLEAN

    if [[ "${CLEAN,,}" = y ]]; then

        echo "removing $( [[ $CLEAN_ALL = true ]] && echo all||echo old ) packages from cache..."
        packages="$(package-query -Q | grep 'local/' | grep "$PKG" | sed 's:local/::' | sort)"

        for i in *; do
            [[ ! "$packages" = *"$i"* || $CLEAN_ALL = true ]] &&
                rm -rf "$i"; done; fi; }

function query {
    package-query -Q | grep 'local/' \
                     | grep "$PKG" \
                     | sed 's:local/::' \
                     | sort ; }

function search {
    package-query -As --nameonly "$PKG"; }

function find {
    RES=$(curl -s "https://aur.archlinux.org/rpc/?v=5&type=search&arg=$PKG")
    ERR=$(echo "$RES" | jq -r '.error')
    WIDTH=$(stty size | cut -d ' ' -f 2)

    if [[ "$ERR" != "null" ]]; then
        echo $ERR
        exit 1

    else echo "$RES" | jq -r '.results | .[] | .Name + "|" +
                                               .Version + "|" +
                                               .Description' |
                                               column -t -s '|' |
                                               cut -c 1-${WIDTH} |
                                               sort; fi; }

function web {
    URL="https://aur.archlinux.org/packages/$PKG"
    xdg-open "$URL"; }

function as_root {
    if [[ ! $EUID -ne 0 && ! "$*" = *'--root' ]]; then
        echo -e "error: root privileges detected\nrun as '--root' to explicity bypass this warning" 1>&2
        exit 1; fi; }

# execute #

mkdir -p "$DIR"

case "$ARG" in

    -S|--sync)
        as_root
        sync
        ;;

    -Su|--update)
        as_root
        update
        ;;

    -Sy|--refresh)
        refresh
        ;;

    -Ss|--search)
        search
        ;;

    -Sc|-Scc|--clean)
        clean
        ;;

    -Sw|--download)
        download
        ;;

    -R|--remove)
        remove
        ;;

    -Q|--query)
        query
        ;;

    -F|--find)
        find
        ;;

    -w|--web)
        web
        ;;

    *) # default
        help
        ;;

esac # finishes