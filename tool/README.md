# Wi-Fi Statistics Tool

This tool extracts security statistics from network packet captures containing beacon and probe response frames.

In order to be representative, it is assumed the network packet capture contains only a single frame per unique network.

## Tool

Using ```statistics.sh```, one can extract security statistics from the network packet captures.

#### Pre-Requirements

This tool has the following pre-requirements:

- ```tshark```, the Wireshark Network Analyzer.

#### Usage

One can extract security statistics using one of the supported commands:

```
./statistics.sh -h
```
```
Usage: ./statistics.sh -r filename [-c command] [-f filter] [-w filename]

Options:
   [-h]                     Display this help message.
    -r filename             Read from a network capture file.
   [-c command]             Run a command to obtain certain statistics.
                            Supported: standards, frequency, encryption, pmf,
                            wps, hidden, mesh, and all (default).
   [-f filter]              Apply a global filter to all statistics.
                            Supported: open, encrypted, hidden, non-hidden,
                            mesh, non-mesh, 2ghz, and 5ghz.
   [-w filename]            Write filtered results to a new file.
```

Supported commands:
- ```standards```: Usage of Standards and Specifications.
- ```frequency```: Usage of Frequency Bands.
- ```encryption```: Usage of Encryption and Authentication and Key Management.
- ```pmf```: Usage of Wi-Fi Protected Management Frames.
- ```wps```: Usage of Wi-Fi Protected Setup.
- ```hidden```: Usage of (Non-)Hidden Networks.
- ```mesh```: Usage of (Non-)Mesh Networks.

Note multiple filters can be used using a ```+``` delimiter (for example, ```encrypted+2ghz```).

#### Example

For example, one can easily extract all statistics using the following command:

```
./statistics.sh -r example.pcapng
```
```
Analyzing <example.pcapng> with <200> frames...

Standards:
     197 =  98.50 %   (2005) IEEE 802.11e
     193 =  96.50 %   (2009) IEEE 802.11n
       0 =   0.00 %   (2009) IEEE 802.11w
      43 =  21.50 %   (2013) IEEE 802.11ac Wave 1
       0 =   0.00 %   (2016) IEEE 802.11ac Wave 2
       0 =   0.00 %   (2019) IEEE 802.11ax

Frequency:
     156 =  78.00 %   2.4 GHz Band
      44 =  22.00 %   5 GHz Band

Encryption and Key Management:
       4 =   2.00 %   Open
     196 =  98.00 %   Encrypted

      10 =   5.00 %   Pairwise Key (None)
       0 =   0.00 %   Pairwise Key (WEP)
      41 =  20.50 %   Pairwise Key (TKIP)
     190 =  95.00 %   Pairwise Key (CCMP)
       0 =   0.00 %   Pairwise Key (GCMP)

      10 =   5.00 %   Group Key (None)
       1 =   0.50 %   Group Key (WEP)
      40 =  20.00 %   Group Key (TKIP)
     149 =  74.50 %   Group Key (CCMP)
       0 =   0.00 %   Group Key (GCMP)

      10 =   5.00 %   Auth Key Management (None)
     172 =  86.00 %   Auth Key Management (PSK)
      18 =   9.00 %   Auth Key Management (EAP)
       0 =   0.00 %   Auth Key Management (SAE)

Protected Management Frames:
     190 =  95.00 %   MGMT Protection
       0 =   0.00 %   MGMT Protection Capable
       0 =   0.00 %   MGMT Protection Required

Wi-Fi Protected Setup:
       0 =   0.00 %   WPS (Not Configured)
      95 =  47.50 %   WPS (Configured)
      95 =  47.50 %   WPS (Any)

Hidden Networks:
      73 =  36.50 %   Hidden SSID
     127 =  63.50 %   Non-Hidden SSID

Mesh Networks:
       0 =   0.00 %   Mesh Networks
     200 = 100.00 %   Non-Mesh Networks
```
