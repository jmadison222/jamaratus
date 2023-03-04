################################################################################
# action - Print a message in the format that tells the user to take an action.
################################################################################
action() {

    sActionP1=${1:-""}

    if [ -z "$sActionP1" ]; then
        usage "Need an action message in P1"
    else
        clr lc "$sActionP1"
    fi

}

