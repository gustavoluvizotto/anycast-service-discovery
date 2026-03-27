# Artifacts of the paper "A Deep Dive on Deployment Strategies of Services Provisioned using Anycast"

Welcome to the software artifacts of the aforementioned paper. This repository provides resources needed to examine and reproduce our work.

Paper reference: ```under peer-review``` -- link will follow upon publication.

## Project structure

This is the research project to investigate the operational strategies and services on anycast prefixes.

The artifacts are divided as follows:

common/generic:

- ``census_helper.py``: helper functions for LACeS census.
- ``requirements.txt``: python modules used.
- ``setup_dev.sh``: set up development environment.

Analysis related files:
- ``analysis/services_notebooks/measurements_analysis.ipynb``: The main services analysis. Ignore the sections that contains ``UNUSED`` from this notebook.
- ``analysis/services_notebooks/openintel_analysis.ipynb``: The main OpenINTEL analysis. This notebook is used in the ``Service Discovery`` section, DNS part. Ignore the sections in this notebook that contains ``UNUSED``.
- ``analysis/services_notebooks/*.csv``: The .csv files are intermediary output or used as input for the analysis notebooks under the directory ``analysis/services_notebooks``.

Measurement related files:
- ``run_pipeline_all_ports.sh``: Run the scanning pipeline (without ZGrab2 -- see below). The pipeline can run UDP and TCP ports. UDP ports configured: 53, 123, 443 and 853. TCP ports are anything else. Port 443 is configured to run both TCP and UDP. The ports are taken from ``measurements/input/lzr_ports.txt``.
- ``run_zgrab.sh``: Script to run ZGrab2.
- ``input/zgrab/zgrab_config.ini``: Instrumentation of scanner module and parameters to use with ZGrab2.
- ``input/zmap/dns_53.pkt``: The DNS UDP probe extracted from [ZMap UDP probes](https://github.com/zmap/zmap/tree/main/examples/udp-probes)
- ``input/zmap/ntp_123.pkt``: The NTP UDP probe extracted from [ZMap UDP probes](https://github.com/zmap/zmap/tree/main/examples/udp-probes)
- ``input/zmap/initial_qscanner_1a1a1a1a.pkt``: This file is **MANDATORY** to run QUIC scans. Please check [this page](https://quicimc.github.io/) on how to obtain this file.
- ``lzr_port_handshake.py``: Python file that provides the handshake (in order) to be used by LZR given a port number. This file also creates the ``measurements/input/lzr_ports.txt`` file that is required for scanning.
- ``measurements/docker-compose.yml``: The compose file necessary to run the measurement pipeline. The services we use in this compose are zmap, lzr and zgrab. However, there are still other tools that might be interesting for you;
- ``Dockerfile.*``: Docker files necessary to create the images mentioned in the compose file.
- ``monitor_if.sh``: Monitor a linux interface. Useful to check whether you are sending/receiving too much traffic while measurements.
- ``upload_*.sh``: Scripts to upload the measurement data to the University's data center. These scripts are not necessary. Please update them to upload the measurement data to the destination you find best.

### Safe to ignore

There are a few files in this repository that did not generate output to the paper.
Hence, they are present only for archival purposes.
Files that are not mentioned above can be safely ignored.
In the notebooks, it is also safe to ignore cells under sections that contain ``UNUSED`` keyword.

## Requirements

We used 2 different environments to process and analyze the data set.
The cluster environment and the local environment.

The cluster environment runs in a Spark cluster, with fine-tuned configurations.
The cluster is capable to retrieve and process data from OpenINTEL, and save intermediate data to the University's data center.
For OpenINTEL data access, we advise contact ``https://openintel.nl/contact/``.
You **do not** need access to the University data center.
You can modify all ``output`` paths and save to your own setup.

The local environment runs with python virtual environment. 
The local environment is a MacOS 26.4, with 8 cores and 16GB of RAM (any regular modern PC should do).

The cluster :

- Spark version 3.5.3
- Python 3.10.17 | packaged by conda-forge
- packages under ``external_packages`` directory
- OpenINTEL data (check on ``openintel.nl``)
- the data set archived in Zenodo

## Usage

To reproduce this work, we advise running first the ``analysis/services_notebooks/measurements_analysis.ipynb``, ``analysis/services_notebooks/openintel_analysis.ipynb`` and ... notebooks.

You can also ignore sections of the notebooks that has the keyword ``UNUSED``.
They are present only for archival purposes

## Data set

Publicly available when the paper becomes public too.
[DOI: xx.xxx/zenodo.xxxxxx](missing-url)

## Contact

For further information, contact:

- [rhendriks](https://github.com/rhendriks)
- [gustavoluvizotto](https://github.com/gustavoluvizotto)

## Acknowledgment

- OpenINTEL project
- CATRIN project (NWA.1215.18.003)

## License

MIT License
