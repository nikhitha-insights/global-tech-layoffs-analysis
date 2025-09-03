-- Exploratory Data Analysis on Global Tech Layoffs

-- Data Overview
SELECT 
    COUNT(*) AS total_rows,
    MIN(`date`) AS min_date,
    MAX(`date`) AS max_date
FROM layoffs_staging2;
-- Dataset contains 1995 rows and spans from 2020 to 2023, covering the COVID-19 pandemic and its aftermath.
-- It captures layoff trends influenced by global disruptions, remote work shifts, economic slowdowns and post-pandemic corrections in the tech industry.
-- The analysis provides insights into how companies responded to one of the most turbulent periods in recent history.


-- HIGH-IMPACT LAYOFF EVENTS

-- companies that had the biggest one-time layoff events
SELECT company,`date`, total_laid_off 
FROM layoffs_staging2
ORDER BY total_laid_off DESC;
-- Insight: Big tech companies like Google and Meta show higher layoffs, likely due to their bigger workforce.

-- Top 10 companies with the most total layoffs (all- time)
SELECT company, SUM(total_laid_off) AS total_layoffs FROM layoffs_staging2
GROUP BY company
ORDER BY total_layoffs DESC
LIMIT 10;
-- Insight: Amazon tops the list.

-- Companies with multiple layoff events (repeat layoffs detection)
SELECT company, COUNT(*) AS layoff_events
FROM layoffs
GROUP BY company
HAVING COUNT(*) > 1
ORDER BY layoff_events DESC;
-- Some companies had up to 6 separate layoff events.



-- COUNTRY & INDUSTRY ANALYSIS
-- Layoffs by Country
SELECT country, SUM(total_laid_off) AS total_laid_off FROM layoffs_staging2
GROUP BY country
ORDER BY total_laid_off DESC;
-- Insight: The United States leads significantly, with layoffs several times higher than other countries. 

-- Top 10 Locations by Layoffs
SELECT location, SUM(total_laid_off) as total_laid_off
 FROM layoffs_staging2
GROUP BY location
ORDER BY total_laid_off DESC
LIMIT 10;

-- Layoffs by Industry
SELECT industry, SUM(total_laid_off) AS total_laid_off FROM layoffs_staging2
GROUP BY industry
ORDER BY total_laid_off DESC;
-- Insight: Industries like Customer, retail, transporation had the most layoffs.


-- TIME-BASED TRENDS
-- Monthly Layoff Trends
SELECT DATE_FORMAT(date, '%Y-%m') AS month, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY month
ORDER BY total_laid_off desc;
-- Insight: January 2023 shows the highest layoffs (over 80,000) followed by December 2022.

-- Quarterly Layoffs  with Avg Funding
SELECT CONCAT(YEAR(date), '-Q', QUARTER(date)) AS quarter,
       SUM(total_laid_off) AS total_laid_off,
       COUNT(*) AS events,
       AVG(funds_raised_millions) AS avg_funding
FROM layoffs_staging2
GROUP BY quarter
ORDER BY total_laid_off desc;
-- Insight: Layoffs spike in Q1 of 2023 and Q4 of 2022


-- 100% Workforce layoffs
-- Companies with 100% Workforce Laid Off
SELECT company, MAX(percentage_laid_off) AS max_percentage
FROM layoffs_staging2
GROUP BY company
HAVING max_percentage = 1
ORDER BY company;

-- Count of Companies with 100% Layoffs
SELECT COUNT(*) AS company_count
FROM (
    SELECT company, MAX(percentage_laid_off) AS max_percentage
    FROM layoffs_staging2
    GROUP BY company
    HAVING max_percentage = 1
) AS t;
-- Insight: 115 companies with 100% workforce laid off


-- FUNDING & LAYOFF RELATIONSHIPS
-- Layoffs vs. Funding Bracket
SELECT 
  CASE 
    WHEN funds_raised_millions < 50 THEN 'Low Funding'
    WHEN funds_raised_millions BETWEEN 50 AND 200 THEN 'Mid Funding'
    ELSE 'High Funding'
  END AS funding_bracket,
  COUNT(*) AS companies,
  SUM(total_laid_off) AS total_laid_off,
  AVG(percentage_laid_off) AS avg_percentage_laid_off
FROM layoffs_staging2
GROUP BY funding_bracket
ORDER BY total_laid_off DESC;
-- Insight: High funding companies shed the most jobs in absolute numbers but kept layoffs proportionally smaller, 
-- while low-funding firms faced severe workforce reductions — cutting on average over 40% of staff


-- Companies with 100% Layoffs Ordered by Funding
SELECT * FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;
-- Insight: Some well-funded companies shut down completely (over $2.4B funds raised).


-- Top companies per year
-- Top 3 Companies by Layoffs per Year
WITH Company_Year AS (
  SELECT company, YEAR(date) AS years, SUM(total_laid_off) AS total_laid_off
  FROM layoffs_staging2
  GROUP BY company, YEAR(date)
),
Company_Year_Rank AS (
  SELECT company, years, total_laid_off, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
  FROM Company_Year
)
SELECT company, years, total_laid_off, ranking
FROM Company_Year_Rank
WHERE ranking <= 3
AND years IS NOT NULL
ORDER BY years ASC, total_laid_off DESC;
-- Insight: Different companies top each year, suggesting no single firm dominated layoffs repeatedly.


-- FUNDING STAGE ANALYSIS
-- Layoffs by Funding Stage
SELECT stage, SUM(total_laid_off) AS total_laid_off FROM layoffs_staging2
GROUP BY stage
ORDER BY total_laid_off DESC;

-- Categorized Funding Stage Analysis
SELECT 
  CASE 
    WHEN stage IN ('Seed', 'Series A') THEN 'Early Stage'
    WHEN stage IN ('Series B', 'Series C') THEN 'Growth Stage'
    WHEN stage IN ('Series D', 'Series E', 'Series F', 'Series G', 'Series H', 
                   'Series I', 'Series J', 'Post-IPO', 'Private Equity', 'Private') THEN 'Late Stage'
    WHEN stage IN ('Acquired', 'Subsidiary') THEN 'Exit/Other'
    WHEN stage = 'Unknown' THEN 'Unknown'
    ELSE 'Unclassified'
  END AS funding_stage_type,
  COUNT(*) AS companies,
  SUM(total_laid_off) AS total_laid_off,
  AVG(percentage_laid_off) AS avg_percentage_laid_off
FROM layoffs_staging2
GROUP BY funding_stage_type
ORDER BY total_laid_off DESC;
-- Insight: Layoffs are not confined to early-stage startups; late-stage and post-IPO firms also face cutbacks.






