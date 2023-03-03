################################################################################
# snow - Manage Snowflake, the cloud-based relational database.
################################################################################
snow() {

sAction=${1:-"help"}
sSnowP1=${2:-""}
sSnowP2=${3:-""}

################################################################################
sUseConn="Echo connection for <db> or list 'all' connection strings."
sUseE="Edit the password file that is in the Secure area."
sUseEnv="Show the variables Snowflake understands and their current value."
sUseMy="Run a script in the 'my' directory named <script>."
sUsePing="TODO Ping <db> to keep it alive, or list 'all' databases with ping syntax."
sUseQ="Run the SQL query on the command line using the -q option."
sUseRun="Run in <db> the script <file>.  For local scripts, not my scripts."
sUseSet="Set the <db> to a value for persistent reuse."
sUseTo="Go to <db>.  Use the cache if it has been populated."

sUsage=$(cat <<EOF
Manage Snowflake database interactions.

    IN ANY NEW SERVER, DO 'snow set foobar' TO CACHE THE SERVER NAME.

    Do not put extensive error trapping in this script to manage failure to set
    the cache.

Usage: snow [action] # Where action is:

    [all]     The 'all' value is reserved and can never be a 'db' value.
    <db>      Use 'conn all' for the list of 'db' values that have connections.
    <file>    Must have the full file name.  It will not assume '.sql'.
    <query>   A query string on the command line.
    <script>  The name of a query script in 'queries' without the '.sql'.

Actions:

    conn  <db:all>.  $sUseConn
    doc   $sAspectDoc
    e     $sUseE
    env   $sUseEnv
    help  $sAspectHelp
    my    <script>  $sUseMy
    ping  <db:all>.  $sUsePing
    q     <query>.  $sUseQ
    run   <db> <file>.  $sUseRun
    set   <db>.  $sUseSet
    to    <db>.  $sUseTo
 
EOF
)

################################################################################
declare -A aAccount
declare -A aUser
declare -A aPassword
declare -A aRole
declare -A aDatabase
declare -A aWarehouse
declare -A aSchema
        
__setup() {

    if [[ ! -f ${jamHome}/Linux/snow/cache.db.gen ]]; then
        printf "east" > ${jamHome}/Linux/snow/cache.db.gen
    fi
    
    if [[ ! -f ${jamHome}/Secure/pw.snowflake ]]; then
        usage "$sUsage"
        line1
        action "Create ${jamHome}/Secure/pw.snowflake file first."
        line1
        sAction="abort"
    else
    
        # tb_linux_bash_array: Read CSV into bash array and loop through it.
    
        while IFS=, read -r alias account username password role database warehouse schema; do
            if [[ $alias =~ ^#.* ]]; then
                :
            else
                aAccount[$alias]=$account
                aUser[$alias]=$username
                aPassword[$alias]=$password
                aRole[$alias]=$role
                aDatabase[$alias]=$database
                aWarehouse[$alias]=$warehouse
                aSchema[$alias]=$schema
            fi
        done < ${jamHome}/Secure/pw.snowflake
    
    fi

}

__setup

################################################################################
_conn() {

    [ -z "$sSnowP1" ] && sSnowP1='all'

    case $sSnowP1 in
    all)
        for sSnowP1 in "${!aAccount[@]}"; do
            echo "alias=$sSnowP1 account=${aAccount[$sSnowP1]} username=${aUser[$sSnowP1]} password=${aPassword[$sSnowP1]} role=${aRole[$sSnowP1]} database=${aDatabase[$sSnowP1]} warehouse=${aWarehouse[$sSnowP1]} schema=${aSchema[$sSnowP1]}"
        done
    ;;
    *)
        echo "alias=$sSnowP1 account=${aAccount[$sSnowP1]} username=${aUser[$sSnowP1]} password=${aPassword[$sSnowP1]} role=${aRole[$sSnowP1]} database=${aDatabase[$sSnowP1]} warehouse=${aWarehouse[$sSnowP1]} schema=${aSchema[$sSnowP1]}"
    ;;
    esac
}


################################################################################
_e() {

    e ${jamHome}/Secure/pw.snowflake

}

################################################################################
# Internal silent child of its parent function.
################################################################################
__env() {

    env | grep SNOWSQL | sort | grep SNOWSQL

}

################################################################################
_env() {

    line1 "$sUseEnv"

    snowsql --help | grep -o 'SNOWSQL_[_A-Z]*' | sort | grep SNOWSQL
    echo 

    __env

    line1

}

################################################################################
_my() {

    line1 "$sUseMy"

    if [ -z "$sSnowP1" ]; then
        cd ${jamHome}/Linux/snow/my >/dev/null 2>&-
        dir *.sql
        cd - >/dev/null 2>&-
    else
        snowsql -o friendly=false -f ${jamHome}/Linux/snow/my/${sSnowP1}.sql -D jamSnowStage=${jamSnowStage}
    fi

}

################################################################################
# Internal silent child of its parent function.
################################################################################
# This doesn't actually work: PRIVATE_KEY_PATH=~/.ssh/rsa_snowflake.p8
################################################################################
__set() {


    export SNOWSQL_ACCOUNT=${aAccount[$1]}
    export SNOWSQL_DATABASE=${aDatabase[$1]}
    export SNOWSQL_PWD=${aPassword[$1]} # Either/or with private key.
    export SNOWSQL_ROLE=${aRole[$1]}
    export SNOWSQL_SCHEMA=${aSchema[$1]}
    export SNOWSQL_USER=${aUser[$1]}
    export SNOWSQL_WAREHOUSE=${aWarehouse[$1]}

}

################################################################################
_set() {

    line1 "$sUseSet"

    if [ -z "$sSnowP1" ]; then
        if [ -f ${jamHome}/Linux/snow/cache.db.gen ]; then
            sDb=$(cat ${jamHome}/Linux/snow/cache.db.gen)
            echo "Using snowflake database: [$sDb]"
            __set $sDb
            __env
        else
            usage "Need an alias from this list:"
            cat ${jamHome}/Secure/pw.snowflake
        fi
    else
        echo "Setting snowflake database to: [$sSnowP1]"
        printf "$sSnowP1" > ${jamHome}/Linux/snow/cache.db.gen
        __set $sSnowP1
        __env
    fi


}

################################################################################
_q() {

    line1 "$sUseQ"

    [ -z "$sSnowP1" ] && return $(usage "Run what?  Need <query> on the command line.")

    evalx "snowsql -o friendly=false -q '$sSnowP1'"

}

################################################################################
_run() {

    [ -z "$sSnowP1" ] && return $(usage "Need a filename in sSnowP1 that contains the SQL to run.")

    evalx "snowsql -o friendly=false -f '$sSnowP1'"

}

################################################################################
_to() {

    line1 "$sUseTo"

    if [[ -z "${sSnowP1}" ]]; then
        sSnowP1=$(cat ${jamHome}/Linux/snow/cache.db.gen) # Default to cached value.
    fi

    if [[ -z "${aAccount[$sSnowP1]}" ]]; then
        usage "Pick a valid connection from the list."
        return
    else
        printf "$sSnowP1" > ${jamHome}/Linux/snow/cache.db.gen # Cache for reuse.
        __set ${sSnowP1} # Set the environmental variables.
    fi

    snowsql

}

################################################################################
__set $(cat ${jamHome}/Linux/snow/cache.db.gen)

case $sAction in

    abort) false ;;
    conn) _conn ;;
    doc) shift; aspect doc snow "$@" ;;
    e) _e ;;
    env) _env ;;
    my) _my ;;
    ping) _ping ;;
    q) _q ;;
    run) _run ;;
    set) _set ;;
    to) _to ;;
    *) usage "$sUsage" ;;

esac

##  if [ ! -f ${jamHome}/Secure/pw.snowflake ]; then
##      line1
##      action "The ${jamHome}/Secure/pw.snowflake not present.  Create it first."
##      line1
##  fi
##  
##  if [ ! -f ${jamHome}/Linux/snow/cache.db.gen ]; then
##      line1
##      action "The ${jamHome}/Linux/snow/cache.db.gen not present.  Run 'set' first."
##      line1
##  fi

}

