source ~/lib/bash/bashutils.sh || \
    alias info=echo && \
    alias warn=echo && \
    alias error=echo

function lorg (
    # Locate .org (or .${EXT}) files
    #
    # Usage:
    #   [FLAGS=-i] [EXT=.org] org [-h] [WHAT]
    #
    # Enviornment Variables:
    #   WHAT   - regexp to serach for
    #   EXT    - Search files of this extention.  Default ".org"
    #   FLAGS  - used for locate flags.  Set to "FLAGS=-i" for case-insensitive.
    #   DEBUG  - set to "1" for debugging
    #
    WHAT=${1:-$HOME};
    FLAGS=${FLAGS:-'-r'}

    if [[ $WHAT == "-h" ]]; then
        info "Usage: [FLAGS=] [EXT=.org]  lorg [WHAT]"
        exit 1
    fi

    [[ -v DEBUG ]] && set -x
    \locate "${FLAGS}" "${WHAT}" | grep -e \."${EXT:-org}"\$ | grep -v backup
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

    if [[ $WHAT == "-h" ]]; then
        info "Usage: [FLAGS=-i] [EXT=.org] [WHERE=$HOME] gorg [WHAT [AGE]]"
        exit 1
    fi

    AGE=${2:-7};
    [[ -v DEBUG ]] && set -x
    find "${WHERE:-.}" -type f -name \*."${EXT:-org}" -mtime -"${AGE}" -exec grep "${FLAGS:-}" --color=always -H -e  "${WHAT}" \{\} \;
    [[ -v DEBUG ]] && set +x
)
