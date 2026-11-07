SELECT *
FROM layouff_staging2;

-- Top 5 laid off
SELECT company, total_laid_off
FROM layouff_staging
ORDER BY total_laid_off DESC
LIMIT 5;

-- Maximum layoff count
SELECT MAX(total_laid_off)
FROM layouff_staging2;

-- Percentage of Min and Max Laid off
SELECT
    MAX(percentage_laid_off),
    MIN(percentage_laid_off)
FROM layouff_staging2
WHERE percentage_laid_off IS NOT NULL;

-- 100% layoff Records
SELECT *
FROM layouff_staging2
WHERE percentage_laid_off = 1;

-- 100% layoff companies
SELECT *
FROM layouff_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- Companies wise top 10 layoff companies
SELECT
    company,
    SUM(total_laid_off) AS total_laid_off
FROM layouff_staging2
GROUP BY company
ORDER BY total_laid_off DESC
LIMIT 10;

-- Location wise Total layoff
SELECT
    location,
    SUM(total_laid_off) AS total_laid_off
FROM layouff_staging2
GROUP BY location
ORDER BY total_laid_off DESC
LIMIT 10;

-- Country wise total layoff
SELECT
    country,
    SUM(total_laid_off) AS total_laid_off
FROM layouff_staging2
GROUP BY country
ORDER BY total_laid_off DESC;

-- Yearly wise total layoff
SELECT
    YEAR(date) AS year,
    SUM(total_laid_off) AS total_laid_off
FROM layouff_staging2
GROUP BY YEAR(date)
ORDER BY year ASC;

-- Industry wise total layoff
SELECT
    industry,
    SUM(total_laid_off) AS total_laid_off
FROM layouff_staging2
GROUP BY industry
ORDER BY total_laid_off DESC;

-- Company stage wise total layoff
SELECT
    stage,
    SUM(total_laid_off) AS total_laid_off
FROM layouff_staging2
GROUP BY stage
ORDER BY total_laid_off DESC;

-- top 3 companies in every year wise layoff
WITH company_year AS (
    SELECT
        company,
        YEAR(date) AS years,
        SUM(total_laid_off) AS total_laid_off
    FROM layouff_staging2
    GROUP BY company, YEAR(date)
),
company_year_rank AS (
    SELECT
        company,
        years,
        total_laid_off,
        DENSE_RANK() OVER (
            PARTITION BY years
            ORDER BY total_laid_off DESC
        ) AS ranking
    FROM company_year
)
SELECT
    company,
    years,
    total_laid_off,
    ranking
FROM company_year_rank
WHERE ranking <= 3
  AND years IS NOT NULL
ORDER BY years ASC, total_laid_off DESC;


-- Monthly wise total layoff
SELECT
    SUBSTRING(date, 1, 7) AS dates,
    SUM(total_laid_off) AS total_laid_off
FROM layouff_staging2
GROUP BY dates
ORDER BY dates ASC;

-- Monthly wise commulative layoff -rolling Total
WITH date_cte AS (
    SELECT
        SUBSTRING(date, 1, 7) AS dates,
        SUM(total_laid_off) AS total_laid_off
    FROM layouff_staging2
    GROUP BY dates
)
SELECT
    dates,
    SUM(total_laid_off) OVER (ORDER BY dates ASC) AS rolling_total_layoffs
FROM date_cte
ORDER BY dates ASC;

