#!/bin/bash

##
##     Renato Silva Scripts
##     Copyright (C) 2009-2014 Renato Silva
##     GNU GPLv2 licensed
##
## This is a set of useful scripts. Some should work on Unix environments in
## general but some are specific to MSYS2/MSYS. Most of the scripts can be
## installed and removed with this install script, which should detect system
## type and install only the ones compatible. Some scripts may require adaption.
##
## Main scripts
##     backup.sh                   Secured file backup with 7-Zip.
##     bacon-crypt.rb              Base Conversion Encryption algorithm.
##     bzrcheck.sh                 Pending work check for Bazaar branches.
##     bzrgrep.rb                  Find out what revision from a Bazaar branch
##                                 has introduced some specific change.
##     bzrtags.sh                  Tag synchronization check of Bazaar branches.
##     dnsdynamic.sh               Update DNSdynamic entries automatically.
##     conconv-msys.sh             Convert encoding of MSYS console programs.
##     conconv-msys2.sh            Convert encoding of MSYS2 console programs.
##     http-shutdown.py            Shut down Windows from a remote HTTP request.
##     msys2-msys.bat              Allow using MSYS and MSYS2 together.
##     packages.sh                 Package management helper for mingw-get.
##     ppk-add.sh                  Add a PuTTY private key to current SSH agent.
##     randpass.sh                 Random password generation.
##     runcrt.sh                   Avoid timezone problems in MSVCRT programs
##                                 running in MSYS (for example Python).
##     testonsave.rb               Run JUnit tests automatically when saving
##                                 files in Eclipse (works with Kepler).
##     tz-brazil.rb                Brazilian timezone configuration for MSYS.
##     winclean.sh                 Windows system cleanup.
##
## Other scripts
##     aliases.sh                   Help with SQLite encoding issues and Bazaar
##                                  hurried commits, among others.
##     check-bookmarks.sh           Search for Firefox bookmarks that are
##                                  unorganized or have a description.
##     colordiff.pl                 Colored diff tool by Dave Ewart.
##     colornote-backup-clean.sh    Keep only last week for backups of the
##                                  Android ColorNote application.
##     csvt.rb                      Transform a CSV file according to a given
##                                  template (for example HTML conversion).
##     dcim-organizer.sh            Rename pictures from DCIM-style to
##                                  sequential enumeration.
##     homeclean.sh                 Home directory cleanup (Unix environments).
##     ivona-speak.sh               Read text aloud with IVONA reader.
##     networkmeter-reset.sh        Reset traffic statistics in Network Meter
##                                  Windows gadget.
##     numpass.sh                   Convert an alphanumeric password into
##                                  numeric-only.
##     sslcert.sh                   Generate an SSL certificate.
##     tabela-price                 How specific advances would affect a loan.
##                                  (specific to Brazil).
##     termcolors.sh                Testing terminal colors table.
##     wifi-reconnections.rb        Generate statistics from a log of Wi-Fi
##                                  reconnections.
##
## Third-party downloads
##     colormake.sh                 Colorized output for Make and GCC.
##     easyoptions                  Easy option parsing for Bash and Ruby.
##     git-bzr.py                   Bridge between Git and Bazaar.
##     vimcat.sh                    Syntax highlighting for the cat command.
##     vimpager.sh                  A terminal pager with syntax highlighting.
##     vpaste.sh                    Command-line pastebin (vpaste.net).
##
## Usage: @script.name [options], where options are:
##
##     -r, --remove        Remove the scripts instead of installing them.
##     -l, --local         Do not install the third-party downloads.
##
##         --where=PATH    Install scripts to PATH rather than /usr/local/bin,
##                         or remove them from there. This option does not
##                         affect scripts that need to be installed into
##                         /etc/profile.d. Requires --system.
##
##         --system=NAME   Set system type manually, determining which scripts
##                         will be installed. Supported systems are "unix",
##                         "msys" and "msys2".
##
##         --to-msys=ROOT  Shorthand for --system=msys --where=ROOT/local/bin.
##                         ROOT is a valid MSYS root.
##

eayoptions_url_base="https://github.com/renatosilva/easyoptions/raw/master"
easyoptions_main="easyoptions:$eayoptions_url_base/easyoptions"
easyoptions_bash="easyoptions.sh:$eayoptions_url_base/bash/easyoptions.sh"
easyoptions_ruby="easyoptions.rb:$eayoptions_url_base/ruby/easyoptions.rb"
vimpager="vimpager:https://github.com/rkitover/vimpager/raw/1b7a351/vimpager"
vpaste="vpaste:http://vpaste.net/vpaste"

all=(
    "bacon-crypt"
    "bzrcheck"
    "bzrgrep"
    "bzrtags"
    "colordiff"
    "csvt"
    "dcim-organizer"
    "dnsdynamic"
    "numpass"
    "randpass"
    "colormake:https://github.com/renatosilva/colormake/raw/master/colormake.sh"
    "vimcat:https://github.com/rkitover/vimpager/raw/1b7a351/vimcat"
)

windows=(
    "backup"
    "colornote-backup-clean"
    "ivona-speak"
    "networkmeter-reset"
    "winclean"
    "git-bzr:https://github.com/termie/git-bzr-ng/raw/master/git-bzr"
)

msys1=(
    "conconv-msys1"
    "msys2-msys.bat"
    "packages"
    "runcrt"
    "tz-brazil"
    "$easyoptions_main"
    "$easyoptions_bash"
    "$easyoptions_ruby"
)

msys2=(
    "conconv-msys2"
    "http-shutdown"
    "$vimpager"
    "$vpaste"
)

