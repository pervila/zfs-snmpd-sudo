#!/bin/bash
e_ok=0
e_warning=1
e_critical=2
e_unknown=3

magic_oid="NET-SNMP-EXTEND-MIB NET-SNMP-EXTEND-MIB::nsExtendOutLine"

usage() {
  echo "
$0 -H hostname -C community"
}

while getopts "H:C:hd" Option; do
  case $Option in
    H)
      hostname="${OPTARG}"
    ;;
    C)
      snmpcommunity="${OPTARG}"
    ;;
    *) 
      echo "ERROR: unimplemented parameter ${Option}"
      usage
      exit $e_unknown
    ;;
  esac
done

if [ -z "${hostname}" ] || [ -z "${snmpcommunity}" ]; then
  echo "ERROR: not enough parameters given."
  usage
  exit $e_unknown
fi


