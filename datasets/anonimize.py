#!/usr/bin/env python3
# Copyright (C) 2021 Domien Schepers.

from scapy.layers.all import Dot11FCS,Dot11,Dot11Beacon,Dot11ProbeResp,Dot11Elt
from scapy.layers.all import RadioTap,PPI,raw
from scapy.contrib.ppi_cace import PPI_Dot11Common
from scapy.utils import PcapReader,PcapWriter
import argparse

##########################################################################################
class Anonimize:
	""" Anonimize WLAN Beacon and Probe Response frames.
	"""
	
	# Variables.
	input = None
	output = None
	bssids = [] # List of known network BSSIDs.
	ssids = {} # Map of known network SSIDs.
	counter = 0
	
	def __init__( self , input = None , output = None ):
		assert( input is not None and output is not None ), \
			"Please provide an input and output file."
		self.input = input
		self.output = PcapWriter( output , append=True )
	
	def run( self ):
		for packet in PcapReader( self.input ):
			# Perform sanity checks and filter BSSIDs to discard repeating networks.
			packet = self.__filter( packet )
			if packet is None:
				continue
			# Anonimize newly discovered networks.
			packet = self.__sanitize_radiotap_and_fcs( packet )
			packet = self.__sanitize_mac_addresses( packet )
			packet = self.__sanitize_ssid( packet )
			packet = self.__sanitize_miscellaneous( packet )
			# Write the anonymized packet to file.
			self.output.write( packet )
			
	def __filter( self , packet ):
		""" Filter for a single beacon or probe response frame per unique network.
		"""
		# Sanity checks for Beacon and Probe Response frames.
		if not( packet.haslayer(Dot11Beacon) or packet.haslayer(Dot11ProbeResp) ):
			return None
		# Discard packet if we have seen the Basic Service Set IDentifier (BSSID) before.
		if packet.addr3 in self.bssids:
			return None
		# Save the new BSSID, and return the packet.
		self.bssids.append( packet.addr3 )
		return packet
			
	def __sanitize_radiotap_and_fcs( self , packet ):
		""" Reset the radiotap/ppi header, and potential frame check sequences.
		"""
		# Reset the RadioTap/PPI header, recoding any channel information; it avoids
		# formatting issues when writing a mix of packet types to file.
		radiotap = RadioTap()
		if packet.haslayer(RadioTap):
			radiotap = RadioTap( present='Channel' , 
				ChannelFrequency=packet[RadioTap].ChannelFrequency ,
				ChannelFlags=packet[RadioTap].ChannelFlags )
		elif packet.haslayer(PPI) and packet.haslayer(PPI_Dot11Common):
			# https://scapy.readthedocs.io/en/latest/api/scapy.contrib.ppi_cace.html
			radiotap = RadioTap( present='Channel' ,
				ChannelFrequency=packet[PPI_Dot11Common].Ch_Freq ,
				ChannelFlags=packet[PPI_Dot11Common].Ch_Flags )
		# Due to our modifications, we will corrupted the checksum, thus let us remove it.
		if packet.haslayer(PPI_Dot11Common) and not packet.haslayer(Dot11FCS):
			if 'FCS' in packet[PPI_Dot11Common].Pkt_Flags:
				packet = Dot11(raw(packet[Dot11])[:-4])
		elif packet.haslayer(Dot11FCS):
			packet = Dot11(raw(packet[Dot11FCS])[:-4])
		# Return sanitized packet.
		return radiotap/packet[Dot11]
		
	def __sanitize_mac_addresses( self , packet ):
		"""	Remove the three least-significant bytes of MAC addresses, thereby keeping
			the three most-significant vendor-assigned bytes (OUI).
		"""
		# Probe responses require their destination MAC address to be anonymized, since
		# these addresses identify the client station which sent the probe request. 
		if packet.haslayer(Dot11ProbeResp):
			packet.addr1 = packet.addr1[:9] + "00:00:00"
		# Anonymize all other MAC addresses.
		packet.addr2 = packet.addr2[:9] + "00:00:00"
		packet.addr3 = packet.addr3[:9] + "00:00:00" # BSSID
		# Precautionary check for bridging networks.
		if packet.addr4:
			packet.addr4 = packet.addr4[:9] + "00:00:00"
		return packet
		
	def __sanitize_ssid( self , packet ):
		"""	Map every SSID to a pseudonym “SSID-N” where N is an incremental number. 
			Note: we skip hidden networks, that is, networks with an empty SSID.
		"""
		# Find the SSID information element.
		ie = packet
		while Dot11Elt in ie:
			ie = ie[Dot11Elt]
			if ie.ID == 0:
				# Skip hidden networks: their empty SSID exposes no sensitive information.
				if not ie.info or ie.info[0]==0:
					break
				# Search our SSID map for known SSIDs, and get its anonymized value.
				ssid = self.ssids.get( ie.info )
				# If not known, generate a newly anonymized value.
				if ssid is None:
					ssid = "SSID-" + str("{:06d}".format(self.counter))
					self.ssids[ ie.info ] = ssid
					self.counter += 1
				# Modify the SSID value and its length.
				ie.setfieldval( 'info' , ssid )
				ie.setfieldval( 'len' , len(ssid) )
				break
			ie = ie.payload
		# Return the packet.
		return packet
		
	def __sanitize_miscellaneous( self , packet ):
		""" Sanitize miscellaneous fields.
		"""
		# Reset the frame's timestamp.
		packet[Dot11].setfieldval( 'timestamp' , 0 )
		# Reset fragment and sequence numbers.
		packet[Dot11].setfieldval( 'SC' , 0 )
		return packet
		
##########################################################################################
if __name__ == "__main__":

	# Argument Parser.
	parser = argparse.ArgumentParser()
	parser.add_argument( '--input' , help='Input network capture.' , required=True , \
		dest='input' )
	parser.add_argument( '--output' , help='Output network capture.' , required=True , \
		dest='output' )
	args = parser.parse_args()
	
	# Anonimize.
	Anonimize( input=args.input , output=args.output ).run()
	
