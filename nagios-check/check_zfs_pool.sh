#!/bin/bash
e_ok=0
e_ok_str="OK"
e_warning=1
e_warning_str="WARNING"
e_critical=2
e_critical_str="CRITICAL"
e_unknown=3
e_unknown_str="UNKNOWN"
magic_mib="NET-SNMP-EXTEND-MIB"
magic_oid="${magic_mib}::nsExtendOutLine"

usage() {
  echo "
$0 -H hostname -C community

Uses snmpwalk to fetch ${magic_oid} from hostname using community"
}

while getopts "H:C:hvw:c:" Option; do
  case $Option in
    H)
      hostname="${OPTARG}"
    ;;
    C)
      community="${OPTARG}"
    ;;
    w)
      warning="${OPTARG}"
    ;;
    c)
      critical="${OPTARG}"
    ;;
    v)
      verbose=1
    ;;
    *) 
      echo "ERROR: unimplemented parameter ${Option}"
      usage
      exit $e_unknown
    ;;
  esac
done

for value in "$hostname" "$community" "$warning" "$critical"; do
 if [ -z "${value}" ]; then
 
   echo "ERROR: not enough parameters given."
   usage
   exit $e_unknown
 fi
done

t=$(mktemp)
snmpwalk -v 2c -c "${community}" -m "${magic_mib}"  "${hostname}" "${magic_oid}" > "$t"
if [ ! $? -eq 0 ]; then
  echo "ERROR: could not fetch snmp data from ${hostname}"
  rm $t
  exit $e_unknown
fi

if [ "$verbose" = 1 ]; then
  echo "INFO: snmpwalk successful, results:"
  cat $t
fi

zpool_name="$(grep zpool_name tests/sample_output.txt | sed -e 's/.*STRING: \(.\+\)\+/\1/')"
zpool_capacity="$(grep zpool_capacity tests/sample_output.txt | sed -e 's/.*STRING: \([0-9]\+\)\+%/\1/')"
zpool_dedupratio="$(grep zpool_dedupratio tests/sample_output.txt | sed -e 's/.*STRING: \([0-9.]\+\)\+x/\1x/')"
zpool_available="$(grep zpool_available tests/sample_output.txt | sed -e 's/.*STRING: \([0-9]\+\)\+/\1/')"
zpool_used="$(grep zpool_used tests/sample_output.txt | sed -e 's/.*STRING: \([0-9]\+\)\+/\1/')"

err_code=$e_ok
status=$e_ok_str
if [ $zpool_capacity -ge "$warning" ]; then
  err_code=$e_warning
  status=$e_warning_str
fi
if [ $zpool_capacity -ge "$critical" ]; then
  err_code=$e_critical
  status=$e_critical_str 
fi

echo "zpool $zpool_name ${status}; usage ${zpool_capacity}%; dedup ratio $zpool_dedupratio; ($zpool_available/$zpool_used)"
rm $t
