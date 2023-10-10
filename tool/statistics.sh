#!/bin/bash
# Copyright (C) 2021-2023 Domien Schepers.

##########################################################################################
### Tool for Drawing Security Statistics of Wi-Fi Networks ###############################
##########################################################################################
# TSHARK-Filters:
# https://www.wireshark.org/docs/dfref/w/wlan.html

# Common TSHARK-Filters.
FILTER_GLOBAL_OPEN="(wlan.fixed.capabilities.privacy==0)"
FILTER_GLOBAL_2GHZ="(radiotap.channel.flags.2ghz==0x01 \
	|| ppi.80211-common.chan.flags.2ghz==0x01)"
FILTER_GLOBAL_5GHZ="(radiotap.channel.flags.5ghz==0x01 \
	|| ppi.80211-common.chan.flags.5ghz==0x01)"
FILTER_GLOBAL_HIDDEN="(!wlan.ssid||wlan.ssid==\"\")"
FILTER_GLOBAL_MESH="(wlan.mesh.id)"

run_tshark_filter () {
	# $1 = Description of the filter.
	# $2 = The filter to be ran using TSHARK.
	DESCRIPTION=$1
	Y=$2
	
	# Append a potential global filter to the command.
	if [ "$FILTER" ]; then
		Y="($2)&&($FILTER_GLOBAL)"
	fi
	
	# Execute the filter and print the results.
	result=$(tshark -r $INPUT -Y "$Y" | wc -l)
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
	TOTAL=$(tshark -r $INPUT | wc -l)
	TOTAL=$(printf "%d" $TOTAL)
	echo "Analyzing <$INPUT> with <$TOTAL> frames..."
	
	# Sanity check on the number of frames.
	if [ "$TOTAL" -eq 0 ]; then
		exit 0
	fi
	
	# Construct the requested global filter.
	if [ "$FILTER" ]; then
		TOTAL_ORIGINAL=$TOTAL
		
		# Set the Internal Field Separator (IFS) variable for multiple filter requests.
		IFS='+' read -ra FILTERS <<< "$FILTER"
		for i in "${FILTERS[@]}"; do
		
			#  Validate and assign the requested filter.
			case "$i" in
				'open' )
					FILTER_ITEM=$FILTER_GLOBAL_OPEN
					;;
				'encrypted' )
					FILTER_ITEM=!$FILTER_GLOBAL_OPEN
					;;
				'hidden' )
					FILTER_ITEM=$FILTER_GLOBAL_HIDDEN
					;;
				'non-hidden' )
					FILTER_ITEM=!$FILTER_GLOBAL_HIDDEN
					;;
				'mesh' )
					FILTER_ITEM=$FILTER_GLOBAL_MESH
					;;
				'non-mesh' )
					FILTER_ITEM=!$FILTER_GLOBAL_MESH
					;;
				'2ghz' )
					FILTER_ITEM=$FILTER_GLOBAL_2GHZ
					;;
				'5ghz' )
					FILTER_ITEM=$FILTER_GLOBAL_5GHZ
					;;
				* )
					echo "Quitting: filter <$i> is not supported."
					exit 1
					;;
			esac
		
			# Add more individual filters to the global filter.
			if [ -z "$FILTER_GLOBAL" ]; then
				FILTER_GLOBAL=$FILTER_ITEM
			else
				FILTER_GLOBAL+="&&"$FILTER_ITEM
			fi
		
		done
		
		# Print the filtering results.
		TOTAL=$(tshark -r $INPUT -Y "$FILTER_GLOBAL" | wc -l)
		TOTAL=$(printf "%d" $TOTAL)
		percentage=$(bc -l <<< "($TOTAL/$TOTAL_ORIGINAL)*100")
		percentage=$(printf "%0.2f" $percentage)
		echo "Applied filter resulting in <$TOTAL> frames ($percentage %)..."
		
		# Sanity check on the number of frames.
		if [ "$TOTAL" -eq 0 ]; then
			exit 0
		fi
	
		# Write filtered output to a new network capture file.
	 	if [ "$OUTPUT" ]; then
	 		tshark -r $INPUT -Y "$FILTER_GLOBAL" -w $OUTPUT
			exit 0
	 	fi
		
	fi
	
}

##########################################################################################
##########################################################################################
##########################################################################################

