################################################################################
# prompt - Run some other function in prompt mode.
################################################################################
prompt() {

sDefault="help"
sAction=${1:-"$sDefault"}

if ! command -v rlwrap &>/dev/null; then
    line1
    clr lr "Prompt will not have history due to missing rlwrap command."
fi

################################################################################
sUseExit="The command to get out of the prompt."
sUseStar="The name of the solution to run in prompt mode."

sUsage=$(cat <<EOF
Run some other function in prompt mode.

    exit # The command to get out of the prompt.
    pwd  # A command the solution must have so the prompt works right.

Usage: ${FUNCNAME[0]} <action:$sDefault> # Where action is:

    !     <command>  Run the command on the local file system.
    help  $sAspectHelp
    *     $sUseStar
 
EOF
)

##      https://stackoverflow.com/questions/55965497/handle-eof-in-rlwrap
################################################################################
_star() {

    line1 "$sUseFunc"

    sSolution=$sAction # Lock in the action as calling other solutions changes it.

##      eval "$sSolution help" # Show the help of the solution when the prompt starts.

    sCommand=""
    while [ ! "$sCommand" == "exit" ]
    do

        sPwd=$($sSolution pwd 2>&-) # If the solution has a pwd, use it.
        if [ -z "$sPwd" ]; then sPwd="($sSolution)"; fi # If not, just restate the solution.
        sPwd=$(clr lyi $sPwd 2>&1) # Highlight the pwd of the solution.
        sPwd="$(clr lbi $(pwd) 2>&1) @ $sPwd" # Add the pwd of the Linux level.

        sHistory=~/.promptHistory
        export sPwd

        if ! command -v rlwrap &>/dev/null; then
            read -p "[[ $sPwd ]] " sCommand
        else
            sCommand=$(rlwrap -H $sHistory sh -c 'read -p "[[ $sPwd ]] " REPLY && echo $REPLY'; echo $? > ~/.hold)
        fi

        if [[ "$(cat ~/.hold)" -eq 1 ]]; then sCommand="exit"; fi


        if [ "$sCommand" == "exit" ]; then return; fi # Bail out if the user asked for exit.

        case $sCommand in

            "") ;; # Let enter just restate the prompt.
            !*) eval "${sCommand:1}" 2>&- ;; # Run anything starting with '!' as a system command.
            *) eval "$sSolution $sCommand" ;; # Otherwise, send the command to the solution.

        esac

    done 

    echo "And the command is $sCommand"

}

################################################################################
case $sAction in

    help) usage "$sUsage" ;;
    *) _star ;;

esac

}


################################################################################

