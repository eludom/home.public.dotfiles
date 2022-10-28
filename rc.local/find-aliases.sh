function lo {
    # locate org files
    WHAT=${1:-.org};
    debug WHAT $WHAT;
    locate "$WHAT" | grep \.org | grep -v backup
}

function gorg (
    # grep or WHAT in org files in the current directolry younger than AGE
    WHAT=${1:-.org};
    AGE=${2:-7};
    debug WHAT $WHAT;
    debug AGE $AGE;
    find . -name \*.org -mtime -${AGE} -exec grep -i --color -H -e  "${WHAT}" \{\} \;
)
