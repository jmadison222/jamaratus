################################################################################
# line2 - The second-level message within line1.  (clr)
################################################################################
line2() {

    sMessage=$(IFS=$' '; echo "$@") # Turn the input array into a string.

    clr lp "-- $sMessage" 

}

