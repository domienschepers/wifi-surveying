# Wi-Fi Surveying

Over the years, we performed numerous surveys to contextualize or motivate research projects (for example, to estimate the number of vulnerable devices).
From our experience, we recommend a set of best practices on how to capture, analyze, and present the statistics of a survey.
As such, results can be interpreted, and compared to each other, in a more rigorous and accurate manner.

Furthermore,
- we provide a [tool to extract security statistics](tool), and present a detailed [overview of all statistics](statistics).
- we provide a [tool to anonimize datasets](datasets), and share anonimized [datasets](datasets) with other researchers upon request.
- we provide a [tool to wardrive on macOS](https://github.com/domienschepers/wifi-wardriving-macos) operating systems.

## Recommended Best Practices

We recommend the following best practices when surveying Wi-Fi networks.

* **Best Practice 1: Address the Methodology.**
In order to understand and interpret survey results, one must discuss the methodology and provide context for the performed survey.
Specifically, one must clarify when and how data is collected (for example, the frequency bands, location, passive or active data collection) in addition to any assumptions made during processing (for example, how unique networks are defined).

- **Best Practice 2: Preserve Privacy in Published Datasets.**
Prior to publication, one should consider the privacy risks in publishing the dataset (for example, which user-identifiable data is included).
The publisher can describe which privacy-sensitive information it aims to protect (for example, MAC addresses, SSIDs, sensor readings) and explain the actions taken to properly sanitize the dataset.

- **Best Practice 3: Survey Distinct Regions.**
Survey results can be impacted by the region in which they are conducted.
Therefore one must specify where the survey took place (for example, city, residential or commercial neighborhood).
To the extent possible, sufficient distinct regions must be surveyed to avoid any regional bias in the survey results (for example, regions in a different country or different ISP landscape).

- **Best Practice 4: Survey Appropriate Frequency Spectra.**
Based on a survey’s goals, one must consider the appropriate frequency spectra on which to collect data.
Survey results can then be presented for each spectrum, together with the amount of (unique) networks.

Depending on the survey purpose, it may not be required to, for example, collect data on both the 2.4 and 5 GHz spectrum.
Nevertheless, it is important to discuss this in the survey methodology as it is necessary to properly contextualize the resulting statistics, for example, supported standards, availability on commercial products, etc.

Furthermore, we note that when configuring the hardware setup for a survey, it is possible that no equal time is spent listening on each frequency band or channel.
Therefore, one must be aware that certain frequency bands or channels may be over-represented in a survey.
The challenge of surveying multiple frequency bands is further exacerbated since 5 GHz networks are harder to detect as the range in this frequency band is lower than in the 2.4 GHz band, and there are more 5 GHz channels to perform channel-hopping on.
As a result, it may lead to the collection of more 2.4 GHz networks, and therefore the impact of 5 GHz networks on the combined statistics is significantly reduced, further illustrating the importance of reporting statistics for each frequency band separately.

## Wi-Fi Statistics

We present security statistics on a fine-grained level, per year, region, and frequency band.

Statistics cover a variety of features such as Wi-Fi WPS, and detailed encryption and authentication mechanisms.

For more information, see [the detailed page on our security statistics](statistics).

#### Tool

We provide a tool to extract statistics from network captures containing beacon and probe response frames.

For more information, see [the detailed page on our security statistics tool](tool).

## Wi-Fi Datasets

We present our datasets covering more than 280,600 unique networks across four countries in three continents.

Additionally, we provide a tool to anonimize datasets.

For more information, see [the detailed page on our datasets](datasets).

## Publication

This work was published at ACM Conference on Security and Privacy in Wireless and Mobile Networks (WiSec '21):

- Let Numbers Tell the Tale: Measuring Security Trends in Wi-Fi Networks and Best Practices ([pdf](https://papers.mathyvanhoef.com/wisec2021.pdf), [acm](https://dl.acm.org/doi/10.1145/3448300.3468286))
