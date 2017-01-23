#!/usr/bin/env bash
# NetCatScanAndReport - simple script accepts a remote host and a series of ports or port ranges
# NetCatScanAndReport --remote [remote-Host] --ports [port(s)]
#
# Created December 19, 2016 by Kevin Nefeuld
#
# Resources Used:
#   NetCat  ->  http://www.tutorialspoint.com/unix_commands/nc.htm
#   Bash    ->  http://mywiki.wooledge.org/BashGuide
#   regex   ->  http://wiki.bash-hackers.org/syntax/ccmd/conditional_expression
#               https://www.gnu.org/software/bash/manual/html_node/Conditional-Constructs.html
#
# Reset all variables that might be set
remote=
ports=

# Basic functions --------------------------------------------------------------
function show_help {
    local usage="$(basename "$BASH_SOURCE")  [-h] [-r remote] [-p port numbers | range] -- simple script that scans and reports
ports and/or port ranges for a remote host or ip.

where:
-h | -\? | --help   show this help.
-r | --remote       set to FQDN or valid IP.
-p | --ports        set to port range(s) or ports

examples:
$(basename "$BASH_SOURCE") -r 127.0.0.1 -p 20-22
$(basename "$BASH_SOURCE") -r 127.0.0.1 -p 80 443
$(basename "$BASH_SOURCE") -r 127.0.0.1 -p 20-22 443-445 1024 90
"
    echo "$usage";
}

# check if port is valid between 1-65535
function validate_port_number {
    #default is false = 1
    local is_valid_port=1

    if [[ $1 -ge 1 ]] && [[ $1 -le 65535 ]] ; then
        # 0 = true
        is_valid_port=0
    fi
    echo "$is_valid_port"
}

#check if port range has valid ports and start < end.
function validate_port_range {
    #default is false
    local is_valid_range=1

    if [[ $(validate_port_number ${1%-*}) -eq 0 ]] && \
        [[ $(validate_port_number ${1#*-}) -eq 0 ]] && \
        [[ ${1%-*} -le ${1#*-} ]] ; then

             is_valid_range=0  #0 = true
    fi
    echo "$is_valid_range"
}

#main function called to check port and port ranges
function port_safe {
    local is_port_safe=1

    if ( [[ "$1" =~ (^[0-9]{1,5}-[0-9]{1,5}$) ]] && [[ $(validate_port_range $1) -eq 0  ]] ) || \
        ( [[ "$1" =~ (^[0-9]{1,5}$) ]] && [[ $(validate_port_range $1) -eq 0 ]] ); then
        is_port_safe=0;
    fi
    echo "$is_port_safe";
}

# check if remote is pingable.
function remote_alive {
    ping -c 1 $1 >/dev/null;
    echo $?;
}

# Determine Script Arguments ---------------------------------------------------
while :; do
    case $1 in
        -h|-\?|--help)      #Call "show_help" display a synopsis, then exit.
            show_help
            exit
            ;;
        -r|--remote)
            if [ -n "$2" ]; then

                if [[ $(remote_alive "$2") -ne 0 ]]; then
                   printf 'ERROR: "--romote" is not pingable.\n' >&2;
                   exit 1;
                fi

                remote=$2
                shift
            else
                printf 'ERROR: "--romote" requires valid IP address or FQDN.\n' >&2
                show_help
                exit 1
            fi
            ;;
        -p|--ports)
            if [ -n "$2" ]; then
                ports=${*:2}
            else
                printf 'ERROR: "--ports" require valid port numbers or ranges.\n' >&2
                show_help
                exit 1
            fi
            ;;
        *)                  #Default case: break out of look if no more options.
            break
    esac
    shift
done

# Main -------------------------------------------------------------------------
for port in $ports ; do

    if [[ $(port_safe "$port") -eq 0 ]]; then
        nc -v -z -w 3 "$remote" "$port";
    else
        printf "ERROR: connection to %s port(s): %s failed: port(s) invalid.\n" "$remote" "$port">&2
    fi
done
