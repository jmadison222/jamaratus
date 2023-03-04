################################################################################
# confirm - Return 0 or 1 based on user confirmation.
################################################################################
confirm() {

sDefault="ask"
sAction=${1:-"$sDefault"}
sConfirmP1=${2:-""}

################################################################################
sUseAsk="Ask the user to confirm."

sUsage=$(cat <<EOF
Return 0 or 1 based on user confirmation.

Use in scripts:

    if confirm; then
        echo "Yes"
    else
        echo "No"
    fi

Usage: ${FUNCNAME[0]} <action:$sDefault> # Where action is:

    ask   $sUseAsk
    help  $sAspectHelp
 
EOF
)

################################################################################
_ask() {

##      local response msg="${1:-Are you sure} (y/[n])? "; shift
    local response msg=$(clr lri "Are you sure (y/[n])? "); shift
    read -r $* -p "$msg" response || echo
    case "$response" in
    [yY][eE][sS]|[yY]) return 0 ;;
    *) return 1 ;;
    esac

}

################################################################################
case $sAction in

    ask) _ask ;;
    help) usage "$sUsage" ;;
    *) usage "$sUsage" ;;

esac

}

################################################################################

