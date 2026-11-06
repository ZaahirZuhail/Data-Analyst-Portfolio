-- Data Cleaning

SELECT * FROM my_layoffs_practice;

-- 1. Remove Duplicates
-- 2.Standardize the data
-- 3.Null Values or Blank Values
-- 4.Remove Any Coloums

CREATE TABLE layouff_staging
LIKE my_layoffs_practice;

SELECT * FROM layouff_staging;

INSERT layouff_staging 
SELECT * FROM my_layoffs_practice;

SELECT COUNT(*)
FROM my_layoffs_practice;

-- Remove Duplicates

CREATE TABLE layouff_staging2
LIKE layouff_staging;

ALTER TABLE layouff_staging2
ADD COLUMN row_num INT;

--  copy data with row numbers

INSERT INTO layouff_staging2
SELECT *,
ROW_NUMBER() OVER (
    PARTITION BY
        company,
        location,
        industry,
        total_laid_off,
        percentage_laid_off,
        `date`,
        stage,
        country,
        funds_raised_millions
) AS row_num
FROM layouff_staging;

-- Duplicate records check

SELECT *
FROM layouff_staging2
WHERE row_num > 1;

-- Duplicate records remove
SET SQL_SAFE_UPDATES = 0;
DELETE FROM layouff_staging2
WHERE row_num > 1;

-- varify
SELECT *
FROM layouff_staging2;

-- Standardize the Data

-- COMPANY
SELECT DISTINCT company
FROM layouff_staging2
ORDER BY company;

UPDATE layouff_staging2
SET company = TRIM(company);

-- INDUSTRY
SELECT DISTINCT industry
FROM layouff_staging2
ORDER BY industry;

UPDATE layouff_staging2
SET industry = TRIM(industry);

-- Converting empty values into Null
UPDATE layouff_staging2
SET industry = NULL
WHERE TRIM(industry) = '';

-- Filling the missing values with available industry values
UPDATE layouff_staging2 t1
JOIN layouff_staging2 t2
ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- Check those values
SELECT *
FROM layouff_staging2
WHERE industry IS NULL;

-- Location --
SELECT DISTINCT location
FROM layouff_staging2
ORDER BY location;

UPDATE layouff_staging2
SET location = TRIM(location);

-- Stage 
SELECT DISTINCT stage
FROM layouff_staging2
ORDER BY stage;

UPDATE layouff_staging2
SET stage = TRIM(stage);

UPDATE layouff_staging2
SET stage = NULL
WHERE TRIM(stage) = '';

-- Country
SELECT DISTINCT country
FROM layouff_staging2
ORDER BY country;

UPDATE layouff_staging2
SET country = TRIM(country);

-- Removing the full stop in the end of the country name
UPDATE layouff_staging2
SET country = TRIM(TRAILING '.' FROM country);

-- Check Again
SELECT DISTINCT country
FROM layouff_staging2
ORDER BY country;

-- Handle null values and Blanks
SELECT *
FROM layouff_staging2
WHERE total_laid_off IS NULL;

SELECT *
FROM layouff_staging2
WHERE percentage_laid_off IS NULL;

SELECT *
FROM layouff_staging2
WHERE funds_raised_millions IS NULL;

-- Standardize Date Format
SELECT DISTINCT `date`
FROM layouff_staging2
ORDER BY `date`;

-- Preview the different format Dates
SELECT
    `date`,
    CASE
        WHEN `date` REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
            THEN STR_TO_DATE(`date`, '%Y-%m-%d')
        WHEN `date` REGEXP '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}$'
            THEN STR_TO_DATE(`date`, '%m/%d/%Y')
        WHEN `date` REGEXP '^[0-9]{1,2}-[0-9]{1,2}-[0-9]{4}$'
            THEN STR_TO_DATE(`date`, '%d-%m-%Y')
        ELSE NULL
    END AS cleaned_date
FROM layouff_staging2;

-- Convert dates
UPDATE layouff_staging2
SET `date` = CASE
    WHEN `date` REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
        THEN STR_TO_DATE(`date`, '%Y-%m-%d')
    WHEN `date` REGEXP '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}$'
        THEN STR_TO_DATE(`date`, '%m/%d/%Y')
    WHEN `date` REGEXP '^[0-9]{1,2}-[0-9]{1,2}-[0-9]{4}$'
        THEN STR_TO_DATE(`date`, '%d-%m-%Y')
    ELSE NULL
END;

-- Changing column data type
ALTER TABLE layouff_staging2
MODIFY COLUMN `date` DATE;

-- Remove Unnecessary Rows
    -- Check the unnecessary rows
SELECT *
FROM layouff_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layouff_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Remove Unnecessary Column
ALTER TABLE layouff_staging2
DROP COLUMN row_num;

-- Final Cleaned Data
SELECT *
FROM layouff_staging2;

-- Total cleaned records
SELECT COUNT(*)
FROM layouff_staging2;

-- Duplicates Varification

SELECT
    company,
    location,
    industry,
    total_laid_off,
    percentage_laid_off,
    `date`,
    stage,
    country,
    funds_raised_millions,
    COUNT(*) AS duplicate_count
FROM layouff_staging2
GROUP BY
    company,
    location,
    industry,
    total_laid_off,
    percentage_laid_off,
    `date`,
    stage,
    country,
    funds_raised_millions
HAVING COUNT(*) > 1;