################################################################################
# dfx - The 'df' wrapper.
################################################################################
dfx() {

sAction=${1:-"show"}
P1=${2:-""}

################################################################################
sUseShow="Show the 'df' output in pretty form."
sUseHelp="Help by showing these instructions.  [default]"

sUsage=$(cat <<EOF
The 'df' wrapper.

Usage: ${FUNCNAME[0]} [action] # Where action is:

    show  $sUseShow
    help  $sUseHelp
 
EOF
)

################################################################################
_show() {

    line1 "$(cd ~; pwd -P) is your home."
    
    python3 ${jamHome}/Linux/dfx/dfx.py | \
        grep -v '/run/user' | \
        GREP_COLOR="1;33" egrep --color=always '.*/tech.*|$' |\
        GREP_COLOR="1;37" egrep --color=always '.*/tmp.*|$' | \
        GREP_COLOR="1;37" egrep --color=always '.*/var.*|$'
    line1

}

################################################################################
case $sAction in

    show) _show ;;
    help) usage "$sUsage" ;;
    *) usage "$sUsage" ;;

esac

}

################################################################################

