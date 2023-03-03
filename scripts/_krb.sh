################################################################################
# krb - Manage Kerberos.  (kinit, klist, kdestroy)
################################################################################
krb() {

sKrbDefault="init"
sKrbAction=${1:-"$sKrbDefault"}
sKrbP1=${2:-""}

klist -s # Just to get the return code.
nReturn=$? # Hold the return code so many functions can use it below.

################################################################################
sKrbUseHelp="Help by showing this message."
sKrbUseInit="Verify ticket, or initialize if none."
sKrbUseKeytab="Generate a keytab file for authentication without password."
sKrbUseMm="Get red/green status suitable for the 'mm' command."
sUseSso="Sign on to \$jamKerberosUser using the \$USER.keytab file."
sKrbUseValid="State 'Yes' or 'No' message, return non-zero if 'No'.  [default]"
sKrbUseWarn="State 'No' message, silent otherwise, return non-zero if 'No'."

sKrbUsage=$(cat <<EOF
My kerberos wrapper.

Exit a function gracefully with this function:

    krb valid; [ \$? -ne 0 ] && exit $? # Logic: Yes/0/F/{flow}, No/1/T/{exit}.

Usage: ${FUNCNAME[0]} <action:$sKrbDefault> # Where action is:

Actions:

    help    $sKrbUseHelp
    init    $sKrbUseInit
    keytab  $sKrbUseKeytab
    mm      $sKrbUseMm
    sso     $sUseSso
    valid   $sKrbUseValid
    warn    $sKrbUseWarn
.
EOF
)

################################################################################
_init() {

    line1 "$sKrbUseInit"

    if [[ "$nReturn" -eq 0 ]]; then
        echo "Yes, you have a valid ticket."
    else
        if [[ -z "$jamKerberosUser" ]]; then
            evalx "kinit" # Take our chances with the default.
        else
            evalx "kinit $jamKerberosUser"
        fi
        mm
    fi

}

################################################################################
_keytab() {

    line1 "$sKrbUseKeytab"

    pushdx ${jamHome}/Linux/krb

        line2
        line2 "Generate the keytab file:"
        line2
        usage "Do these commands in ktutil:"
        action "addent -password -p $jamKerberosUser -e aes256-cts -k 1"
        action "wkt ${jamHome}/Linux/krb/$USER.keytab"
        action "quit"

        ktutil

        line2
        line2 "See that the file exists:"
        line2
        ls -lrt | grep keytab

        line2
        line2 "Use it to get a ticket:"
        line2
        evalx "kinit -kt /export/home/${USER}/Linux/krb/${USER}.keytab $jamKerberosUser"
        krb valid

    popdx

}

################################################################################
_mm() {

    if [[ "$nReturn" -eq 0 ]]; then
        clr lgi "krb"
    else
        clr lri "krb"
    fi

}

################################################################################
_sso() {

    krb warn; [ $? -eq 0 ] && return $? # If we have a key, exit.

    # If the keytab file exists.
    # If the kerberos user is defined.
    # Then:
    evalx "kinit -k -t ${jamHome}/Linux/krb/jm43436e.keytab $jamKerberosUser"

}

################################################################################
_valid() {

    if [[ "$nReturn" -eq 0 ]]; then
        echo "Yes, you have a valid ticket."
    else
        echo "No, you do not have a valid ticket.  Do 'kinit'."
    fi

    return $nReturn

}

################################################################################
_warn() {

    if [[ "$nReturn" -ne 0 ]]; then
        echo "No, you do not have a valid ticket.  Do 'kinit'."
    fi

    return $nReturn

}

################################################################################
case $sKrbAction in

    help) usage "$sKrbUsage" ;;
    init) _init ;;
    keytab) _keytab ;;
    mm) _mm ;;
    sso) _sso ;;
    valid) _valid ;;
    warn) _warn ;;
    *) usage "$sKrbUsage" ;;

esac

}