standards () {
	echo "Standards:"

	# WMM/WME Information Element.
	FILTER_IEEE_E="wlan.wfa.ie.wme.version"
	# IEEE 802.11n will have an HT Capabilities and Information field.
	FILTER_IEEE_N="wlan.ht.capabilities"
	# IEEE 802.11w will have support for PMF.
	# Management Frame Protection Capable.
	FILTER_IEEE_W="wlan.rsn.capabilities.mfpc==0x01 || wlan.aironet.clientmfp==0x01"
	# IEEE 802.11ac will mandate a 80 MHz bandwidth, and an optional 160 MHz for Wave 2.
	# wlan.vht.capabilities.supportedchanwidthset==0x0 ---> Neither 160 nor 80+80 MHz.
	# wlan.vht.capabilities.supportedchanwidthset==0x1 ---> 160 MHz supported.
	# wlan.vht.capabilities.supportedchanwidthset==0x2 ---> 160 and 80+80 MHz supported.
	FILTER_IEEE_AC_WAVE1="wlan.vht.capabilities && wlan.vht.op \
		&& wlan.vht.capabilities.supportedchanwidthset==0x0"
	FILTER_IEEE_AC_WAVE2="wlan.vht.capabilities && wlan.vht.op \
		&& wlan.vht.capabilities.supportedchanwidthset>0x0"
	# IEEE 802.11ax.
	# HE MAC Capabilities Information.
	FILTER_IEEE_AX="wlan.ext_tag.he_mac_caps \
		&& wlan.ext_tag.he_operation.params"

	run_tshark_filter "(2005) IEEE 802.11e" "$FILTER_IEEE_E"
	run_tshark_filter "(2009) IEEE 802.11n" "$FILTER_IEEE_N"
	run_tshark_filter "(2009) IEEE 802.11w" "$FILTER_IEEE_W"
	run_tshark_filter "(2013) IEEE 802.11ac Wave 1" "$FILTER_IEEE_AC_WAVE1"
	run_tshark_filter "(2016) IEEE 802.11ac Wave 2" "$FILTER_IEEE_AC_WAVE2"
	run_tshark_filter "(2019) IEEE 802.11ax" "$FILTER_IEEE_AX"
	
}

frequency () {
	echo "Frequency:"
	
	run_tshark_filter "2.4 GHz Band" "$FILTER_GLOBAL_2GHZ"
	run_tshark_filter "5 GHz Band" "$FILTER_GLOBAL_5GHZ"
	
}

encryption () {
	echo "Encryption and Key Management:"
	
	run_tshark_filter "Open" "$FILTER_GLOBAL_OPEN"
	run_tshark_filter "Encrypted" "!$FILTER_GLOBAL_OPEN"
	
	echo
	
	FILTER_PAIR_NONE="!wlan.rsn.pcs.type && !wlan.wfa.ie.wpa.ucs.type"
	FILTER_PAIR_WEP="wlan.rsn.pcs.type==1 || wlan.rsn.pcs.type==5 \
		|| wlan.wfa.ie.wpa.ucs.type==1 || wlan.wfa.ie.wpa.ucs.type==5"
	FILTER_PAIR_TKIP="wlan.rsn.pcs.type==2 || wlan.wfa.ie.wpa.ucs.type==2"
	FILTER_PAIR_CCMP="wlan.rsn.pcs.type==4 || wlan.wfa.ie.wpa.ucs.type==4"
	FILTER_PAIR_GCMP="wlan.rsn.pcs.type==9 || wlan.wfa.ie.wpa.ucs.type==9"
	
	run_tshark_filter "Pairwise Key (None)" "$FILTER_PAIR_NONE"
	run_tshark_filter "Pairwise Key (WEP)" "$FILTER_PAIR_WEP"
	run_tshark_filter "Pairwise Key (TKIP)" "$FILTER_PAIR_TKIP"
	run_tshark_filter "Pairwise Key (CCMP)" "$FILTER_PAIR_CCMP"
	run_tshark_filter "Pairwise Key (GCMP)" "$FILTER_PAIR_GCMP"
	
	echo
	
	FILTER_GROUP_NONE="!wlan.rsn.gcs.type && !wlan.wfa.ie.wpa.mcs.type"
	FILTER_GROUP_WEP="wlan.rsn.gcs.type==1 || wlan.rsn.gcs.type==5 \
		|| wlan.wfa.ie.wpa.mcs.type==1 || wlan.wfa.ie.wpa.mcs.type==5"
	FILTER_GROUP_TKIP="wlan.rsn.gcs.type==2 || wlan.wfa.ie.wpa.mcs.type==2"
	FILTER_GROUP_CCMP="wlan.rsn.gcs.type==4 || wlan.wfa.ie.wpa.mcs.type==4"
	FILTER_GROUP_GCMP="wlan.rsn.gcs.type==9 || wlan.wfa.ie.wpa.mcs.type==9"
	
	run_tshark_filter "Group Key (None)" "$FILTER_GROUP_NONE"
	run_tshark_filter "Group Key (WEP)" "$FILTER_GROUP_WEP"
	run_tshark_filter "Group Key (TKIP)" "$FILTER_GROUP_TKIP"
	run_tshark_filter "Group Key (CCMP)" "$FILTER_GROUP_CCMP"
	run_tshark_filter "Group Key (GCMP)" "$FILTER_GROUP_GCMP"
	
	echo
	
	FILTER_AKM_NONE="!wlan.rsn.akms.type && !wlan.wfa.ie.wpa.type"
	FILTER_AKM_PSK="wlan.rsn.akms.type==2 || wlan.rsn.akms.type==4 \
		 || wlan.rsn.akms.type==6 || wlan.wfa.ie.wpa.type==2 \
		 || wlan.wfa.ie.wpa.type==4 || wlan.wfa.ie.wpa.type==6"
	FILTER_AKM_EAP="wlan.rsn.akms.type==1 || wlan.rsn.akms.type==3 \
		 || wlan.rsn.akms.type==5 || wlan.wfa.ie.wpa.type==1 \
		 || wlan.wfa.ie.wpa.type==3 || wlan.wfa.ie.wpa.type==5"
	FILTER_AKM_SAE="wlan.rsn.akms.type==8 || wlan.rsn.akms.type==9 \
		|| wlan.wfa.ie.wpa.type==8 || wlan.wfa.ie.wpa.type==9"
	
	run_tshark_filter "Auth Key Management (None)" "$FILTER_AKM_NONE"
	run_tshark_filter "Auth Key Management (PSK)" "$FILTER_AKM_PSK"
	run_tshark_filter "Auth Key Management (EAP)" "$FILTER_AKM_EAP"
	run_tshark_filter "Auth Key Management (SAE)" "$FILTER_AKM_SAE"
	
}

