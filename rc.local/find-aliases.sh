# Aliases and functions to find files that have chagened
#
# This is an evolvoing collection of aliases and fucntions
# to find files that have changed from the command line.
#
# There may be some overlap.



function latest (
    # Find lastest modified files and grep them.
    #
    # define parameters that control find(1)

    WHAT=${1:-.}
    AGE=${AGE:-7}
    WHERE=${WHERE:-.}
    # define filenames/paths to be ignored
    #define junk files.  Your junk milage may vary.

    prune_linux='foo/|git/|backups/|auto-save-list|config/|snap/|cache/|local/|mozilla/|target/|.rustup/|.cargo/'
    prune_just_me='blog/docs'
    prune=".*(${prune_just_me}|${prune_linux}).*"
    #prune='.*(foo|r|git).*'
    # define errors to be ignored

    # define parameters that control grep of file content
    GREP=${GREP:-}
    FLAGS=${FLAGS:-}

    if [[ ${1} == "-h" ]]; then
        WHAT="."
        info 'Locate latst files'
        info "Usage: [WHERE=${WHERE}] [AGE=${AGE}]  latest [WHAT=${WHAT}]"
        exit 1
    fi


    [[ -v DEBUG ]] && set -x
    if [ "${GREP}" == "" ]; then
        # basic find functionality

#        find . -regextype posix-extended -regex '.*(foo|r).*' -prune -o -print

        # -xdev \

        find -L ${WHERE} \
             `: global options` \
             `: prune 'junk' files and dirs` \
             -regextype posix-extended \
             -xdev \
             -regex ${prune} -prune -o \
             `: only look at regular files ` \
             -type f \
             `: restrict to mtime AGE days ago` \
             -mtime -${AGE}\
             `: restrict to files that match WHAT in full path` \
             -regex ".*${WHAT}.*" \
             -print #\
            # TODO Add grep options
            #   - Grep sring on command line
            #     + only do --exec grep if present
            #   - option for filenames only on grep -H
            #   - optoon for case insensitive -i
            #   - option for invert -v
            # so probably some syntax like
            #
            # latest [locate options] WHAT [grep [grep optons] grep-regex]

        #| grep ${WHAT}
    else
        # grep contents of files found
        error locate does not yet implement grep for content
    fi
    [[ -v DEBUG ]] && set +x
)

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
    # Example
    #
    WHAT=${1:-"DONE"};
    AGE=${2:-7};
    WHERE=${WHERE:-$HOME};
    EXT=${EXT:-"org"}

    if [[ $WHAT == "-h" ]]; then
        info "Usage: [DEBUG=1] [FLAGS=] [EXT=.org] [WHERE=$HOME] gorg [WHAT [AGE]]"
        exit 1
    fi

    COLOR="--color=always"

    if [[ "$FLAGS" != "" ]]; then
       unset COLOR
    fi

    [[ -v DEBUG ]] && set -x
    find "${WHERE}" -xdev -type f -name \*."${EXT}" -mtime -"${AGE}" -exec grep ${COLOR:-} ${FLAGS:-} -H -e    "${WHAT}" \{\} \; |& grep -v "No such file"
    [[ -v DEBUG ]] && set +x
)
