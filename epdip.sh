#!/bin/bash
#
# Description: a simple but efficient script for expanding IP addresses in dash format, optimized with bitwise operations and multithreading
# Author: Jih-Wei Liang (leviliangt)
# https://github.com/leviliangtw

POSITIONAL_ARGS=()
SLIENCE=NO


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
      SLIENCE=YES
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
    if [[ ${SLIENCE} = NO ]]; then
        printf "Expanding ${1}...\n"
    fi
    eval $(printf ${1} | awk -F'[.-]' '{}END{print "A=\""$1"\"; B=\""$2"\"; C=\""$3"\"; D=\""$4"\";E=\""$5"\"; F=\""$6"\";G=\""$7"\"; H=\""$8"\";"}')
    IP1_DEC=$(( 16777216*${A} + 65536*${B} + 256*${C} + ${D} ))
    IP2_DEC=$(( 16777216*${E} + 65536*${F} + 256*${G} + ${H} ))
    for IP_DEC in $(seq ${IP1_DEC} ${IP2_DEC}); do
        TEMP=${IP_DEC}
        D=$(( ${TEMP} & 255 ))
        if [[ D -eq 0 ]]; then
            continue
        fi
        TEMP=$(( ${TEMP} >> 8 ))
        C=$(( ${TEMP} & 255 ))
        TEMP=$(( ${TEMP} >> 8 ))
        B=$(( ${TEMP} & 255 ))
        TEMP=$(( ${TEMP} >> 8 ))
        A=$(( ${TEMP} & 255 ))
        
        if [[ -n ${OUTPUTFILE} ]]; then
            printf "${A}.${B}.${C}.${D}\n" >> ${OUTPUTFILE}
        else
            printf "${A}.${B}.${C}.${D}\n"
        fi
    done
    if [[ ${SLIENCE} = NO ]]; then
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
