source ~/lib/bash/bashutils.sh

function lorg {
    # locate org files
    WHAT=${1:-.org};
    debug WHAT $WHAT;
    locate "$WHAT" | grep -e \.org\$ | grep -v backup
}

function gorg (
    # grep for WHAT in org (or EXT) files younger than AGE
    #
    # Usage:
    #   [GF=-i] [EXT=.org] [WHERE=$HOME] gorg [-h] [WHAT [AGE]]
    #
    # Enviornment Variables:
    #   WHAT   - regexp to serach for
    #   WHERE  - WHERE to search.  Default "."
    #   AGE    - files not older than AGE days.  Default 7.
    #   EXT    - Search files of this extention.  Default ".org"
    #   GF     - used for grep flags.  Set to "GF=-i" for case-insensitive, "GF=-l"  for names only
    #   DEBUG  - set to "1" for debugging
    #
    WHAT=${1:-DONE};

    if [[ $WHAT == "-h" ]]; then
        info "Usage: [GF=-i] [EXT=.org] [WHERE=$HOME] gorg [WHAT [AGE]]"
        exit 1
    fi

    AGE=${2:-7};
    [[ -v DEBUG ]] && set -x
    find ${WHERE:-.} -type f -name \*.${EXT:-org} -mtime -${AGE} -exec grep ${GF:-} --color=always -H -e  "${WHAT}" \{\} \;
    [[ -v DEBUG ]] && set +x
)
