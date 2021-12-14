#  This is George Jone's .bashrc file
#

# These should be set but sometimes cause problems (shell exiting)
#   set -e
#   set -u

# Don't exit out of login shell on error
set +e

# Set to debug
#   export DEBUG=1

#PROG=`basename "$0" | tr -d '\n'`  # normal setting
PROG="bashrc" # setting for bashrc due to errors

function info()  { echo ${PROG}\: info: "$@" 1>&2; }
function warn()  { echo ${PROG}\: warning: "$@" 1>&2; }
function error() { echo ${PROG}\: error: "$@" 1>&2; }
function debug() { [[ -v DEBUG ]] && echo ${PROG}\: debug: "$@" 1>&2 || true ; }
function die()   { echo ${PROG}\: fatal: "$@" 1>&2 && exit 1; }


function set_xtitle {
    # set X window title
    #
    # Usage:
    #
    #   set_xtitle [name]
    WINDOW_NAME="${1:-`basename $PWD`}"
    PROMPT_COMMAND="echo -ne \"\033]0;${WINDOW_NAME} $USER@$HOSTNAME:$PWD\007\"";
}
export PS1="\# [\t] \u@\h \W/ $ "

#
# Aliases from ages past
#

# shell related
alias ag='	alias | grep -i'
alias eg='	printenv | grep -i'
alias hg='	history | grep -i'
alias ht='	history | tail'
alias egi='	egrep -i'
# File related
alias rm='	rm -i'
alias locate='locate -r'
alias fpg='	find . -print | egrep -i'
# Process related
alias psg='	/bin/ps -auxww | grep'
# Network related
alias listening='sudo lsof -i | grep LISTEN'
alias ips='ifconfig | grep inet'
alias p8='	ping -c 3 8.8.8.8' # make sure routing works
alias pp='	ping -c 3 port111.com' # make sure dns and routing work
# utilities/statistics
alias count='sort | uniq -c | sort -nr' # count unique things on stdin

# Newer aliases

# json pretty prett print
alias jpp="python -m json.tool"

#
# Shell-related functions
#


#
# Directory stack functions
#
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



# Preserve history across sesssions
#
# http://unix.stackexchange.com/questions/1288/preserve-bash-history-in-multiple-terminal-windows
#
export HISTCONTROL=ignoredups:erasedups  # no duplicate entries
export HISTSIZE=100000                   # big big history
export HISTFILESIZE=100000               # big big history
shopt -s histappend                      # append to history, don't overwrite it

# Save and reload the history after each command finishes

if [[ -z "${DISPLAY}" ]]; then
    export PROMPT_COMMAND="history -a; history -c; history -r;echo -ne \"\033]0;$USER@$HOSTNAME:$PWD\007\""
else
    # in X-land, set window title to user@host:pwd
    export PROMPT_COMMAND="history -a; history -c; history -r;echo -ne \"\033]0;\`whoami\`@\`hostname -s\`:\`pwd\`\007\""
fi

# modern GPG setup
# https://stackoverflow.com/questions/17769831/how-to-make-gpg-prompt-for-passphrase-on-cli
#
GPG_TTY=$(tty)
export GPG_TTY

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

#
# set hostname
#
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

#
# Start SSH agent
#
if [ -e ~/bin/sshagent ]; then
    source ~/bin/sshagent
fi

#
# Copy to clipbloard/paste buffer without using the mouse
#
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  alias 2clip='xclip -selection c'
  alias 3clip='printf %s "$(cat /dev/stdin)" | xclip -selection c'  # no final \n
elif [[ "$OSTYPE" == "darwin"* ]]; then
  alias 2clip='pbcopy'
fi


#
# Path aliases
#
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
pathfirst $HOME/.local/bin
pathlast /usr/local/bin
pathlast /opt/bin

#
# Source scripts in ~/rc.local/*.sh
#
# These are for setup in different environments
# .e.g. I only set up email on my laptop.
#
if [ -d ${HOME}/rc.local ]; then
    for rcfile in $(find ${HOME}/rc.local -name \*.sh); do
        debug running localrc ${rcfile}
        source ${rcfile}
    done
fi


#
# Emacs setup
#
# TODO: move to ~/rc.local
#   + I (sadly) don't urn emacs everwhere
#
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

#
# Various ls functions
#

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


if [[  ! -z "`which xdg-open`" ]]; then
    alias open='xdg-open ';
    export OPEN='xdg-open ';
else
    export OPEN='echo OPEN not defined';
fi



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

# new file cat
function nfo { NF=`nf ${1:-.}`; debug NF $NF;  echo "$NF" | xargs $OPEN  ; }

# new file ls
function nfls { NF=`nf ${1:-.}`; debug NF $NF;  echo "$NF" | xargs ls -A1t  ; }

# new file ls -l
function nflsl { NF=`nf ${1:-.}`; debug NF $NF;  echo "$NF" | xargs
ls -Atl  ; }

#
# Don't exit the shell casually
#
export IGNOREEOF=42

#
# "...footprints on the sands of time..." (I exist[ed]...)
#
touch $HOME/.bashrc-ran
debug ".bashrc done"
