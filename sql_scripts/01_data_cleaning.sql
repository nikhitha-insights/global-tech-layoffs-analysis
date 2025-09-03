-- SQL Project: Data Cleaning - Global tech layoffs dataset

-- Dataset source: https://www.kaggle.com/datasets/swaptr/layoffs-2022

-- Step 1: Create a staging table to preserve raw data
CREATE TABLE world_layoffs.layoffs_staging 
LIKE world_layoffs.layoffs;

INSERT INTO world_layoffs.layoffs_staging
SELECT * FROM world_layoffs.layoffs;


-- Step 2: Remove Duplicates
-- Initial duplicate check using 4 key columns
SELECT company, industry, total_laid_off, `date`,
       ROW_NUMBER() OVER (PARTITION BY company, industry, total_laid_off, `date`) AS row_num
FROM world_layoffs.layoffs_staging;

-- Final duplicate check using all columns
SELECT *
FROM (
  SELECT *,
         ROW_NUMBER() OVER (
           PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
         ) AS row_num
  FROM world_layoffs.layoffs_staging
) duplicates
WHERE row_num > 1;

-- MySQL does not allow DELETE directly from a CTE, so this query will not work:
WITH DELETE_CTE AS 
(
SELECT *
FROM (
	SELECT company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions,
		ROW_NUMBER() OVER (
			PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions
			) AS row_num
	FROM 
		world_layoffs.layoffs_staging
) duplicates
WHERE 
	row_num > 1
)

DELETE
FROM DELETE_CTE
; 
-- Instead, use an approach with a helper column and second staging table
-- Create staging2 table with row_num
CREATE TABLE world_layoffs.layoffs_staging2 (
  company TEXT,
  location TEXT,
  industry TEXT,
  total_laid_off INT,
  percentage_laid_off TEXT,
  `date` TEXT,
  stage TEXT,
  country TEXT,
  funds_raised_millions INT,
  row_num INT
);

-- Insert data with row numbers
INSERT INTO `world_layoffs`.`layoffs_staging2`
(`company`,
`location`,
`industry`,
`total_laid_off`,
`percentage_laid_off`,
`date`,
`stage`,
`country`,
`funds_raised_millions`,
`row_num`)
SELECT `company`,
`location`,
`industry`,
`total_laid_off`,
`percentage_laid_off`,
`date`,
`stage`,
`country`,
`funds_raised_millions`,
		ROW_NUMBER() OVER (
			PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions
			) AS row_num
	FROM 
		world_layoffs.layoffs_staging;

-- Delete duplicates (keep only row_num = 1)
DELETE FROM world_layoffs.layoffs_staging2
WHERE row_num >= 2;


-- Step 3: Standardize Data
-- 3.1 Clean null and blank industry values
-- Identify blank or NULL industries
SELECT *
FROM world_layoffs.layoffs_staging2
WHERE industry IS NULL
OR industry = ''
ORDER BY industry;

-- Convert empty strings to NULLs
UPDATE world_layoffs.layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- Fill missing industry values using matching company names
UPDATE world_layoffs.layoffs_staging2 t1
JOIN world_layoffs.layoffs_staging2 t2
  ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL AND t2.industry IS NOT NULL;

-- 3.2 Standardize inconsistent values (e.g., Crypto variants)
UPDATE world_layoffs.layoffs_staging2
SET industry = 'Crypto'
WHERE industry IN ('Crypto Currency', 'CryptoCurrency');

-- 3.3 Standardize country names 
-- Clean trailing characters in country values (e.g., "United States.")
UPDATE world_layoffs.layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country);


-- STEP 4: Format Date Column to Proper Date Type
-- Convert string dates from MM/DD/YYYY to proper MySQL DATE type
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;


-- Step 5: Handle nulls and incorrect values
-- 5.1  Review NULLs in important numeric fields
-- Leave NULLs in total_laid_off, percentage_laid_off, and funds_raised_millions for now
-- Delete records missing both key numeric values
DELETE FROM world_layoffs.layoffs_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

 -- Fix misleading percentage_laid_off = 0 values
 SELECT *
 FROM world_layoffs.layoffs_staging2
 WHERE total_laid_off>0 and percentage_laid_off =0;
 -- well this is incorrect and leads to misleading analysis so will set percentage_laid_off to null 
 UPDATE world_layoffs.layoffs_staging2
 SET percentage_laid_off = NULL 
 WHERE total_laid_off>0 and percentage_laid_off =0;

-- Step 6: Final Cleanup and Optimization
ALTER TABLE world_layoffs.layoffs_staging2
DROP COLUMN row_num;

-- schema Optimization
-- good i think for data quality, performance, and future-proofing.
 ALTER TABLE world_layoffs.layoffs_staging2
MODIFY company VARCHAR(50),
MODIFY location VARCHAR(50),
MODIFY industry VARCHAR(50),
MODIFY percentage_laid_off decimal(5,4),
MODIFY stage VARCHAR(50),
MODIFY country VARCHAR(50),
MODIFY funds_raised_millions INT;

