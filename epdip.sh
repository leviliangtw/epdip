#!/bin/bash
#
# Description: a simple but efficient script for expanding IP addresses in dash format, optimized with bitwise operations and multithreading
# Author: Jih-Wei Liang (leviliangt)
# https://github.com/leviliangtw

POSITIONAL_ARGS=()
SILENCE=YES

if [[ $# -lt 1 ]]; then
  echo "Usage: ./epdip.sh [-f ip_range_file / ip_range] [-m] [-o output_file] [-s]

  -f|--file
      Specify a list of IP ranges for expanding operations. 
  -m|--multithreading
      Expand multiple IP ranges parallelly, which may cause out-of-order output. 
  -o|--outputfile
      Specify a file to store expanded IPs. 
  -s|--silence
      Don't print information messages additional to IPs. "
  exit 1
fi

while [[ $# -gt 0 ]]; do
  case $1 in
    -f|--file)
      SILENCE=NO
      FILE="$2"
      shift # past argument
      shift # past value
      ;;
    -m|--multithreading)
      MULTITHREADING=YES
      shift # past argument
      ;;
    -o|--outputfile)
      OUTPUTFILE="$2"
      shift # past argument
      shift # past value
      ;;
    -s|--silence)
      SILENCE=YES
      shift # past argument
      ;;
    -*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
    *)
      POSITIONAL_ARGS+=("$1") # save positional arg
      shift # past argument
      ;;
  esac
done

set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

if [[ -n ${FILE} ]]; then
    IP_RANGES=$(cat ${FILE})
else
    IP_RANGES=$(echo ${POSITIONAL_ARGS[0]})
fi

if [[ -n ${OUTPUTFILE} ]]; then
    printf "" > ${OUTPUTFILE}
fi

function expandIpRanges {
    if [[ ${SILENCE} = NO ]]; then
        printf "Expanding ${1}...\n"
    fi
    eval $(printf ${1} | awk -F'[.-]' '{print "IP1_DEC=$(( 16777216*"$1"+65536*"$2"+256*"$3"+"$4" )); IP2_DEC=$(( 16777216*"$5"+65536*"$6"+256*"$7"+"$8" ));"}')
    for IP_DEC in $(seq ${IP1_DEC} ${IP2_DEC}); do
        TEMP=${IP_DEC}
        IP=$(( ${TEMP} & 255 ))
        if [[ IP -eq 0 ]]; then
            continue
        fi
        IP=$(( (${TEMP} >> 8) & 255 ))".${IP}"
        IP=$(( (${TEMP} >> 16) & 255 ))".${IP}"
        IP=$(( (${TEMP} >> 24) & 255 ))".${IP}"
        
        if [[ -n ${OUTPUTFILE} ]]; then
            printf "${IP}\n" >> ${OUTPUTFILE}
        else
            printf "${IP}\n"
        fi
    done
    if [[ ${SILENCE} = NO ]]; then
        printf "Expanding ${1} succeeded!\n"
    fi
}

if [[ ${MULTITHREADING} = YES ]]; then
    for IP_RANGE in ${IP_RANGES}; do
        expandIpRanges ${IP_RANGE} &
    done
    wait
else
    for IP_RANGE in ${IP_RANGES}; do
        expandIpRanges ${IP_RANGE}
    done
fi

exit 0
