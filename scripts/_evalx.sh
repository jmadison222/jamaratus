################################################################################
# evalx - The 'eval' wrapper, mostly to echo the command first.
################################################################################
evalx() {

sAction=${1:-"help"}

################################################################################
sUseStar="Echo the given string and run it as a command."

sUsage=$(cat <<EOF
$sDescription
The 'eval' wrapper, mostly to echo the command first.

    Shell scripts often do lots of commands.  But when you do them inside 
    such scripts, you can lose visibility into what is happening.  You can 
    try "set -x", but this very commonly provides far too much information.
    Instead, use the "evalx" function.  This will echo the command being
    used to the screen in a special color, then execute the command.  This
    gives you just the right level of insight into what commands are being
    executed in a script.

    You must quote the command string.  Using full quotes so that variables
    are expanded is likely your most common choice.

Special cases:

    evalx "du -hs .git | awk '{print \$1}'" # Escape the dollar sign.

Usage: ${FUNCNAME[0]} [action] # Where action is:

    *     $sUseStar
    help  $sAspectHelp
 
EOF
)

################################################################################
_star() {

    clr nc "$@"
    eval "$@"

}

################################################################################
case $sAction in

    help) usage "$sUsage" ;;
    *) _star "$@" ;;

esac

}

################################################################################

