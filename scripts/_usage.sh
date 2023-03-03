################################################################################
# usage - Print P1 in the 'usage' message format.
################################################################################
usage() {
    if [ -z "$1" ]; then
        echo "P1 must be the string to print"
    else
        clr ng "${1}" >&2
    fi
}

################################################################################
# USE OF STDERR.  The output of usage is intended for the user, so it goes to
# stderr.  It must also do this so that the one-line -z test function that is
# used pervasively works as a clean one-liner.
################################################################################

