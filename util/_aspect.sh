################################################################################
# aspect - Manage the aspects that are common to functions.
################################################################################

################################################################################
# The messages are global because they are used by many functions.
################################################################################
sAspectBuild="Build the solution."
sAspectCmd="[e]  Show doc.cmd.txt or edit if [e] is given."
sAspectDesign="[e]  Show doc.design.txt or edit if [e] is given."
sAspectDoc="[subject] [e]  List doc files, and see or edit [subject]."
sAspectE="Edit the dominate list of this solution."
sAspectHelp="Help by showing these instructions."
sAspectTest="Test the system."
################################################################################
aspect() {

sAction=${1:-"help"}
sAspectP1=${2:-""}
sAspectP2=${3:-""}
sAspectP3=${4:-""}

################################################################################
# The action comes before the solution to be consistent with the standard 
# function pattern, even though having the solution before the action might
# make more sense in this particular situation.
################################################################################

sUsage=$(cat <<EOF
Manage the aspects that are common to functions.

    Put this in the main 'case' of the function:

        doc) shift; aspect doc <sol> "\$@" ;;

Usage: ${FUNCNAME[0]} <action:$sAction> <solution> # Where action is:

    doc   <sol>  $sAspectDoc
    help  $sAspectHelp
 
EOF
)

################################################################################
_doc() {

    sSolution="$sAspectP1"
    sSubject="$sAspectP2"
    sEdit="$sAspectP3"

    [ -z "$sSolution" ] && return $(usage "Need a solution for this aspect.")

    pushdx ${jamHome}/Linux/${sSolution}

        if [ -z "$sSubject" ]; then
            doc list
        else
            if [ -z "$sEdit" ]; then
                doc cat ${sSubject}
            else
                doc e ${sSubject}
            fi
        fi

    popdx

}

################################################################################
case $sAction in

    doc) _doc ;;
    help) usage "$sUsage" ;;
    *) usage "$sUsage" ;;

esac

}

################################################################################