pmf () {
	echo "Protected Management Frames:"
	
	FILTER_MFP="wlan.rsn.capabilities.mfpr || wlan.aironet.clientmfp"
	FILTER_MFP_CAPABLE="wlan.rsn.capabilities.mfpc==0x01 || wlan.aironet.clientmfp==0x01"
	FILTER_MFP_REQUIRED="wlan.rsn.capabilities.mfpr==0x01"
	
	run_tshark_filter "MGMT Protection" "$FILTER_MFP"
	run_tshark_filter "MGMT Protection Capable" "$FILTER_MFP_CAPABLE"
	run_tshark_filter "MGMT Protection Required" "$FILTER_MFP_REQUIRED"
	
}

wps () {
	echo "Wi-Fi Protected Setup:"

	FILTER_WPS_01="wps.wifi_protected_setup_state==0x01"
	FILTER_WPS_02="wps.wifi_protected_setup_state==0x02"
	FILTER_WPS_03="wps.wifi_protected_setup_state"

	run_tshark_filter "WPS (Not Configured)" "$FILTER_WPS_01"
	run_tshark_filter "WPS (Configured)" "$FILTER_WPS_02"
	run_tshark_filter "WPS (Any)" "$FILTER_WPS_03"
	
}

hidden () {
	echo "Hidden Networks:"

	run_tshark_filter "Hidden SSID" "$FILTER_GLOBAL_HIDDEN"
	run_tshark_filter "Non-Hidden SSID" "!$FILTER_GLOBAL_HIDDEN"

}

mesh () {
	echo "Mesh Networks:"

	run_tshark_filter "Mesh Networks" "$FILTER_GLOBAL_MESH"
	run_tshark_filter "Non-Mesh Networks" "!$FILTER_GLOBAL_MESH"
	
}

##########################################################################################
##########################################################################################
##########################################################################################

usage () {
	echo "Usage: $0 -r filename [-c command] [-f filter] [-w filename]"
	echo ""
	echo "Options:"
	echo "   [-h]                     Display this help message."
	echo "    -r filename             Read from a network capture file."
	echo "   [-c command]             Run a command to obtain certain statistics."
	echo "                            Supported: standards, frequency, encryption, pmf,"
	echo "                            wps, hidden, mesh, and all (default)."
	echo "   [-f filter]              Apply a global filter to all statistics."
	echo "                            Supported: open, encrypted, hidden, non-hidden,"
	echo "                            mesh, non-mesh, 2ghz, and 5ghz."
	echo "   [-w filename]            Write filtered results to a new file."
	exit 0
}

# Default arguments.
COMMAND=all

# Parse command-line arguments.
while getopts ":hr:c:f:w:" opt; do
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
		f)
			FILTER=${OPTARG}
			;;
		w)
			OUTPUT=${OPTARG}
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
	'standards' | 'frequency' | 'encryption' | 'pmf' | 'wps' | 'hidden' | 'mesh' )
		initialize
		run $COMMAND
		;;
	'all' )
		initialize
		run standards
		run frequency
		run encryption
		run pmf
		run wps
		run hidden
		run mesh
		;;
	*)
		usage
		;;
esac
