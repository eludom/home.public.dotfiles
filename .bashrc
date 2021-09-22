#PROG=`basename "$0" | tr -d '\n'`  # normal setting
PROG="bashrc" # setting for bashrc due to errors

function info()  { echo ${PROG}\: info: "$@" 1>&2; }
function warn()  { echo ${PROG}\: warning: "$@" 1>&2; }
function error() { echo ${PROG}\: error: "$@" 1>&2; }
function debug() { [[ -v DEBUG ]] && echo ${PROG}\: debug: "$@" 1>&2 || true ; }
function die()   { echo ${PROG}\: fatal: "$@" 1>&2 && exit 1; }

export PS1="\# [\t] \u@\h \W/ $ "

alias rm='	rm -i'
alias ag='	alias | grep -i'
alias eg='	printenv | grep -i'
alias hg='	history | grep -i'
alias ht='	history | tail'
alias fpg='	find . -print | egrep -i'
alias egi='	egrep -i'
alias psg='	/bin/ps -auxww | grep'
alias p8='	ping -c 3 8.8.8.8' # make sure routing works
alias pp='	ping -c 3 port111.com' # make sure dns and routing work
alias locate='locate -r'

alias count='sort | uniq -c | sort -nr'
alias listening='sudo lsof -i | grep LISTEN'
alias ips='ifconfig | grep inet'

function dirl() {
    # "DIR"ectory "L"ist directory stack, one per line
    # Usage: dirl

    for d in `dirs`; do echo $d; done
}

function dirc() {
    # "DIR"ectory "C"onnect - connect to directory and list stack
    # Usage: dirc [DIR

    pushd ${1:-"$HOME"} > /dev/null
    dirl
}

function dirp () {
    # "DIR"ectory "P"op - pop N entries off the directory stack
    # Usage: dirp [N]
    #
    # OLD:
    #   alias  dirp='popd > /dev/null && dirl'
    for i in `seq ${1:-"1"}`; do
        debug "dirl: popd. i is $i"
        popd > /dev/null;
    done
    dirl
}

alias cd=pushd

function gf() {
# grep-find: grep for patterins in files via find
#
# Usage: gf patterns [files [days]]
#
# Examples:
#   gf findMeAnywhere
#   gf findMeInTextFiles '*.txt'
#   gf findMeInTextFiles .txt
#   gf BEGIN\|END .org 30

local files=""
local days="365"

set -o noglob

# First arg is pattern(s) for egrep
if [ -z ${1+x} ]; then
  echo 'gf needs string(s) to search for ' 1>&2
  info "Usage: gf patterns [files [days]]"
  return 1
fi

# Second arg (if present) is files for find.  No globbing, so "*.txt" OK
if [ ! -z ${2+x} ]; then
  if [[ "$2" =~ ^\. ]]; then
    # Special case: treat ".foo" as "*.foo"
    # Avoids needing to quote on command line
    files="-name *$2"
  else
    files="-name ${2}"
  fi
fi

# $3 (if present) is find -mtime arg, default 365
if [ ! -z ${3+x} ]; then
  days="${3}"
fi

# set -x
find . -type f -mtime -${days} $files -exec egrep --color -H -i "${1}" \{\} \;
# set +x

set +o noglob
}

# Preserve history across sesssions
#
# http://unix.stackexchange.com/questions/1288/preserve-bash-history-in-multiple-terminal-windows
#
export HISTCONTROL=ignoredups:erasedups  # no duplicate entries
export HISTSIZE=100000                   # big big history
export HISTFILESIZE=100000               # big big history
shopt -s histappend                      # append to history, don't overwrite it

# Save and reload the history after each command finishes
export PROMPT_COMMAND="history -a; history -c; history -r;"


function hgt() {
    # hgt == "history grep (for arg) tail"
    #echo "Histroy Grep tail"

    if [ -z ${1+x} ]; then
        echo 'hgt needs an argument' 1>&2
        return 1
    fi

    history | grep -i "$1" | tail
    return 0
}

if [ -e ${HOME}/etc/hostname ]; then
    export HOSTNAME=`cat ${HOME}/etc/hostname`
elif [ -e /etc/hostname ]; then
    export HOSTNAME=`cat /etc/hostname`
else
    export HOSTNAME="unknown"
fi

# Set timezone if ~/bin/tz.sh exists

# NEW, if neeeed?
#
# https://linuxize.com/post/how-to-set-or-change-timezone-in-linux/
#
# OLD:
#
# if [ -e ~/bin/tz.sh ]; then
#     echo Setting timezone.
#     source ~/bin/tz.sh # should be in ~/rc.local
# fi

