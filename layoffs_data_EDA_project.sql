-- EDA - Exploring the Layoffs Dataset

-- The goal here is to get a feel for the data, spot trends, outliers, or any interesting patterns.
-- I'm starting this analysis with a general idea of looking at layoffs by company, industry, year, etc.
-- Let’s dig in and see what insights we can uncover.

-- First look at the raw data
SELECT * 
FROM world_layoffs.layoffs_staging2;



-- Quick and Simple Queries to Start --------------------------------------------

-- Highest number of layoffs in a single record
SELECT MAX(total_laid_off) AS max_layoffs
FROM world_layoffs.layoffs_staging2;

-- Range of layoff percentages
SELECT MAX(percentage_laid_off) AS max_percentage, MIN(percentage_laid_off) AS min_percentage
FROM world_layoffs.layoffs_staging2
WHERE percentage_laid_off IS NOT NULL;

-- Companies that laid off 100% of their employees
SELECT *
FROM world_layoffs.layoffs_staging2
WHERE percentage_laid_off = 1;

-- Interesting to see that many of these are startups that likely shut down completely

-- Sort them by how much funding they had raised
SELECT *
FROM world_layoffs.layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- BritishVolt and Quibi stand out — raised huge amounts and still went under. That's wild.



-- Grouped Insights (More Complex Aggregations) ---------------------------------

-- Top 5 biggest single layoff events (by total laid off)
SELECT company, total_laid_off
FROM world_layoffs.layoffs_staging
ORDER BY total_laid_off DESC
LIMIT 5;

-- Companies with the most layoffs across the entire dataset
SELECT company, SUM(total_laid_off) AS total_laid_off
FROM world_layoffs.layoffs_staging2
GROUP BY company
ORDER BY total_laid_off DESC
LIMIT 10;

-- Layoffs by location
SELECT location, SUM(total_laid_off) AS total_laid_off
FROM world_layoffs.layoffs_staging2
GROUP BY location
ORDER BY total_laid_off DESC
LIMIT 10;

-- Layoffs by country
SELECT country, SUM(total_laid_off) AS total_laid_off
FROM world_layoffs.layoffs_staging2
GROUP BY country
ORDER BY total_laid_off DESC;

-- Layoffs per year
SELECT YEAR(date) AS year, SUM(total_laid_off) AS total_laid_off
FROM world_layoffs.layoffs_staging2
GROUP BY YEAR(date)
ORDER BY year ASC;

-- Layoffs by industry
SELECT industry, SUM(total_laid_off) AS total_laid_off
FROM world_layoffs.layoffs_staging2
GROUP BY industry
ORDER BY total_laid_off DESC;

-- Layoffs by funding stage
SELECT stage, SUM(total_laid_off) AS total_laid_off
FROM world_layoffs.layoffs_staging2
GROUP BY stage
ORDER BY total_laid_off DESC;



-- More Advanced Analysis -------------------------------------------------------

-- Top 3 companies with the most layoffs *per year*
WITH Company_Year AS (
  SELECT 
    company, 
    YEAR(date) AS year, 
    SUM(total_laid_off) AS total_laid_off
  FROM layoffs_staging2
  GROUP BY company, YEAR(date)
),
Company_Year_Rank AS (
  SELECT 
    company, 
    year, 
    total_laid_off, 
    DENSE_RANK() OVER (PARTITION BY year ORDER BY total_laid_off DESC) AS ranking
  FROM Company_Year
)
SELECT company, year, total_laid_off, ranking
FROM Company_Year_Rank
WHERE ranking <= 3 AND year IS NOT NULL
ORDER BY year ASC, total_laid_off DESC;

-- Monthly layoffs (aggregated by year-month)
SELECT 
  SUBSTRING(date, 1, 7) AS month, 
  SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY month
ORDER BY month ASC;

-- Rolling total of layoffs by month
WITH Monthly_Layoffs AS (
  SELECT 
    SUBSTRING(date, 1, 7) AS month, 
    SUM(total_laid_off) AS total_laid_off
  FROM layoffs_staging2
  GROUP BY month
)
SELECT 
  month, 
  SUM(total_laid_off) OVER (ORDER BY month ASC) AS rolling_total_layoffs
FROM Monthly_Layoffs
ORDER BY month ASC;
