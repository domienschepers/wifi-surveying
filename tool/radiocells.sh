#!/bin/bash
# Copyright (C) 2021 Domien Schepers.

TABLE="wifiap"

##########################################################################################
### Tool for Drawing Security Statistics of Wi-Fi Networks ###############################
##########################################################################################

run_query () {
	# $1 = Description of the query.
	# $2 = The query to be ran using sqlite3.
	DESCRIPTION=$1
	QUERY=$2
	
	# Execute the query and print the results.
	result=$(sqlite3 $INPUT "$QUERY" ".exit")
	percentage=$(bc -l <<< "($result/$TOTAL)*100")
	percentage=$(printf "%0.2f" $percentage)
	printf "%8d = %6s %%   " $result $percentage
	echo $DESCRIPTION
	
}

run () {
	# $1 = Requested command.
	echo
	$1
}

initialize () {
	QUERY="SELECT COUNT(DISTINCT bssid) FROM $TABLE"
	TOTAL=$(sqlite3 $INPUT "$QUERY" ".exit")
	TOTAL=$(printf "%d" $TOTAL)
	echo "Analyzing <$INPUT> with <$TOTAL> distinct records..."
	
	# Sanity check on the number of frames.
	if [ "$TOTAL" -eq 0 ]; then
		exit 0
	fi
	
}

##########################################################################################
##########################################################################################
##########################################################################################

frequency () {
	echo "Frequency:"
	
	QUERY_2GHZ="SELECT COUNT(DISTINCT bssid) FROM $TABLE \
		WHERE ntiu >= 2412 AND ntiu <= 2484"
	QUERY_5GHZ="SELECT COUNT(DISTINCT bssid) FROM $TABLE \
		WHERE ntiu >= 5160 AND ntiu <= 5865"
	
	run_query "2.4 GHz Band" "$QUERY_2GHZ"
	run_query "5 GHz Band" "$QUERY_5GHZ"
	
}

encryption () {
	echo "Encryption:"
	
	QUERY_WEP="SELECT COUNT(DISTINCT bssid) FROM $TABLE \
		WHERE capa LIKE '%WEP%'"
	QUERY_TKIP="SELECT COUNT(DISTINCT bssid) FROM $TABLE \
		WHERE capa LIKE '%TKIP%'"
	QUERY_CCMP="SELECT COUNT(DISTINCT bssid) FROM $TABLE \
		WHERE capa LIKE '%CCMP%'"
	
	run_query "WEP" "$QUERY_WEP"
	run_query "TKIP" "$QUERY_TKIP"
	run_query "CCMP" "$QUERY_CCMP"
	
}

wps () {
	echo "Wi-Fi Protected Setup:"
	
	QUERY_WPS="SELECT COUNT(DISTINCT bssid) FROM $TABLE \
		WHERE capa LIKE '%WPS%'"
	
	run_query "WPS" "$QUERY_WPS"
	
}

hidden () {
	echo "Hidden Networks:"
	
	QUERY_HIDDEN_SSID="SELECT COUNT(DISTINCT bssid) FROM $TABLE \
		WHERE md5essid LIKE 'D41D8CD98F0B24E980998ECF8427E'"
	
	run_query "Hidden SSID" "$QUERY_HIDDEN_SSID"
	
}

##########################################################################################
##########################################################################################
##########################################################################################

usage () {
	echo "Usage: $0 -r filename [-c command]"
	echo ""
	echo "Options:"
	echo "   [-h]                     Display this help message."
	echo "    -r filename             Read from a database file."
	echo "   [-c command]             Run a command to obtain certain statistics."
	echo "                            Supported: frequency, encryption, wps, hidden," 
	echo "                            and all (default)."
	exit 0
}

# Default arguments.
COMMAND=all

# Parse command-line arguments.
while getopts ":hr:c:" opt; do
	case "$opt" in
		h)
			usage
			;;
		r)
			INPUT=${OPTARG}
			;;
		c)
			COMMAND=${OPTARG}
			;;
		*)
			usage
			;;
	esac
done
shift $((OPTIND-1))

# Verify arguments.
if [ -z "$INPUT" ]; then
    usage
fi
if [ ! -f "$INPUT" ]; then
    echo "Quitting: file <$INPUT> does not exist."
    exit 1
fi

# Run the requested command.
case "$COMMAND" in
	'frequency' | 'encryption' | 'wps' | 'hidden' )
		initialize
		run $COMMAND
		;;
	'all' )
		initialize
		run frequency
		run encryption
		run wps
		run hidden
		;;
	*)
		usage
		;;
esac
