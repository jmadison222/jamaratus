################################################################################
# evalx - The 'eval' wrapper, mostly to echo the command first.  (eval)
################################################################################
evalx() {

sAction=${1:-"help"}

################################################################################
sUseHelp="Help by showing these instructions.  [default]"
sUseStar="Echo the given string and run it as a command."

sUsage=$(cat <<EOF
$sDescription
The 'eval' wrapper, mostly to echo the command first.  (eval)

Special cases:

    evalx "du -hs .git | awk '{print \$1}'" # Escape the dollar sign.

Usage: ${FUNCNAME[0]} [action] # Where action is:

    *     $sUseStar
    help  $sUseHelp
.
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

