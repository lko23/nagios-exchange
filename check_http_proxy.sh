
#!/bin/bash
#
# check https return by curl for some string using proxy
#
##########################################################

PROGNAME=`basename $0`

help() {
cat << END
Usage :
        $PROGNAME -u [STRING] -r [STRING]

        OPTION          DESCRIPTION
        ----------------------------------
        -h              Help
        -u [STRING]     URL
        -r [STRING]     Regex
        -v              Verbose
        ----------------------------------
END
}

if [ $# -lt 2 ]
then
        help;
        exit 3;
fi

while getopts "hu:r:v" OPT
do
        case $OPT in
        h) help ;;
        u) url="$OPTARG" ;;
        r) reg="$OPTARG" ;;
        v) ver=true ;;
        *) help ;;
        esac
done

ret=`curl -s -x 'http://user:proxy@proxy.domain.com:port' $url`

if [[ $ver == true ]]; then
echo "URL: $url"
echo "Regex: $reg"
echo "Return: $ret"
fi

if [[ $ret == *$reg* ]]; then
    echo "OK: String $reg found on $url"
    exit 0
else
    echo "CRITICAL: String $reg not found on $url"
    exit 2
fi

echo "UNKNOWN: not handled Error"
exit 3
