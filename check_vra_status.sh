#!/bin/bash
##########################################################
# Check VRA Status

PROGNAME=`basename $0`
VERSION="Version 1.0,"
AUTHOR="lko23"

help() {
cat << END
Usage :
        $PROGNAME -l [STRING] -H [STRING] -p [VALUE] -w [VALUE] -c [VALUE]

        OPTION          DESCRIPTION
        ----------------------------------
        -h              Help
        -l [STRING]     Remote user
        -H [STRING]     Host name
        -w [VALUE]      Warning threshold number of running services (higher)
        -c [VALUE]      Critical threshold number of running services (lower)
        ----------------------------------
Note : [VALUE] must be an integer.
END
}

if [ $# -ne 8 ]
then
        help;
        exit 3;
fi

while getopts "l:H:w:c:" OPT
do
        case $OPT in
        l) USERNAME="$OPTARG" ;;
        H) HOSTNAME="$OPTARG" ;;
        w) hi="$OPTARG" ;;
        c) lo="$OPTARG" ;;
        *) help ;;
        esac
done

running=`ssh -q -l $USERNAME $HOSTNAME -C "grep -i '\"state\":\s\"running\"' /run/vmware/prelude/service/monitor/local.json | wc -l"`
output=`ssh -q -l $USERNAME $HOSTNAME -C "grep -i '\"name\|.......\"value\|\"state' /run/vmware/prelude/service/monitor/local.json | sed -e 's/^[ \t]*//' | pcregrep -M -v '\"name\":.*\n\"value\":\s\"healthy\"\n\"state\":\s\"running\"\n\"state\":\s\"started\"' | pcregrep -M -v '\"name\":.*\n\"state\":\s\"started\"'"`
perf_data="proc_running=$running;$hi;$lo;;"

if [ -n "$running" ]; then
        if  [ "$running" -le "$lo" ]; then
                echo "Critical: Not enough running processes ($running <= $lo)"
                echo "$output|$perf_data"
                exit 2
        elif  [ "$running" -ge "$hi" ]; then
                echo "Warning: Too many running processes ($running >= $hi)"
                echo "$output|$perf_data"
                exit 1
        elif  [ "$running" -gt "$lo" -a "$running" -lt "$hi" ]; then
                echo "OK: All processes are running"
                echo "$output|$perf_data"
                exit 0
        fi
 else
        echo "Unknown error"
        exit 3
fi
