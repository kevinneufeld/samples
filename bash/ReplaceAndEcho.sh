#!/usr/bin/env bash
# ReplaceAndEcho.sh:
#   This script that accepts a filename, regular expression and replacement
#   string and echo back to results without modifing the orginal file contents.
#
# Created December 20, 2016 by Kevin Neufeld
#
# Went with perl regex over POSIX.
# Reset all variables that might be set
# Resources:
#   man pages: sed, awk, perlrun and mktemp
#
#   regex testing: http://regexr.com/
#   google: perl vs sed vs awk
#       http://rc3.org/2014/08/28/surprisingly-perl-outperforms-sed-and-awk/
#       http://stackoverflow.com/questions/366980/what-are-the-differences-between-perl-python-awk-and-sed


filename=
regex=
replacement=

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

# Basic functions --------------------------------------------------------------
function show_help {
    local usage="$(basename "$BASH_SOURCE")  [-h] [-f file] [-p regex] [-s string]-- Returns back the results of search and
replace of all occuances with in a file, without modifing the file.

where:
-h | -\? | --help  show this help.
-f | --filename    input file.
-p | --pattern     regular express pattern (perl regex)
-s | --string      replacement string.

examples:
$(basename "$BASH_SOURCE") -f examplefile.txt -p '\b\d{3}[-.]?\d{3}[-.]?\d{4}\b' -s 'XXX-XXX-XXXX'
"
    echo "$usage";
}
# Determine Script Arguments ---------------------------------------------------
while :; do
    case $1 in
        -h|-\?|--help)      #Call "show_help" display a synopsis, then exit.
            show_help
            exit
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
        -p|--pattern)
            if [ -n "$2" ]; then
                regex=$2
                shift
            else
                printf 'ERROR: "--pattern" required valid regex pattern.\n' >&2
                show_help
                exit 1
            fi
            ;;
        -s|--string)
            if [ -n "$2" ]; then
                replacement=$2
                shift
            else
                printf 'ERROR: "--string" required replacement string.\n' >&2
                show_help
                exit 1
            fi
            ;;
        *)                  #Default case: break out of look if no more options.
            break
    esac
    shift
done

#Perfer perl's regex support over MacOS SED
#sed -E 's,'"$regex"','"$replacement"',g' $filename>$TMPFILE;
#Copy file to temp
cp -f $filename $TMPFILE
#use perl to find and replace
perl -pi -e 's/'"$regex"'/'"$replacement"'/g' $TMPFILE;

#echo out the results
echo "$(cat "$TMPFILE")";

