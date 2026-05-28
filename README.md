# Aalborg University Geodesy Group Data Assimilation framework (AAUDA)

AAUDA is a Matlab-based framework designed to conduct land hydrological Data Assimilation (DA) experiments. Particularly, it includes scripts to assimilate satellite-based Terrestrial Water Storage (TWS) and Surface Soil Moisture (SSM) observations (retrievals). The current framework offers the following features:
* Spans various DA techniques belonging to the Ensemble Kalman Filter (EnKF) family, including the classical EnKF and the EnKF-Rescaling approach
* Includes different covariance localization techniques such as observation space localization and model space localization
* Offers the possibility to conduct DA experiments in different timescales, ranging daily to monthly.

The framework is currently coupled with the World-Wide Water Resources Assessment (W3RA) water balance model, which was originally developped by Albert van Dijk [[1]](https://awo.bom.gov.au/assets/notes/publications/Van_Dijk_AWRA05_TechReport3.pdf) [[2]](https://agupubs.onlinelibrary.wiley.com/doi/full/10.1002/wrcr.20251) and can be found in [this Dropbox folder](https://www.dropbox.com/scl/fo/b0hneugr9vao0rqm4oh86/AEPPU-QG6kgh9wTlIBgiwMQ?rlkey=q7ux08mitdghnoac3e4spwaev&e=2&dl=0).

> [!NOTE]
> **Repository in construction**
> 
> This repository is currently under development. The following features will be added in the following months:
> * SSM DA scripts
> * Multivariate TWS and SSM DA scripts
> * DA through the Ensemble Adjustment Kalman Filter (EAKF) approach
> * Model space mixed localization approach


## Documentation

The documentation for AAUDA can be found in the [GitHub project wiki](https://github.com/AAUGeodesyGroup/AAUDA/wiki).

## Installing the framework
The framework can be directly downloaded or cloned from this GitHub repository. The framework is designed to run in Matlab 2020b. A few Matlab Toolboxes might have to be installed to run specifical functionalities of the framework.

## Authorship, license and citation
This framework has been developped by Leire Retegui-Schiettekatte, with notable contributions of Maike Schumacher (monthly EnKF), Nooshin Mehrnegar (river routing model), Ehsan Forootan (EnKF-Rescaling approach), Manuela Girotto (mixed covariance localization approach), and Fan Yang (general DA implementation). The W3RA model was originally developped by Albert van Dijk.

The framework is licensed under a
[Creative Commons Attribution 4.0 International License][cc-by].
[![CC BY 4.0][cc-by-image]][cc-by]

The framework itself can be cited as:

* Retegui-Schiettekatte, L., 2026. AAUDA. [https://doi.org/10.6084/m9.figshare.31741930.v1](https://doi.org/10.6084/m9.figshare.31741930.v1)

Additionally, the usage of some features of the framework (e.g., W3RA model, river routing module or monthly EnKF) **requires additional citations**. Please visit the "Authorship, licence and citation" seciton of the [GitHub project wiki](https://github.com/AAUGeodesyGroup/AAUDA/wiki) for more information.

## Funding

The development of this framework was economically supported by the DANSk-LSM project granted by the Independent Research Fund Denmark (DFF, 10.46540/2035-00247B). The main author of the framework, Leire Retegui-Schiettekatte, was also supported by an EliteForsk travel grant from the Ministry of Higher Education and Science of Denmark.

<img height="137" alt="Independent Research Fund Denmark" src="https://github.com/user-attachments/assets/e03e6ca5-97e8-4bef-8731-c4a0d8f6985d" />


<img height="137" alt="Ministry of Higher Education and Science" src="https://github.com/user-attachments/assets/3071e53f-07f6-42a0-8164-ef61547398e5" />
<img height="137" alt="EliteForsk" src="https://github.com/user-attachments/assets/41b1cc42-ea8a-4bf6-a992-65cd683b8924" />


## Contact
For any queries, please contact [Leire Retegui-Schiettekatte](https://vbn.aau.dk/en/persons/leirears/).

<img width="416" height="110" alt="__AAU_LEFT_RGB_UK" src="https://github.com/user-attachments/assets/e69e813c-febf-41a4-8e80-25412b75f42a" />



[cc-by]: http://creativecommons.org/licenses/by/4.0/
[cc-by-image]: https://i.creativecommons.org/l/by/4.0/88x31.png
[cc-by-shield]: https://img.shields.io/badge/License-CC%20BY%204.0-lightgrey.svg
