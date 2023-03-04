################################################################################
# cache - Manage cache files across other components.
################################################################################
cache() {

sCacheDefault="help"
sCacheAction=${1:-"$sCacheDefault"}
sCacheP1=${2:-""}
sCacheP2=${3:-""}
sCacheP3=${4:-""}

################################################################################
sCacheUseDefault="Set the cache but don't overwrite it."
sCacheUseFlush="Delete all cache files."
sCacheUseGet="Get the <value> stored in <item> for the <sol>ution."
sCacheUsePut="Put the <value> as the <item> for the <sol>ution."
sCacheUseSet="Put the <value> as the <item> for the <sol>ution."
sCacheUseShow="Show cache files and contents filtered on [sol]."

sCacheUsage=$(cat <<EOF
Manage cache files across other components.

    Put creates the cache file needed, including if you make a mistake.
    To undo a mistake with set, delete the cache file manually.
    The [value] can be blank as a legitimate value to store.

Usage: ${FUNCNAME[0]} <action:$sCacheDefault> # Where action is:

    default  <sol> <item> [value]  $sCacheUseDefault
    flush    $sCacheUseFlush
    help     $sAspectHelp
    get      <sol> <item>  $sCacheUseGet
    set      <sol> <item> [value]  $sCacheUsePut 
    show     [sol] $sCacheUseShow
 
EOF
)

################################################################################
_default() {

    if [[ ! -f ~/.cache.$sCacheP1.$sCacheP2.gen.txt ]]
    then
        _set
    fi

}

################################################################################
_flush() {

    line1 "$sCacheUseFlush"

    action "This will delete all cache files."
    if confirm
    then
        rm -f ~/.cache.*.*.gen.txt
    fi

}

################################################################################
_get() {

    [ -z "$sCacheP1" ] && return $(usage "Need a solution name.")
    [ -z "$sCacheP2" ] && return $(usage "Need an item name.")

    if [[ ! -f ~/.cache.$sCacheP1.$sCacheP2.gen.txt ]]
    then
        >&2 echo "Cache not found for $sCacheP1 $sCacheP2."
        return 1
    else
        cat ~/.cache.$sCacheP1.$sCacheP2.gen.txt
    fi

}

################################################################################
_set() {

    [ -z "$sCacheP1" ] && return $(usage "Need a solution name.")
    [ -z "$sCacheP2" ] && return $(usage "Need an item name.")

    echo "$sCacheP3" > ~/.cache.$sCacheP1.$sCacheP2.gen.txt

}

################################################################################
_show() {

    line1 "$sCacheUseShow"

    if [[ -z "$sCacheP1" ]]; then
        tail -n +1 ~/.cache.*.*.gen.txt
    else
        tail -n +1 ~/.cache.$sCacheP1.*.gen.txt
    fi


}

################################################################################
case $sCacheAction in

    default) _default ;;
    flush) _flush ;;
    help) usage "$sCacheUsage" ;;
    get) _get ;;
    set) _set ;;
    show) _show ;;
    *) usage "$sCacheUsage" ;;

esac

}

################################################################################

