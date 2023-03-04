################################################################################
# clr - Manage screen colors.  (printf)
################################################################################
# Color reference: https://misc.flogisoft.com/bash/tip_colors_and_formatting
################################################################################
clr() {

sClrAction=${1:-"list"}
sClrP1=${2:-""}
sClrP2=${3:-""}

      clrBlack='\e[0;30m' # nx
 clrLightBlack='\e[1;30m' # lx
        clrRed='\e[0;31m' # nr
   clrLightRed='\e[1;31m' # lr
      clrGreen='\e[0;32m' # ng
 clrLightGreen='\e[1;32m' # lg
     clrYellow='\e[0;33m' # ny
clrLightYellow='\e[1;33m' # ly
       clrBlue='\e[0;34m' # nb
  clrLightBlue='\e[1;34m' # lb
     clrPurple='\e[0;35m' # np
clrLightPurple='\e[1;35m' # lp
       clrCyan='\e[0;36m' # nc
  clrLightCyan='\e[1;36m' # lc
      clrWhite='\e[0;37m' # nw
 clrLightWhite='\e[1;37m' # lw
       clrNone='\e[0m'    # No color.  Back to default.

################################################################################
sClrUseHelp="Help by showing these instructions."
sClrUseList="List all colors.  Use this to understand the codes."
sClrUseLs="List the colors used by the 'ls' command."
sClrUseDefault="Print using the two or three character code."

sClrUsage=$(cat <<EOF
Manage screen colors.  (printf)

    Color site: https://misc.flogisoft.com/bash/tip_colors_and_formatting
    See also: The 'clrls' command.

Usage: clr [action] # Where action is:

Usage: ${FUNCNAME[0]} <action:$sClrAction> # Where action is:

    help  $sClrUseHelp
    list  $sClrUseList
    ls    $sClrUseLs
    *     $sClrUseDefault
.
EOF
)

################################################################################
bInline=false

################################################################################
_clr_default_do_one() {

    sColorEscape=${1}
    shift
    sColorMessage="$@"

    if [ "$bInline" == true ]; then
        printf "${sColorEscape}${sColorMessage}${clrNone}" >&2
    else
        printf "${sColorEscape}${sColorMessage}${clrNone}\n" >&2
    fi
}

################################################################################
_clr_default() {

    sCode=$1    
    sColor=${sCode:0:2}
    sInline=${sCode:2:1}

    if [[ "${sInline:-""}" == "i" ]]; then
        bInline=true
    fi

    case $sColor in

        nx) shift; _clr_default_do_one "${clrBlack}"       "$@" ;;
        lx) shift; _clr_default_do_one "${clrLightBlack}"  "$@" ;;
        nr) shift; _clr_default_do_one "${clrRed}"         "$@" ;;
        lr) shift; _clr_default_do_one "${clrLightRed}"    "$@" ;;
        ny) shift; _clr_default_do_one "${clrYellow}"      "$@" ;;
        ly) shift; _clr_default_do_one "${clrLightYellow}" "$@" ;;
        ng) shift; _clr_default_do_one "${clrGreen}"       "$@" ;;
        lg) shift; _clr_default_do_one "${clrLightGreen}"  "$@" ;;
        nb) shift; _clr_default_do_one "${clrBlue}"        "$@" ;;
        lb) shift; _clr_default_do_one "${clrLightBlue}"   "$@" ;;
        np) shift; _clr_default_do_one "${clrPurple}"      "$@" ;;
        lp) shift; _clr_default_do_one "${clrLightPurple}" "$@" ;;
        nc) shift; _clr_default_do_one "${clrCyan}"        "$@" ;;
        lc) shift; _clr_default_do_one "${clrLightCyan}"   "$@" ;;
        nw) shift; _clr_default_do_one "${clrWhite}"       "$@" ;;
        lw) shift; _clr_default_do_one "${clrLightWhite}"  "$@" ;;

        *) echo "Invalid code.  Do 'clr list' for proper codes." ;;

    esac

}

################################################################################
_clr_list() {

    line1

    usage "Use 'n' for normal, 'l' for light' and 'x' for black."

    _clr_default nx "nx = clrBlack         0;30"
    _clr_default lx "lx = clrLightBlack    1;31"

    _clr_default nr "nr = clrRed           0;31"
    _clr_default lr "lr = clrLightRed      1;31   # Danger: confirm, ps1."

    _clr_default ny "ny = clrYellow        0;33"
    _clr_default ly "ly = clrLightYellow   1;33   # Primary visual: dfx, ps1."

    _clr_default ng "ng = clrGreen         0;32   # How to: usage."
    _clr_default lg "lg = clrLightGreen    1;32"

    _clr_default nb "nb = clrBlue          0;34"
    _clr_default lb "lb = clrLightBlue     1;34   # Secondary information: announce, ps1."

    _clr_default np "np = clrPurple        0;35"
    _clr_default lp "lp = clrLightPurple   1;35   # Primary information: line1, line2."

    _clr_default nc "nc = clrCyan          0;36   # Secondary actions: evalx."
    _clr_default lc "lc = clrLightCyan     1;36   # Primary actions: action, ps1"

    _clr_default nw "nw = clrWhite         0;37"
    _clr_default lw "lw = clrLightWhite    1;37   # Secondary visual: dfx, ps1."

    line1

    usage "Add 'i' to a code for in-line printing."
    echo ""

    _clr_default nxi "nxi "
    _clr_default lxi "lxi "

    _clr_default nri "nri "
    _clr_default lri "lri "

    _clr_default nyi "nyi "
    _clr_default lyi "lyi "

    _clr_default ngi "ngi "
    _clr_default lgi "lgi "

    _clr_default nbi "nbi "
    _clr_default lbi "lbi "

    _clr_default npi "npi "
    _clr_default lpi "lpi "

    _clr_default nci "nci "
    _clr_default lci "lci "

    _clr_default nwi "nwi "
    _clr_default lwi "lwi "

    echo

    line1

    printf "${clrNone}clrNone\n"
}

################################################################################
_clr_ls() {

    line1 $sClrUseLs

    echo "Move the functionality of clrls to here."

}

################################################################################
case $sClrAction in

    help) usage "$sClrUsage" ;;
    list) _clr_list ;;
    ls) _clr_ls ;;
    *) shift; _clr_default $sClrAction "$@" ;;

esac

}


