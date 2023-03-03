################################################################################
# dir - Directory listing in various forms.
################################################################################
dir() {

sDirDefault=""
sDirAction=${1:-"$sDirDefault"}
sDirP1=${2:-""}

################################################################################
sUseDirSize="List from smallest to largest: -lShr."
sUseDirStar="Show directory listing for <glob>."
sUseDirTime="List from oldest to newest: -ltr."

sDirUsage=$(cat <<EOF
Directory listing in various forms.

Usage: ${FUNCNAME[0]} <action:$sDirDefault> # Where action is:

    help  $sAspectHelp
    size  $sUseDirSize
    time  $sUseDirTime
    *     <glob>  $sUseStar
 
EOF
)

################################################################################
_dir_size() {

    line1 "$sUseDirSize"

    ls --color=auto -lShr 2>&-

}

################################################################################
_dir_star() {

    line1

    ls --group-directories-first --color=auto -dAFl ${@:-*} 2>&-
    nResult=$?

    case $nResult in

        0)
            # Worked fine.  Take no action.
        ;;

        2)
            # Empty directory.  Take no action.
        ;;

        126)
            echo "Directory too big to be fancy.  Just listing..."
            sleep 1
            ls -l
        ;;

        *)
            echo Error $nResult.
        ;;

    esac

    line1
}

################################################################################
_dir_time() {

    line1 "$sUseDirTime"

    ls --color=auto -ltr 2>&-

}

################################################################################
case $sDirAction in

    help) usage "$sDirUsage" ;;
    size) _dir_size ;;
    time) _dir_time ;;
    *) _dir_star "$@" ;;

esac

}


################################################################################