unix=(
    "$vimpager"
    "$vpaste"
    "$easyoptions_main"
    "$easyoptions_bash"
    "$easyoptions_ruby"
)

dosconv() {
    read input
    msys_encoding="${LANG##*.}"
    dos_encoding=$(cmd //c chcp)
    dos_encoding="cp${dos_encoding##*\ }"
    echo "$input" | iconv -f "$dos_encoding" ${msys_encoding:+-t $msys_encoding}
}

winlink() {
    if [[ -z "$remove" && ! -e "$where/$1" ]]; then
        cd "$where"
        cmd.exe //c mklink "$1" "$2" | dosconv
        [[ "$1" = cmd ]] && hash cmd
        cd - > /dev/null
    fi
    [[ -n "$remove" && -e "$where/$1" ]] && rm -vf "$where/$1"
}

winlinks() {
    if [[ $system = msys* ]]; then
        [[ -z "$remove" && ! -e "$where/cmd" ]] && printf "\n${title_format:-%s}\n" "Creating symlinks"
        for link in cmd attrib ipconfig net ping reg schtasks shutdown taskkill; do winlink "$link" conconv.cp850; done
        [[ $system = msys ]] && for link in bzr python ruby; do winlink "$link" runcrt; done
        winlink speak ivona-speak
    fi
}

download() {
    file="$2/$3"
    host="${1#*//}"
    host="${host%%/*}"
    wget -q --no-check-certificate -O "$file" "$1" && chmod +x "$file"
    case "$?" in
        0) printf "%s -> $2/$3\n" "$host" ;;
        *) printf "${error_format:-%s} failed downloading and installing $3\n" "Error:" >&2 ;;
    esac
}

# Colors and EasyOptions
[[ -t 1 ]] && title_format="\e[0;32m%s\e[0m"
[[ -t 2 ]] && error_format="\e[1;31m%s\e[0m"
if ! which easyoptions > /dev/null 2>&1; then
    download "$eayoptions_url_base/ruby/easyoptions.rb" /tmp "easyoptions.rb" > /dev/null || rm /tmp/easyoptions.rb
    download "$eayoptions_url_base/easyoptions"         /tmp "easyoptions"    > /dev/null || rm /tmp/easyoptions
    PATH="/tmp:$PATH"
fi
source easyoptions || exit

# Install to MSYS from a non-MSYS environment
if [[ -n "$to_msys" ]]; then
    if [[ -n "$system" || -n "$where" ]]; then
        [[ -n "$system" ]] && echo "Ambiguous options specified: --to_msys implies --system=msys."
        [[ -n "$where"  ]] && echo "Ambiguous options specified: --to_msys implies --where=$to_msys."
        exit 1
    fi
    if [[ ! -f "$to_msys/bin/msys-1.0.dll" ]]; then
        echo "Invalid MSYS root \"$to_msys\"."
        exit 1
    fi
    where="$to_msys/local/bin"
    system="msys"
fi

# Target system
if [[ -z "$system" ]]; then
    if [[ -n "$where" ]]; then
        echo "No target system specified, see --help."
        exit 1
    fi
    case $(uname -or) in
        1.*Msys) system="msys" ;;
        2.*Msys) system="msys2" ;;
        *) system="unix"
    esac
elif [[ "$system" != unix && "$system" != msys && "$system" != msys2 ]]; then
    echo "Unrecognized system type \"$system\"."
    exit 1
fi

# Prepare
default_location="/usr/local/bin"
where="${where:-$default_location}"
mkdir -p "$where"
case $system in
    unix)  scripts="${all[@]} ${unix[@]}" ;;
    msys)  scripts="${all[@]} ${windows[@]} ${msys1[@]}" ;;
    msys2) scripts="${all[@]} ${windows[@]} ${msys2[@]}" ;;
esac

# Deploy
from=$(dirname "$0")
if [[ -z "$remove" ]]; then
    printf "${title_format:-%s}\n" "Installing local scripts"
    for script in $scripts; do
        case "$script" in
            *:http*)        remote_scripts+=("$script") ;;
            conconv-msys1)  cp -v "$from/conconv-msys1.sh" "$where/conconv.cp850" ;;
            conconv-msys2)  cp -v "$from/conconv-msys2.sh" "$where/conconv.cp850" ;;
            *)              cp -v "$from/$script"* "$where/$script" ;;
        esac
    done
    mkdir -p "$to_msys/etc/profile.d"
    cp -v "$from/aliases.sh" "$to_msys/etc/profile.d/aliases.sh"
    if [[ $system != msys2 ]]; then
        if [[ -n "$to_msys" || "$where" = "$default_location" ]]; then
            echo "Adding $default_location to Ruby library path"
            echo "export RUBYLIB=\"\$RUBYLIB:$default_location\"" > "$to_msys/etc/profile.d/rubylib.sh"
        else
            echo "Ignoring configuration of Ruby library path"
        fi
    fi
    if [[ -z "$local" && -n "${remote_scripts[0]}" ]]; then
        printf "\n${title_format:-%s}\n" "Installing remote scripts"
        for script in "${remote_scripts[@]}"; do
            download "${script#*:}" "$where" "${script%%:*}"
        done
    fi
    winlinks
else
    winlinks
    for script in $scripts; do rm -vf "$where/${script%%:*}"; done
    [[ $system != msys2 ]] && rm -vf "$to_msys/etc/profile.d/rubylib.sh"
    rm -vf "$to_msys/etc/profile.d/aliases.sh"
    rm -vf "$where/conconv.cp850"
fi
