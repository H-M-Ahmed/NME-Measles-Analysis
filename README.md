# NME-Measles-Analysis

## Overview

This repository contains the county-level analytic dataset, data dictionary, and R code used for the analyses reported in the accompanying manuscript. Each row of the analytic dataset represents one US county or county equivalent. Counties are identified using 5-digit Federal Information Processing Standards (FIPS) codes.

## Repository Contents

- `Data.xlsx`: County-level analytic dataset and variable dictionary.
- `Statistical_Analysis_Code.R`: R code used for data preparation and the primary statistical analyses.
- `README.md`: Description of the repository contents and instructions for reproducing the analyses.

## Reproducing the Analyses

1. Download `Data.xlsx` and `Statistical_Analysis_Code.R`.
2. Place both files in the same directory.
3. Set the R working directory to that folder.
4. Install the packages listed in the R script if they are not already installed.
5. Run `Statistical_Analysis_Code.R` from beginning to end.

The analysis was conducted using **R version 4.5.2** on Windows 10. The R script contains the package versions and complete session information for the original analysis environment.

## Data Preparation

The R script creates the derived variables used in the analyses, including transformed covariates, the metropolitan-status indicator, the outbreak indicator, and the population offset. Analyses are restricted to observations with complete data for all variables included in the applicable models.

For the primary occurrence analysis, counties with **3 or more confirmed measles cases** were classified as meeting the outbreak proxy, while counties with 0 to 2 cases were retained as the comparison group. The secondary case-burden analysis was restricted to counties meeting the outbreak proxy. The natural logarithm of county population was used as an offset in the negative binomial component of the two-part analysis.

## Data Sources

The analytic dataset integrates information from publicly available sources, including the Area Health Resources Files, the Johns Hopkins University measles tracker, the MIT Election Data and Science Lab, and other sources described in the manuscript and data dictionary. Users should consult and cite the original data sources when reusing these data.

MMR coverage primarily represented kindergarten-entry children; source definitions varied somewhat across states, as described in the manuscript and supplementary methods.

## Data Dictionary

| Variable name | Description | Notes |
|---|---|---|
| **Identifiers** |  |  |
| `FIPS` | 5-digit Federal Information Processing Standards (FIPS) county code | Unique county identifier used to merge county-level data across data sources |
| `County` | County name |  |
| `State` | 2-letter US state abbreviation |  |
| **Vaccination and Measles Variables** |  |  |
| `MMR_Coverage_Prop` | County-level measles, mumps, and rubella (MMR) vaccination coverage, expressed as a proportion | Coverage primarily represented kindergarten-entry children; see the manuscript and supplementary methods for state-specific definitions |
| `Exemption_Pct` | County-level nonmedical vaccination exemption prevalence (%) | Percentage of children with a nonmedical vaccination exemption |
| `Cases_2025` | Number of confirmed measles cases reported in the county during 2025 | Obtained from the Johns Hopkins University measles tracker |
| **Demographic Characteristics** |  |  |
| `popn_est_23` | County population estimate, 2023 | Obtained from the 2024-2025 Area Health Resources Files (AHRF), `AHRF2025pop`; log-transformed in models because of a skewed distribution |
| `forgn_born_popn_pct_23` | Foreign-born population as a percentage of the total county population, 2023 | Obtained from AHRF 2024-2025, `AHRF2025pop`; log-transformed in the models because of a skewed distribution |
| **Geographic Characteristics** |  |  |
| `RUCC_2023` | 2023 Rural-Urban Continuum Code (RUCC) for the county | Original 9-category RUCC classification was collapsed into a binary variable: metropolitan (RUCC 1-3) vs nonmetropolitan (RUCC 4-9) |
| `popn_densty_per_squr_mi_20` | County population density, measured as persons per square mile, 2020 | Obtained from AHRF 2024-2025, `AHRF2025env`; log-transformed in the models because of a skewed distribution |
| **Socioeconomic Characteristics** |  |  |
| `pers_noins_lt65_pct_22` | Percentage of county residents younger than 65 years without health insurance, 2022 | Obtained from AHRF 2024-2025, `AHRF2025pop` |
| `pers_4yrs_collg_ge25_pct_23` | Percentage of county residents aged 25 years or older who completed 4 or more years of college, 2023 | Obtained from AHRF 2024-2025, `AHRF2025pop` |
| **Political Characteristic** |  |  |
| `gop_vote_share_pct_24` | Republican presidential candidate's share of the county-level vote in the 2024 US presidential election (%) | Obtained from the MIT Election Data and Science Lab |
| **Healthcare Access** |  |  |
| `phys_nf_prim_care_pc_exc_rsdt_23` | Nonfederal primary care physicians per 100,000 population, excluding residents, 2023 | Obtained from AHRF 2024-2025, `AHRF2025hp`; log-transformed in the models because of a skewed distribution |

## Citation

Users of these data or code should cite the accompanying manuscript and the original data sources. The complete manuscript citation will be added here once available.

## Contact

For questions or further information regarding the dataset or analysis code, contact Hafiz M. Ahmed at h.m.ahmed5077@gmail.com.
