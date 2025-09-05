# Global Tech Layoffs Analysis (2020–2023)

## Project Background
This project explores global tech layoffs from 2020 to 2023 using SQL. The dataset spans the COVID-19 pandemic, economic slowdown, and post-pandemic corrections, providing insights into how companies responded during a turbulent period.  

The analysis focuses on uncovering trends in layoffs by company, industry, country, and funding stage through descriptive and exploratory techniques.


## Skills & Tools
- SQL (MySQL Workbench) → Data cleaning, transformations, EDA  
- Data Cleaning → Handling duplicates, nulls, formatting, schema optimization  
- Exploratory Data Analysis → Trends, time-series, funding impact  


## Objectives
- Database Setup → Load raw layoffs dataset into MySQL and create staging/final tables  
- Data Cleaning → Remove duplicates, standardize text fields, format dates, and handle null values  
- Exploratory Data Analysis (EDA) → Perform queries to explore layoffs by company, country, industry, and time  


## SQL Scripts
- [Data Cleaning SQL Script](https://github.com/nikhitha-insights/global-tech-layoffs-analysis/blob/main/sql_scripts/01_data_cleaning.sql)  
- [Exploratory SQL Queries](https://github.com/nikhitha-insights/global-tech-layoffs-analysis/blob/main/sql_scripts/02_eda.sql)  


## Data Structure & Initial Checks
The dataset comes from the [Layoffs 2022 Dataset on Kaggle](https://www.kaggle.com/datasets/swaptr/layoffs-2022).  
Analysis was conducted on a staging table (`layoffs_staging2`) to preserve the original raw data while working on a cleaned version.

**Main Table Columns**
- Company name  
- Location & Country  
- Industry  
- Total employees laid off  
- Percentage laid off  
- Date  
- Funding amount (in millions)  
- Funding stage  

**Initial Checks**
- Removed duplicate records (using ROW_NUMBER())  
- Checked for missing values and inconsistent entries in key fields  
- Dropped misleading records (e.g., 0% layoffs)  
- Converted key fields to proper data types for accurate analysis  


## Exploratory Data Analysis (EDA)

**Key Insights**
- **Dataset Size**: 1,995 layoff events (2020–2023)  
- **Peak Layoff Month**: Jan 2023 → 80,000+ employees laid off  
- **Worst Quarters**: Q4 2022 & Q1 2023 → 125,000+ layoffs, peak of post-pandemic corrections  
- **Top Company**: Amazon (highest cumulative layoffs)  
- **Repeat Layoffs**: Some firms had up to 6 separate events  
- **Country Impact**: United States dominated, with layoffs several times higher than other countries  
- **Industry Impact**: Customer services, retail, and transportation most affected  
- **Full Shutdowns**: 115 companies laid off 100% of their workforce  
- **Funding Effect:**  
  High-funded firms (> $200M) shed the most jobs in absolute numbers but at smaller percentages while,  
   Low-funded firms (< $50M) cut 40%+ of staff on average.  
    Layoffs occurred across early-stage, growth, late-stage, and post-IPO companies  


## Conclusion
This exploratory analysis uncovers key patterns in global tech layoffs, including peak periods, most affected industries and countries, repeat layoffs, and funding-stage effects. The insights provide a clear view of workforce reduction trends in the tech sector from 2020 to 2023.





