################################################################################
# s3 - Manage S3 on AWS.
################################################################################
s3() {

sDefault="help"
sAction=${1:-"$sDefault"}
P1=${2:-""}
P2=${3:-""}

################################################################################
sUseAutodir="Toggle whether to show directory contents when doing 'cd'."
sUseCache="Show the cached values that drive the behavior of commands."
sUseCat="Show the contents of the <file>."
sUseCd="Change directory.  A logical notion made physical by other commands."
sUseGet="Use 'cp' to get <glob> to current local directory."
sUseHead="Show lines from the top of the file.  Count has hypen as usual."
sUseHelp="Help by showing these instructions.  [default]"
sUseTo="Go to directory for <label> or [set] the label to pwd."
sUseDir="List files in current directory.  Use 'cd' to move around."
sUseLsr="List files recursively under current S3 directory."
sUsePut="Put <glob> from local directory to S3."
sUsePwd="Show the current directory.  Same as 'cd .' but more intuitive."
sUseRm="Remove files matching <glob>.  Use \"s3 rm dir/*\" for a directory."
sUseServer="Use <server> as s3://<server>/ in all needed contexts."

sUsage=$(cat <<EOF
Manage S3 on AWS.

    QUOTE THE GLOBS!  Do 'foo*.txt' to get the glob to S3 not foo*.txt.  This
    is critical for the 'put' and 'rm' command on directories.

    Most commands use the current directory for their work.  Act accordingly.

    Use of this solution as a prompt in multiple sessions will cause them
    to interfere with each other due to the shared cache.  This may be fine
    for your work, but if you get odd multi-session behavior, that may be
    why.

Usage: ${FUNCNAME[0]} <action:$sDefault> # Where action is:

    autodir  $sUseAutodir
    cache    $sUseCache
    cat      <file>  $sUseCat
    cd       $sUseCd
    dir      $sUseDir
    doc      $sAspectDoc
    get      <glob>  $sUseGet
    help     $sUseHelp
    head     [count:-10]  $sUseHead
    lsr      $sUseLsr
    put      <glob> $sUsePut
    pwd      $sUsePwd
    rm       <glob>  $sUseRm
    server   <server>  $sUseServer
    to       <label> [set]  $sUseTo
 
EOF
)

################################################################################
cache default s3 autodir "on"
cache default s3 cd ""
cache default s3 server "undefined"

sAutodir=$(cache get s3 autodir) # See note at bottom for head/tail caching.
sCd=$(cache get s3 cd)
sServer=$(cache get s3 server)

################################################################################
_autodir() {

    case "$sAutodir" in
        on) 
            sAutodir=off
            echo "Autodir off" 
        ;;
        off) 
            sAutodir=on
            echo "Autodir on"
        ;;
        *) 
            echo "System error with $sCurrent in _autodir function in s3 solution."
        ;;
    esac

}

################################################################################
_cache() {

    cache show s3 # This mid-script cache interaction is fine as it's a read.

}

################################################################################
_cd() {

    case $P1 in
        "") 
            :
        ;;
        /)
            sCd=""
        ;;
        '.') 
            :
        ;;
        '..') 
            sCd=${sCd%/*}
        ;;
        *) 
            sCd=$sCd/$P1
        ;;
    esac

    if [[ "$sAutodir" == "on" ]]; then
        _dir
    fi

}

################################################################################
_cat() {

    [ -z "$P1" ] && return $(usage "Need a file to show.")

    evalx "aws s3 cp s3://${sServer}${sCd}/${P1} -"

}

################################################################################
_dir() {

    evalx "aws s3 ls s3://${sServer}${sCd}/ | grep -v '_\\\$folder\\\$'"

}

################################################################################
_get() {

    line1 "$sUseGet"

    [ -z "$P1" ] && return $(usage "Need a source glob.")

    evalx "aws s3 cp s3://${sServer}${sCd}/ . --recursive --exclude \"*\" --include \"${P1}\""

}

################################################################################
_head() {

    [ -z "$P1" ] && return $(usage "Need a file to show.")

    evalx "aws s3 cp s3://${sServer}${sCd}/${P1} - 2>&- | head $P2"

}

################################################################################
_lsr() {

    evalx "aws s3 ls s3://${sServer}${sCd}/$P1 --recursive"

}

################################################################################
_put() {

    [ -z "$P1" ] && return $(usage "Need a source glob.")

    evalx "aws s3 cp . s3://${sServer}${sCd}/ --recursive --exclude \"*\" --include \"$P1\" 2>&1 | grep -v \"Skipping file\""
    _dir # Regardless of autodir.

}

################################################################################
_pwd() {

    echo "s3://${sServer}${sCd}"

}

################################################################################
_rm() {

    [ -z "$P1" ] && return $(usage "Need a source glob.")

    action "THIS DATA WILL BE LOST: s3://${sServer}${sCd}/${P1}."
    confirm
    evalx "aws s3 rm s3://${sServer}${sCd}/ --recursive --exclude \"*\" --include \"$P1\""
    _dir # Regardless of autodir.

}

################################################################################
_server() {

    if [[ -z "$P1" ]]; then
        echo "$sServer"
    else
        sServer=$P1
    fi 

}

################################################################################
# This is the big exception to head/tail caching due to the arbitrary nature
# of marker names.
################################################################################
_to() {


    #
    # If the user said only 'to', show the cache state.
    #
    if [[ -z "$P1" ]]; then
        cache show s3.to 2>&-
        if [[ "$?" -ne 0 ]]; then
            echo "No cache values set"
        fi
    fi

    sLabel=$P1
    sSet=$P2

    case "$sSet" in

        #
        # Go to the location the user provided.  Not setting a marker.
        #
        "")
            cache get s3 to.$sLabel 2>&-
            nReturn=$?
            if [[ "nReturn" -eq 1 ]]; then
                usage "Pick a location from above, or set a new one."
            else
                sCd=$(cache get s3 to.$sLabel)
                if [[ "$sAutodir" == "on" ]]; then
                    _dir
                fi
            fi
        ;;

        #
        # Set the marker.
        #
        set)
            cache set s3 to.$sLabel "${sCd}"
            echo "The label [$sLabel] now points to $(cache get s3 to.$sLabel)."
        ;;

        *)
            usage "Need 'set' or nothing after the location name."
        ;;

    esac

}

################################################################################
case $sAction in

    autodir) _autodir ;;
    cd) _cd ;;
    cache) _cache ;;
    cat) _cat ;;
    dir) _dir ;;
    doc) shift; aspect doc s3 "$@" ;;
    get) _get ;;
    head) _head ;;
    help) usage "$sUsage" ;;
    ls) _dir ;; # Convenience.
    lsr) _lsr ;;
    put) _put ;;
    pwd) _pwd ;;
    rm) _rm ;;
    server) _server ;;
    to) _to ;;
    *) usage "$sUsage" ;;

esac

cache set s3 cd $sCd 
cache set s3 autodir $sAutodir
cache set s3 server $sServer

}

################################################################################
# USE HEAD/TAIL CACHE SETTING.  The body of this code should interact little 
# or not at all with the cache.  Instead, get the cache values into variables
# at the start of the script, then set the cache with the variables at the 
# end.  The exception to this must be the 'to' function since the user can
# set arbitrary location names.
################################################################################

