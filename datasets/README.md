# Wi-Fi Datasets

Throughout the years, we performed surveys across four countries in three continents.

We present an overview of our collected datasets, and the number of unique networks within them, per frequency band.

In total, our datasets cover 440,259 networks, of which 327,119 are unique.

Our survey was performed predominantly residential areas.
If applicable, we split datasets per neighborhood (for example, Boston). 

## Datasets

We collected various datasets between October 2019 and October 2023, containing beacon and probe response frames.

For each frequence band, we list the number of unique networks, which is based on the network's BSSID MAC address.

| Date | CC | Region | 2.4 GHz | 5 GHz | Total |
| :--- | :- | :----- | ------: | ----: | ----: |
| October 2019 | US | Boston (Back Bay) | 25,405 | 13,404 | 38,809 |
| October 2019 | US | Boston (Fenway) | 9,992 | 6,579 | 16,571 |
| October 2019 | US | Providence | 7,425 | 3,255 | 10,680 |
| October 2019 | AE | Abu Dhabi | 16,503 | 7,584 | 24,087 |
| October 2019 | BE | Limburg | 4,051 | 1,328 | 5,379 |
| October 2020 | US | Boston (Back Bay) | 18,892 | 21,637 | 40,529 |
| October 2020 | AE | Abu Dhabi | 20,447 | 11,867 | 32,314 |
| October 2020 | BE | Limburg (Hasselt) | 19,267 | 12,099 | 31,366 |
| October 2020 | CH | Zürich | 10,775 | 11,721 | 22,496 |
| May 2021 | BE | Limburg (Hasselt) | 17,647 | 10,259 | 27,906 |
| October 2021 | US | Boston (Back Bay) | 11,822 | 28,938 | 40,760 |
| October 2021 | US | Boston (Fenway) | 11,062 | 17,138 | 28,200 |
| December 2021 | BE | Limburg (Hasselt) | 16,796 | 10,332 | 27,128 |
| October 2022 | BE | Limburg (Hasselt) | 16,979 | 10,312 | 27,291 |
| October 2023 | US | Boston (Back Bay) | 17,498 | 22,729 | 40,227 |
| October 2023 | US | Boston (Fenway) | 11,426 | 15,090 | 26,516 |

<sup> Number of unique networks in our surveys, listed per their respective date, region, and frequency band.

## Anonymization

We anonymize user-specific information that would otherwise enable tracking or localization, and limit sensitive information leakage of access points.

In order to anonymize the datasets, we apply the following rules:
- We remove duplicate beacon and probe response frames, keeping one per unique network.
- We remove RadioTap and PPI headers, except for its channel information.
- We anonymize the three least significant bytes of each MAC address, keeping the Organizationally Unique Identifier (OUI).
- We anonymize the destination MAC address of probe response frames, as it identifies client stations.
- We map each unique SSID to a pseudonym "SSID-_N_" where _N_ is an incremental number.

Following these rules, we limit the potential leakage of sensitive sensor data in beacon frames, keep vendor-related information while preserving user privacy, and allow one to measure how many access points broadcast a specific anonymized SSID.

## Code

#### Pre-Requirements
```
apt-get install python3-venv tshark
```

#### Python Virtual Environment

We provide a virtual Python environment to manage all code dependencies.

The virtual environment can be created using the following script, which additionally installs all [requirements](requirements.txt).

```
./pysetup.sh
```

Then, before every usage, the environment needs to be activated:
```
source venv/bin/activate
```

Note you can leave the virtual environment using:
```
deactivate
```

#### Anonymization

We provide a tool to apply the anonymization rules on any wireless network capture, and can be executed as follows:
```
./anonimize.py --input dataset.pcapng --output anonimized.pcapng
```

A quick sanity check on the anonimization procedure can be done by counting the number of unique BSSID and SSIDs.

We provide a tool for this purpose, and can be executed as follows:
```
./anonimize-sanity-check.sh dataset.pcapng anonimized.pcapng
```

## Publication of Datasets

We make all our anonimized datasets available to other researchers upon request.

Please contact ```schepers.d``` at ```northeastern.edu``` for more information.
