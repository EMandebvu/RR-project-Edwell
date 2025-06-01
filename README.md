---
title: "CAPM Model Reproduction (Python → R)"
subtitle: "Financial Economics Project | [Reproducible Research]"
author: "Edwell B Mandebvu"
output: html_document
Source: Original Kaggle Notebook by Gaurav Dutt
---

**Source**: [Original Kaggle Notebook](https://www.kaggle.com/code/gauravduttakiit/capital-asset-pricing-model/notebook) by Gaurav Dutt

### **Project Overview**

#### Objective

Reproduce a Capital Asset Pricing Model (CAPM) implementation from Python to R, analyzing reproducibility challenges in financial econometrics.

------------------------------------------------------------------------

#### Key Components

-   Data cleaning and preprocessing
-   CAPM regression modeling
-   Portfolio return calculations
-   Statistical validation

#### Technical Stack

| Component     | Python            | R           |
|---------------|-------------------|-------------|
| Data Cleaning | `pandas`          | `tidyverse` |
| Modeling      | `statsmodels.OLS` | `lm()`      |
| Visualization | `seaborn`         | `ggplot2`   |

#### Repository Structure

```         
project-root/
├── data/
│ └── cleaned_data.csv # Processed dataset
├── code/
│ ├── original_python/ # Source implementation
│ └── rewritten_r/ # R translation
│ ├── analysis.qmd # Main Quarto document
│ └── functions.R # Helper functions
└── outputs/
├── plots/ # Visualization exports
└── tables/ # Statistical outputs
```

------------------------------------------------------------------------

#### Reproducibility Validation

To ensure the reproducibility of our CAPM implementation, please follow these steps:

1.  **Environment Setup**
    -   For Python, install required packages with:

        ``` bash
        pip install -r requirements.txt
        ```

    -   For R, install necessary packages (if not already installed) with:

        ``` r
        install.packages(c("tidyverse", "broom", "ggplot2"))
        ```

    -   Using consistent package versions is important to avoid discrepancies.
2.  **Data Consistency**
    -   Use the provided cleaned dataset `data/cleaned_returns.csv` to reproduce results exactly.
    -   Do not modify raw data unless changes are documented.
3.  **Run the Code**
    -   First, execute the Python scripts/notebooks in `code/original_python/` to reproduce the original CAPM results.
    -   Then run the R scripts in `code/rewritten_r/` for the translated analysis.
4.  **Output Comparison**
    -   Compare outputs such as regression coefficients (betas and alphas), summary statistics, and visualizations saved in the `outputs/` folder.
    -   Results between Python and R implementations should be closely aligned, demonstrating reproducibility.
5.  **Reporting Issues**
    -   If any discrepancies occur, please document and report them by opening an issue in this repository for efficient troubleshooting.

------------------------------------------------------------------------

#### 📚 Additional Notes

-   The Python code uses `pandas` for data handling, `statsmodels` for regression, and `seaborn` for plotting.
-   The R version leverages `tidyverse` for data wrangling, `lm()` for regression modeling, and `ggplot2` for visualization.
-   Both implementations aim to deliver equivalent CAPM analysis results and insights.
-   The cleaned dataset includes daily returns prepared for regression, ensuring comparability.
-   For comparison of results, refer to the QMD presentation (CAPM presentation).
