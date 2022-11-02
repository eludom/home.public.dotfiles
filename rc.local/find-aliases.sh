# Define some logging aliases
source ~/lib/bash/bashutils.sh || `: # Use my library if available`\
    `: fall back to echo`
    alias info=echo && \
    alias warn=echo && \
    alias error=echo

function lorg (
    # Locate .org files
    #
    # This function was written primarily to find .org files in my home directory.
    #
    # It used locate(1) to search fro WHAT
    # It can be used to find files of other types (EXT=) anywhere (WHERE=).
    # Certian files/patters (files with spaces) can be ignored with EXCLUDE=
    # Setting DEBUG=1 will print the commands executed (set -x)

    if [[ ${1} == "-h" ]]; then
        info 'Locate .org files'
        info 'Usage: [WHERE=$HOME] [EXCLUDE=regexps] [FLAGS=] [EXT=.org]  lorg [WHAT]'
        exit 1
    fi

    # By default, WHAT is everything
    WHAT=${1:-'*'};
    # Only include files with this extention
    EXT=${EXT:-org}
    # Only include things here (change to WHERE=/ for whole system)
    WHERE=${WHERE:-$HOME}
    # grep -E pattern of thigs to exclude (junk files, backups, files with spaces..)
    EXCLUDE='backup|[[:space:]]'

    [[ -v DEBUG ]] && set -x
    \locate -i "${WHAT}" | `: # locate files with WHAT in them` \
     grep -E \\."${EXT}"\$ | `: # Only include things ending in .${EXT} `\
     grep -E "${WHERE}" | `: # Only include things in these dirs ($HOME,"/"...)`\
     grep -E -v "$EXCLUDE" `: # exclude patterns form EXCLUDE (backups, spaces...)`
    [[ -v DEBUG ]] && set +x
)

function gorg (
    # grep for WHAT in org (or EXT) files younger than AGE
    #
    # Usage:
    #   [FLAGS=-i] [EXT=.org] [WHERE=$HOME] gorg [-h] [WHAT [AGE]]
    #
    # Enviornment Variables:
    #   WHAT   - regexp to serach for
    #   WHERE  - WHERE to search.  Default "."
    #   AGE    - files not older than AGE days.  Default 7.
    #   EXT    - Search files of this extention.  Default ".org"
    #   FLAGS  - used for grep flags.  Set to "FLAGS=-i" for case-insensitive, "FLAGS=-l"  for names only
    #   DEBUG  - set to "1" for debugging
    #
    WHAT=${1:-DONE};
    WHERE=${WHERE:-$HOME};

    if [[ $WHAT == "-h" ]]; then
        info "Usage: [FLAGS=-i] [EXT=.org] [WHERE=$HOME] gorg [WHAT [AGE]]"
        exit 1
    fi

    AGE=${2:-7};
    [[ -v DEBUG ]] && set -x
    find "${WHERE}" -xdev -type f -name \*."${EXT:-org}" -mtime -"${AGE}" -exec grep "${FLAGS:-}" --color=always -H -e  "${WHAT}" \{\} \; |& grep -v "No such file"
    [[ -v DEBUG ]] && set +x
)
