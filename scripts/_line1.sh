################################################################################
# line1 - The first-level visual break.  (tput cols, perl, clr)
################################################################################
line1() {

    sMessage=$(IFS=$' '; echo "$@") # Turn the input array into a string.
    nWidth=`tput -T xterm cols`
    sLine=`perl -e "print '-' x $nWidth;"`

    clr lp "$sLine" # We always print one line.
    if [ -n "${sMessage}" ]; then # If there is some kind of message.
        line2 "$@" # Print the message in the second line.
        line2 "" # Print another line after the message for balance.
    fi

}

################################################################################
# Added -T on tput to make it work in Docker when root switches user
# non-interactively.
################################################################################

