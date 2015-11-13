#!/bin/bash
e_ok=0
e_warning=1
e_critical=2
e_unknown=3
magic_mib="NET-SNMP-EXTEND-MIB"
magic_oid="${magic_mib}::nsExtendOutLine"

usage() {
  echo "
$0 -H hostname -C community

Uses snmpwalk to fetch ${magic_oid} from hostname using community"
}

while getopts "H:C:hd" Option; do
  case $Option in
    H)
      hostname="${OPTARG}"
    ;;
    C)
      community="${OPTARG}"
    ;;
    *) 
      echo "ERROR: unimplemented parameter ${Option}"
      usage
      exit $e_unknown
    ;;
  esac
done

if [ -z "${hostname}" ] || [ -z "${community}" ]; then
  echo "ERROR: not enough parameters given."
  usage
  exit $e_unknown
fi

t=$(mktemp)
snmpwalk -v 2c -c "${community}" -m "${magic_mib}"  "${hostname}" "${magic_oid}" > "$t"
if [ ! $? -eq 0 ]; then
  echo "ERROR: could not fetch snmp data from ${hostname}"
  rm $t
  exit $e_unknown
fi
cat $t

zpool_capacity="$(grep zpool_capacity tests/sample_output.txt | sed -e 's/.*STRING: \([0-9]\+\)\+%/\1%/')"
echo "cap is $zpool_capacity"
zpool_dedupratio="$(grep zpool_dedupratio tests/sample_output.txt | sed -e 's/.*STRING: \([0-9.]\+\)\+x/\1x/')"
echo "dedupratio is $zpool_dedupratio"
# these two are almost the same, but I'm avoiding metaprogramming with Bash
zpool_available="$(grep zpool_available tests/sample_output.txt | sed -e 's/.*STRING: \([0-9]\+\)\+/\1/')"
echo "available is $zpool_available"
zpool_used="$(grep zpool_used tests/sample_output.txt | sed -e 's/.*STRING: \([0-9]\+\)\+/\1/')"
echo "used is $zpool_used"

rm $t
