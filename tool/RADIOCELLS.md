# Wi-Fi Statistics Tool for Radiocells

This tool extracts security statistics from the now-inactive [Radiocells](https://radiocells.org/) community project.

## Tool

Using ```radiocells.sh```, one can extract security statistics from the databases.

#### Pre-Requirements

This tool has the following pre-requirements:

- ```sqlite3```, a command line interface for SQLite.

#### Usage

One can extract statistics using one of the supported commands:

```
./radiocells.sh -h
```
```
Usage: ./radiocells.sh -r filename [-c command]

Options:
   [-h]                     Display this help message.
    -r filename             Read from a database file.
   [-c command]             Run a command to obtain certain statistics.
                            Supported: frequency, encryption, wps, hidden,
                            and all (default).
```

Supported commands:
- ```frequency```: Usage of Frequency Bands.
- ```encryption```: Usage of Encryption and Authentication and Key Management.
- ```wps```: Usage of Wi-Fi Protected Setup.
- ```hidden```: Usage of Hidden Networks.

#### Example

For example, one can easily extract all statistics using the following command:

```
./radiocells.sh -r example.db
```
```
Analyzing <example.db> with <227> distinct records...

Frequency:
     166 =  73.13 %   2.4 GHz Band
      61 =  26.87 %   5 GHz Band

Encryption:
       1 =   0.44 %   WEP
      75 =  33.04 %   TKIP
     190 =  83.70 %   CCMP

Wi-Fi Protected Setup:
     110 =  48.46 %   WPS

Hidden Networks:
       7 =   3.08 %   Hidden SSID
```
