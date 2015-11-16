parse_size() {
  if [ -z "$1" ]; then
    echo "ERROR: null argument to $0"
    exit 1
  fi
  size="$1"
  # Check for size unit 
  unit=$( echo $size | sed -e 's/\([0-9.]\+\)\([KMGT]\)/\2/' )
  count=${size%${unit}}
  case $unit in
    'K') size=$( echo "${count}*1024" | bc ) ;;
    'M') size=$( echo "${size%M}*1024*1024" | bc ) ;;
    'G') size=$( echo "${size%G}*1024*1024*1024" |bc ) ;;
    'T') size=$( echo "${size%T}*1024*1024*1024*1024" | bc ) ;;
    *)
    echo "ERROR: could not parse ${size}"
    exit 1
    ;;
  esac
  echo $size
}
