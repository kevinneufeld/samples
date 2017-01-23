#!/usr/bin/env bash
# InsertLineAtMultiplesOfN.sh
#   This script accepts a string, line number and filename; It will insert the
#   string, in the file at multiples of the line number: N.
#   eg if N=5 at 5, 10, 15...EOF
#
# Created December 20, 2016 by Kevin Neufeld
#
# Resources:
#   man: read
#
#   google:
#       http://stackoverflow.com/questions/10929453/read-a-file-line-by-line-assigning-the-value-to-a-variable
#       http://www.tldp.org/LDP/abs/html/io-redirection.html
#       http://tldp.org/LDP/Bash-Beginners-Guide/html/sect_08_02.html

# Reset all variables that might be set
filename=
string=
line_number=

# Create a temp file for use.
# Directly from mktemp man page.
tempfoo=`basename $0`
TMPFILE=`mktemp -q /tmp/${tempfoo}.XXXXXX`
if [ $? -ne 0 ]; then
       echo "$0: Can't create temp file, exiting..."
       exit 1
fi
#remove tempfile on exit.
trap "rm -f $TMPFILE" EXIT;

# Functions -------------------------------------------------------------------
function show_help {

    local usage="$(basename "$BASH_SOURCE")  [-h] [-s string] [-l number] [-f file] -- Insert a string, into the
file at multiples of the set line number until the EOF.

where:
-h | -\? | --help  show this help.
-s | --string      string to insert.
-l | --line_number set line number.
-f | --filename    input file.

examples:
$(basename "$BASH_SOURCE") -s '---' -l 5 -f examplefile.txtn
"

    echo "$usage";
}

function read_insert_string {

    #Arguments: $1 string; $2 line_number; $3filename
    local counter=1

    while read line ; do
        #if remainder is 0 then divisable by line number
        if [[  $[counter%$2] -eq 0  ]]; then
            echo "$1"
        fi

        echo "$line"
        counter=$[counter + 1];

    done < $3 > $TMPFILE #&& cp -f $TMPFILE $3

    echo "$(cat "$TMPFILE")"
}
# Determine Script Arguments ---------------------------------------------------
while :; do
    case $1 in
        -h|-\?|--help)      #Call "show_help" display a synopsis, then exit.
            show_help
            exit
            ;;
        -l|--line_numeber)
            if [[ -n "$2" ]] && [[ $2 =~ ^-?[0-9]+$  ]]; then
                line_number=$2
                shift
            else
                printf 'ERROR: "--line_number" required a number.\n' >&2
                show_help
                exit 1
            fi
            ;;
        -s|--string)
            if [ -n "$2" ]; then
                string="$2"
                shift
            else
                printf 'ERROR: "--string" required insert string.\n' >&2
                show_help
                exit 1
            fi
            ;;
        -f|--filename)
            if [ -n "$2" ]; then

                if [ ! -f $2 ]; then
                   printf 'ERROR: "--filename" file cannot be found.\n' >&2;
                   exit 1;
                fi
                filename=$2
                shift
            else
                printf 'ERROR: "--filename" required full path to file.\n' >&2
                show_help
                exit 1
            fi
            ;;
        *)                  #Default case: break out of look if no more options.
            break
    esac
    shift
done

read_insert_string "$string" "$line_number" $filename