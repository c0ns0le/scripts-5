#!/bin/bash

# Check Commit Timezone 2013.10.5
# Copyright (c) 2012, 2013 Renato Silva
# GNU GPLv2 licensed

# This program goes recursively through a directory hierarchy searching
# for Bazaar branches containing wrong commit dates with BRST timezone
# within BRT period, for years 2012 and 2013.

check() {
    # Standard time from 2012-02-26 to 2012-10-20
    brt_2012="2012-(02-2[6-9]|0[3-9]-..|10-(0[1-9]|1[0-9]|20))"

    # Standard time from 2013-02-17 to 2013-10-19
    brt_2013="2013-(02-(1[7-9]|2[0-9])|0[3-9]-..|10-(0[1-9]|1[0-9]))"

    # Friendly branch name
    echo "$0:" | sed s/"\/.bzr"// | sed s/".*\/"//

    # Catch DST commits out of DST period
    for brt in "$brt_2012" "$brt_2013"; do
        bzr log "$0/.." | grep -E -B3 "^timestamp: ... $brt .* -0200" | grep -vE "^(committer|branch nick)" | sed -E s/'^(revno|timestamp)'/'    \1'/
    done
}

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "Usage: $0 [root]"
    echo "Without arguments, root is current directory."
    exit
fi

root="$1"
[ -z "$1" ] && root="."
export -f check
find "$root" -name ".bzr" -type d -exec bash -c check '{}' \;
