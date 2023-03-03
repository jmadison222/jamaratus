################################################################################
# announce - Print the file header of the script that calls this function.
################################################################################
announce() {

    [ "$0" == "bash" ] && return $(usage "Use 'announce' within scripts only.")

    sText=`head -3 "$0"`
    clr lb "${sText}"

}

