#!/bin/bash
# Copyright (C) 2021 Domien Schepers.

if [[ ! $# -eq 2 ]] ; then
    echo "Usage; $0 dataset.pcapng anonimized.pcanpg"
    exit 1
fi

# Parameters.
INPUT_DATASET=$1
INPUT_ANONIMIZED=$2

# Common TSHARK-Filters.
FILTER_GLOBAL_2GHZ="(radiotap.channel.flags.2ghz==0x01 \
	|| ppi.80211-common.chan.flags.2ghz==0x01)"
FILTER_GLOBAL_5GHZ="(radiotap.channel.flags.5ghz==0x01 \
	|| ppi.80211-common.chan.flags.5ghz==0x01)"

# Sanity Checks.
if ! command -v tshark &> /dev/null; then
    echo "Command tshark could not be found."
    exit 1
fi
if [ ! -f "$INPUT_DATASET" ]; then
    echo "$INPUT_DATASET does not exist."
    exit 1
fi
if [ ! -f "$INPUT_ANONIMIZED" ]; then
    echo "$INPUT_ANONIMIZED does not exist."
    exit 1
fi

# Overview of the number of frames in each dataset.
echo "Number of frames:"
result=$(tshark -r $INPUT_DATASET | wc -l)
printf "%8d\t%s\n" $result $INPUT_DATASET
result=$(tshark -r $INPUT_ANONIMIZED | wc -l)
printf "%8d\t%s\n" $result $INPUT_ANONIMIZED
echo

# Sanity Check on the number of unique BSSIDs.
echo "Number of unique BSSIDs:"
result=$(tshark -r $INPUT_DATASET -e "wlan.bssid" -Tfields "wlan.bssid" | uniq | wc -l)
printf "%8d\t%s\n" $result $INPUT_DATASET
# Anonimized dataset does not need to be unique, as we already performed filtering.
result=$(tshark -r $INPUT_ANONIMIZED -e "wlan.bssid" -Tfields "wlan.bssid" | wc -l)
printf "%8d\t%s\n" $result $INPUT_ANONIMIZED
echo

# Sanity Check on the number of unique SSIDs.
echo "Number of unique SSIDs"
result=$(tshark -r $INPUT_DATASET -e "wlan.ssid" -Tfields "wlan.ssid" | uniq | wc -l)
printf "%8d\t%s\n" $result $INPUT_DATASET
result=$(tshark -r $INPUT_ANONIMIZED -e "wlan.ssid" -Tfields "wlan.ssid" | uniq | wc -l)
printf "%8d\t%s\n" $result $INPUT_ANONIMIZED
echo

# Sanity Check on the number of unique networks per frequency band.
echo "Overview of unique networks per frequency band:"
result=$(tshark -r $INPUT_DATASET -Y "$FILTER_GLOBAL_2GHZ" | wc -l)
printf "2.4 GHz: %8d\t%s\n" $result $INPUT_DATASET
result=$(tshark -r $INPUT_ANONIMIZED -Y "$FILTER_GLOBAL_2GHZ" | wc -l)
printf "2.4 GHz: %8d\t%s\n" $result $INPUT_ANONIMIZED
result=$(tshark -r $INPUT_DATASET -Y "$FILTER_GLOBAL_5GHZ" | wc -l)
printf "  5 GHz: %8d\t%s\n" $result $INPUT_DATASET
result=$(tshark -r $INPUT_ANONIMIZED -Y "$FILTER_GLOBAL_5GHZ" | wc -l)
printf "  5 GHz: %8d\t%s\n" $result $INPUT_ANONIMIZED
