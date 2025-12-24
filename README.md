# rk.six.sigma: Advanced Industrial Statistics & Six Sigma for RKWard

![Version](https://img.shields.io/badge/Version-0.0.1-orange)
![License](https://img.shields.io/badge/License-GPLv3-blue.svg)
![AI Assistance](https://img.shields.io/badge/Created%20with-Gemini-4E86F8)

**rk.six.sigma** is an external plug-in for [RKWard](https://rkward.kde.org/) designed to bridge the gap between open-source R statistics and commercial quality control software like Minitab or Bluesky Statistics. It provides a user-friendly GUI for performing Measurement System Analysis (MSA) and Process Capability studies, leveraging the power of the `SixSigma`, `irr`, and `MASS` packages.

## Features

### 1. Measurement System Analysis (MSA)
*   **Gage R&R (Crossed):** 
    *   Performs ANOVA-based Gage Repeatability and Reproducibility studies.
    *   Outputs detailed tables for Variance Components, ANOVA, and Study Variation ($%StudyVar$).
    *   Generates standard R&R plots (Components of Variation, R Chart, Xbar Chart, Interaction plots).
*   **Attribute Agreement Analysis:**
    *   Calculates **Fleiss' Kappa** for multiple raters evaluating multiple samples.
    *   Handles data reshaping automatically: Input data in "Long" format (Subject, Rater, Result), and the plugin converts it to the required matrix format internally.
    *   Provides interpretation guidelines for Kappa values.

### 2. Process Capability Analysis
*   **Normal Data:** Calculates standard indices ($C_p, C_{pk}, P_p, P_{pk}$) using the `SixSigma` package.
*   **Non-Normal Data:** 
    *   Supports **Weibull**, **Lognormal**, and **Exponential** distributions.
    *   Fits distributions using Maximum Likelihood Estimation (`MASS::fitdistr`).
    *   Calculates $P_p$ and $P_{pk}$ using the **ISO Quantile Method** (equivalent to Minitab's non-normal capability).
    *   **Visualization:** Plots histograms with the fitted density curve and specification limits, dynamically scaled to ensure the curve is not cut off.

### 3. User Experience
*   **HTML Tables:** All numerical results are formatted as HTML tables (`rk.results`), making them easy to copy and paste into spreadsheet software (Excel, LibreOffice).
*   **Object Saving:** Options to save the internal R objects (ANOVA lists, Fit objects) to the workspace for advanced post-hoc analysis.

## Dependencies

This plugin relies on the following R packages:
*   `SixSigma`
*   `irr`
*   `MASS`
*   `rkwarddev` (for development/building)

## Installation

### Installing from GitHub (Recommended)
You can install the latest version directly from GitHub using the `devtools` or `remotes` package in R:

First run:

```r
library(devtools) # or library(remotes)
install_github("AlfCano/rk.six.sigma")
```

Then restart RKWard.

## Usage Guide

The plugin adds a new entry to the main menu under:
**Analysis > Industrial Stats > Six Sigma**

### Example 1: Gage R&R (Crossed)
**Scenario:** You want to validate a measurement system where 3 operators measure 10 parts, 3 times each.

1.  **Load Data:** Use the built-in dataset from the SixSigma package.
    ```r
    data("ss.data.rr", package = "SixSigma")
    ```
2.  Navigate to **Analysis > Industrial Stats > Six Sigma > Gage R and R**.
3.  **Study Dataframe:** Select `ss.data.rr`.
4.  **Measurement:** Select `time` (expand dataframe to see columns).
5.  **Part ID:** Select `prototype`.
6.  **Operator:** Select `operator`.
7.  **Settings:** Keep Sigma at `6`.
8.  **Save Result Object:** Enter `my_gage_result`.
9.  Click **Submit**.
    *   *Output:* Check the "Variance Components" table to see if `%Contribution` (Total Gage R&R) is acceptable (< 10% is ideal).

### Example 2: Process Capability (Weibull)
**Scenario:** You have process data that is skewed (time-to-failure) and want to calculate capability against an upper limit of 100.

1.  **Generate Data:**
    ```r
    set.seed(123)
    my_data <- rweibull(100, shape=2, scale=50)
    ```
2.  Navigate to **Analysis > Industrial Stats > Six Sigma > Process Capability**.
3.  **Measurement Data:** Select `my_data`.
4.  **Specifications:**
    *   **LSL:** `10`
    *   **USL:** `100`
5.  **Distribution:** Select **Weibull**.
6.  **Preview:** Verify the curve fits the histogram bars.
7.  Click **Submit**.
    *   *Output:* Look for the "Capability Indices (Quantile Method)" table. $P_{pk}$ values > 1.33 indicate a capable process.

### Example 3: Attribute Agreement
**Scenario:** 3 Appraisers rate 5 samples as Pass (1) or Fail (0).

1.  **Create Data:**
    ```r
    attr_df <- data.frame(
      Sample = rep(1:5, 3),
      Appraiser = rep(c("A","B","C"), each=5),
      Rating = c(1,1,0,0,1, 1,0,0,0,1, 1,1,1,0,1)
    )
    ```
2.  Navigate to **Analysis > Industrial Stats > Six Sigma > Attribute Agreement**.
3.  **Dataframe:** Select `attr_df`.
4.  **Sample ID:** Select `Sample`.
5.  **Appraiser:** Select `Appraiser`.
6.  **Rating:** Select `Rating`.
7.  Click **Submit**.
    *   *Output:* Fleiss' Kappa will be displayed. A value > 0.75 indicates excellent agreement.

## Author
**Alfonso Cano**  
Benemérita Universidad Autónoma de Puebla  
License: GPL (>= 3)

---
*This plugin was developed with the assistance of **Gemini**, a large language model by Google.*