# STILL NEEDED?
#
# Set local for numeric output
LOCAL=`locale -a | grep -i en_us | head -1`
if [[ "$LOCAL" != "" ]]; then export LC_NUMERIC="$LOCAL"; fi

if [ -e ~/bin/sshagent ]; then
    source ~/bin/sshagent
fi

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  alias 2clip='xclip -selection c'
  alias 3clip='printf %s "$(cat /dev/stdin)" | xclip -selection c'  # no final \n
elif [[ "$OSTYPE" == "darwin"* ]]; then
  alias 2clip='pbcopy'
fi

pathrm() {
    # remove an item from the path
    if [ -d "$1" ]; then
        removeThis="`echo $1 | sed -e 's#/#\\\/#'g`"
        newPath=`echo $PATH | awk -v RS=: -v ORS=: "/$removeThis/ {next} {print}" | sed 's/[ :]*$//g'`
        export PATH=$newPath
    fi
}


pathlast() {
    # add path to the end if not there
    if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
        export PATH="${PATH:+"$PATH:"}$1"
    fi
}


pathfirst() {
    # add path to the front if not there
    if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
        export PATH="$1:${PATH}"
    fi
}

path() {
  # show path
  echo $PATH
}

# show path, one entry per line
alias pathcat="echo $PATH | sed 's/:/\n/g'"


# Be sure we have a few specific paths if they exist

pathlast $HOME/bin
pathlast /usr/local/bin
pathlast /opt/bin

if [ -d ${HOME}/rc.local ]; then
    for rcfile in $(find ${HOME}/rc.local -name \*.sh); do
        debug running localrc ${rcfile}
        source ${rcfile}
    done
fi

alias emacs='setsid emacs'

# from http://stuff-things.net/2014/12/16/working-with-emacsclient/

if [ -z "$SSH_CONNECTION" ]; then
    export EMACSCLIENT=emacsclient
    alias ec="$EMACSCLIENT -c -n"
    export EDITOR="$EMACSCLIENT -c"
    export ALTERNATE_EDITOR=""
else
    export EDITOR=$(type -P emacs || type -P ed)
fi
export VISUAL=$EDITOR

# coloring for ls functions

if [[ "$OSTYPE" == "linux-gnu" ]]; then
    color="--color";
else
    color=""
fi

BIN_LS=/bin/ls
alias ls='	ls '$color' -a'


# Long List Reverse Tail
function llrt() { ls -lrt $color ${*:-}; }

# Long List Time
function llt() { ls -lt $color ${*:-}; }

# Long List Time, More
function lltm() { ls -lt $color ${*:-} | more; }

# Long List Time, Less
function lltl() { ls -alt $color ${*:-} | more; }

# Long List Time, Head
function llth() { ls -lt $color ${*:-} | head; }

# Long List Time, Tail
function lltt() { ls -alt $color ${*:-} | tail; }


# List Sort Size
function lss() { ls -a1s $color ${*:-} | sort -n; }

# List Sort Size Reverse
function lssr() { ls -a1s $color ${*:-} | sort -nr; }

function nf ()
{
    # list the newest file in the current directory
    NF=`find ${1:-.} -maxdepth 1 -type f -print0 | xargs -0 ls -1t  |  head -1;`;
    echo ${NF:-/dev/null} | sed "s/ /\\\ /g"
}


# new file tail file
function nftf { NF=`nf ${1:-.}`; debug NF $NF;  echo "$NF" | xargs tail -f  ; }

# new file tail
function nft { NF=`nf ${1:-.}`; debug NF $NF;  echo "$NF" | xargs tail  ; }

# new file head
function nfh { NF=`nf ${1:-.}`; debug NF $NF;  echo "$NF" | xargs head  ; }

# new file less
function nfl { NF=`nf ${1:-.}`; debug NF $NF;  echo "$NF" | xargs less  ; }

# new file cat
function nfc { NF=`nf ${1:-.}`; debug NF $NF;  echo "$NF" | xargs cat  ; }

# new file ls
function nfls { NF=`nf ${1:-.}`; debug NF $NF;  echo "$NF" | xargs ls -A1t  ; }

# new file ls -l
function nflsl { NF=`nf ${1:-.}`; debug NF $NF;  echo "$NF" | xargs
ls -Atl  ; }

if [[  ! -z "`which xdg-open`" ]]; then alias open='xdg-open '; fi

touch $HOME/.bashrc-ran
debug ".bashrc done"
