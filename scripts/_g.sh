################################################################################
# g - The 'git' wrapper.
################################################################################
################################################################################
# Branching article: https://thenewstack.io/dont-mess-with-the-master-working-with-branches-in-git-and-github/
################################################################################
g() {

sDefault="help"
sAction=${1:-"$sDefault"}
P1=${2:-""}

################################################################################
sUseDiff="Find any >>>> or <<<< differences resulting from a merge."
sUseLog="Show git log --pretty=oneline."
sUseOrigin="Check the origin from which the local repository was cloned."
sUseSize="Show the size of .git folder."
sUsePat="Show the personal access token.  (eze)#123##"
sUseS="Status of modifications."
sUseUndo="Undo changes and get back to original checkout."
sUseWiki="Manage the information in GitHub wikis."
sUseX="Execute all common operations, with optional [message]."

sUsage=$(cat <<EOF
The 'git' wrapper.

    The hash of a commit is the first 7 characters of the full identifier.

Usage: ${FUNCNAME[0]} <action:$sDefault> # Where action is:

Actions:

    a       git add P1.   Add P1 to local.
    ba      git branch -a.  Show all branch information.
    big     <n:20>  List the largest files so we can find and eliminate bloat.
    c       git commit -m [P1]; git push.   Commit to local and push to origin.
    co      git checkout P1.  Switch to branch P1
    diff    $sUseDiff
    doc     $sAspectDoc
    r       Remove file from directory and local.
    help    $sAspectHelp
    log     $sUseLog
    origin  $sUseOrigin
    pat     $sUsePat
    s       $sUseS
    rso     git remote show origin.  Show details of the origin.
    size    $sUseSize
    undo    $sUseUndo
    wiki    <item>  $sUseWiki
            images  List all the images with permalinks.
    x       [message]  $sUseX
 
EOF
)

################################################################################
__msg() {

    echo "On `date`, James Madison had: `git diff --stat | tail -n1`."

}

################################################################################
_big() {

    [ -z "$P1" ] && P1='20'
    clr ly "$P1"

    git rev-list --objects --all \
    | git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' \
    | sed -n 's/^blob //p' \
    | sort --numeric-sort --key=2 \
    | tail -n $P1 \

}

################################################################################
_commit() {
    line1 "git commit -m; git push -u origin"
    [ -z "$P1" ] && P1="__msg"
    git commit -m "$P1"
    git pull
    git push -u origin 
}

################################################################################
_diff() {

    line1 "$sUseDiff"

    pushdx ${jamHome}/Linux
    grepx find ">>>>|<<<<"
    popdx

}

################################################################################
_log() {

    line1 "$sUseLog"

    git log --pretty=oneline

}

################################################################################
_origin() {

    line1 "$sUseOrigin"
    evalx 'git config --get remote.origin.url'

}

################################################################################
# CREATION PROCESS.  Has two heavy manual steps, so we keep it all manual.
#
#     # Kill any 'gpg-agent' processes to flush the cache.
#     e pat # Put the original personal access token here.
#     gpg -c pat # Encryption the personal access token.
#     # Use the password per the rules in doc.general.txt.
#     base64 pat.gpg > pat.txt # Light armor.
#     g pat # Make sure it worked before deleting other files.
#     rm pat # Don't keep the original for obvious security reasons.
#     rm pat.gpg # No need to keep the intermediate encryption.
#
################################################################################
_pat() {

    export GPG_TTY=$(tty) # Prompt for password in batch.
    usage "(eze)#123## - For the personal access token from Linux."
    usage "(pwd)#G#834 - For interactive access from the browser."
    base64 -d ${jamHome}/Linux/git/pat.txt | gpg -d 2>/dev/null | head -1

}

################################################################################
_size() {

    line1 "$sUseSize"

    if [[ ! -e .git ]]
    then
        usage "Go to a place with a .git directory."
    else
        evalx "du -hs .git | awk '{print \$1}'"
    fi

}

################################################################################
_status() {

    evalx "git status -u"

}

################################################################################
_undo() {

    line1 "$sUseUndo"

    evalx "git status -u"
    echo "This is destructive, so not automated, but you likely want:"
    action "git stash"
    action "get stash show"
    action "git stash drop"

}

################################################################################
_wiki() {

    [ -z "$P1" ] && return $(usage "Need P1.")

    line1 "$sUseWiki"

    case $P1 in

    images)
        egrep -r --color 'image:.*blob/[^/]{20,99}/'
    ;;

    *) usage "$sUsage" ;;

    esac

}

################################################################################
_x() {

    clear 

    line1 "$sUseX"

#   https://stackoverflow.com/questions/18529206/when-do-i-need-to-do-git-pull-before-or-after-git-add-git-commit
#   Consider adding these to the sequence:
#   git stash
#   git pull 
#   git stash apply

    evalx "git status -su"

    if confirm; then

        if [ -z "$P1" ] 
        then 
            sMsg="`__msg`"
        else
            sMsg="$P1"
        fi
        sBranch=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')
        evalx "g pat"
        evalx "git add -A"
        evalx "git commit -m \"$sMsg\""
        #
        # Move to this:
        # git pull https://jmadison222:`g pat`@github.com/jmadison222/Linux04.git 2>&-
        # sOrigin=`g origin 2>&- | cut -c9-1000`
        #
        evalx "git pull"
        #
        evalx "git merge origin/$sBranch --no-edit -m \"$sMsg  (Merge)\"" # In case we're on a branch.
        evalx "git push -u origin"
        evalx "git status -u"

        line2 "Deploying 'f' to 'bin'."
        pushdx ${jamHome}/Linux/f
            go build 2>&- # Functions are so often changed that we just do this.
        popdx

    fi

}

################################################################################
case $sAction in

    a) # Add
        line1 "git add"
        [ -z "$P1" ] && (echo "Need P1 of files to add."; return)
        git add -A $P1
    ;;

    ba) # Branch All
        line1 "git branch -a"
        git branch -a
    ;;

    big) _big ;;

    c) _commit ;;

    co)
        line1 "git checkout {branch}"
        git checkout $P1	    
    ;;

    doc) shift; aspect doc git $@ ;;

    diff) _diff ;;
    help) usage "$sUsage" ;;
    log) _log ;;
    origin) _origin ;;
    pat) _pat ;;

    r)
        line1 "git rm"
        git rm $P1
    ;;

    rso)
        line1 "git remote show origin"
        evalx "git remote show origin"
    ;;

    s) _status ;;
    size) _size ;;
    undo) _undo ;;
    wiki) _wiki ;;
    x) _x ;;
    *) usage "$sUsage" ;;
    
esac

}

