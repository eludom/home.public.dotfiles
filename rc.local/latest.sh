function latest (
    # Find lastest modified files and grep them.
    #
    # This is really just a wrapper around find -exec grep,
    # but it encapsulates some defaults/patterns I use a lot
    #
    #   - Looking for recently modified (AGE) files
    #   - Looking at certain types of files (WHAT, e.g. .org)
    #   - Looking in the current directory (WHERE) usually
    #   - Grep(1)ing for file content (GREP)
    #     + sometimes case insensitive
    #     + usually using --color
    #   - Ignoring junk (PRUNE)

    # Define some logging aliases
    source ~/lib/bash/bashutils.sh || `: # Use my library if available`\
    `: fall back to echo`
    alias info=echo && \
    alias warn=echo && \
    alias error=echo

    #
    # Defaults for parameters that control find(1)
    #
    WHAT=${WHAT:-org}
    AGE=${AGE:-7}
    WHERE=${WHERE:-.}
    # define filenames/paths to be ignored
    #   "junk" stanard on linux systems
    PRUNE_LINUX='git/|backups/|auto-save-list|config/|snap/|cache/|local/|mozilla/|target/|.rustup/|.cargo/'
    #   junk specific to me  Your junk milage may vary.
    PRUNE_JUST_ME='blog/docs'
    PRUNE=".*(${PRUNE_JUST_ME}|${PRUNE_LINUX}).*"
    #
    # defaults for parameters that control grep of file content
    #
    GREP=${GREP:-}
    #
    # define errors to be ignored
    #
    # TODO grep out?


    function usage ()  {
        message=${1:-""}
        cat <<EOF 1>&2
Usage: latest [options] [WHAT]

       find the latest files and what's in them.

Options
  -a|--age=AGE         Max age of files to find.   Default: $AGE
  -h|--help            print help text
  -g|--grep=REGEX      Regex to grep in files.     Default: None.
  -s|--sensitive       Grep is case sensitive.     Default: case insensitive.
  -w|--where=DIR       Where to search for files.  Default: $WHERE

Arguments
  WHAT		Filenames to search for, in full path.  Default: $WHAT

Examples:
  # find latest .org files in current directorry
  lastest

  # find .sql files modified in the last 30 days in the home directory
  latest -a 30 -w $HOME sql

  # find python files with "pandas"
  latest -g pandas .py

EOF

    }

    # parse optons
    while [ $# > 0 ]; do
      case ${1} in
        -a|--age)	shift; AGE="$1"; [[ $# > 0 ]] && shift || die '--age requires an argument';;
        -d|--debug)	DEBUG=1 && shift;;
        -g|--grep)	shift; REGEX="${1}" && shift || die '--grep requires an argument';;
        -h|--help)	usage && return 1;;
        -w|--where)	shift; WHERE="$1" && shift || die '--where requires an argument';;
        -*)              error "Unknown flag: $1" && return 1;;
        *)             break;;
       esac
    done

    # parse args


    if [[ $# = 1 ]]; then
        WHAT="$1"
    elif [[ $# > 1 ]]; then
        die "too many arguments given ($#).  At most one allowed"
    fi

   [[ -v DEBUG ]] && set -x

   GREPFLAGS=()
   if [[ -v REGEX ]]; then
       GREPFLAGS=("-exec" "grep" "--color=always" "-H ""-E"  "$REGEX" '{}' ';')
   else
       GREPFLAGS=( '-print' )
   fi

   find -L ${WHERE} \
        `: global options` \
        `: prune 'junk' files and dirs` \
        -regextype posix-extended \
        -xdev \
        -regex "${prune}" -prune -o \
        `: only look at regular files ` \
        -type f \
        `: restrict to mtime AGE days ago` \
        -mtime -${AGE}\
        `: restrict to files that match WHAT in full path` \
        -regex ".*${WHAT}.*" \
        ${GREPFLAGS[*]}
        #-print #\
   #     # TODO Add grep options
   # #   - Grep sring on command line
   #          #     + only do --exec grep if present
   #          #   - option for filenames only on grep -H
   #          #   - optoon for case insensitive -i
   #          #   - option for invert -v
   #          # so probably some syntax like
   #          #
   #          # latest [locate options] WHAT [grep [grep optons] grep-regex]

   #      #| grep ${WHAT}
   #  # [[ -v DEBUG ]] && set +x
)
