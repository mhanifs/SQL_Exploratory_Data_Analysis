-- =====================================================
-- Project: SQL Exploratory Data Analysis
-- Dataset: Global Tech Layoffs
-- Clean Table: layoffs_staging_2
-- Author: Hanif S
-- =====================================================

-- NOTE:
-- This analysis uses the cleaned dataset created in the
-- "SQL Data Cleaning Project".
-- The cleaned table used here is: layoffs_staging_2


-- =====================================================
-- 1. DATASET OVERVIEW
-- =====================================================

-- View first rows of the dataset
SELECT *
FROM layoffs_staging_2
LIMIT 10;

-- Dataset date range
SELECT MIN(date) AS earliest_date,
       MAX(date) AS latest_date
FROM layoffs_staging_2;


-- =====================================================
-- 2. MAJOR LAYOFF EVENTS
-- =====================================================

-- Maximum layoffs recorded in a single entry
SELECT MAX(total_laid_off) AS max_laid_off,
       MAX(percentage_laid_off) AS max_percentage_laid_off
FROM layoffs_staging_2;

-- Companies that laid off 100% of employees
-- Sorted by funding raised
SELECT company,
       location,
       industry,
       total_laid_off,
       percentage_laid_off,
       funds_raised_millions
FROM layoffs_staging_2
WHERE percentage_laid_off = 1
AND funds_raised_millions IS NOT NULL
ORDER BY funds_raised_millions DESC;


-- =====================================================
-- 3. LAYOFFS BY COMPANY
-- =====================================================

-- Companies with the highest total layoffs
SELECT company,
       SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging_2
GROUP BY company
ORDER BY total_layoffs DESC;


-- =====================================================
-- 4. LAYOFFS BY INDUSTRY
-- =====================================================

SELECT industry,
       SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging_2
GROUP BY industry
ORDER BY total_layoffs DESC;


-- =====================================================
-- 5. LAYOFFS BY COUNTRY
-- =====================================================

SELECT country,
       SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging_2
GROUP BY country
ORDER BY total_layoffs DESC;


-- =====================================================
-- 6. YEARLY LAYOFF TRENDS
-- =====================================================

SELECT YEAR(date) AS year,
       SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging_2
GROUP BY YEAR(date)
ORDER BY year;


-- =====================================================
-- 7. LAYOFFS BY COMPANY STAGE
-- =====================================================

SELECT stage,
       SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging_2
GROUP BY stage
ORDER BY total_layoffs DESC;


-- =====================================================
-- 8. PERCENTAGE OF WORKFORCE LAID OFF BY COMPANY
-- =====================================================

SELECT company,
       ROUND(SUM(percentage_laid_off), 2) AS percentage_laid_off
FROM layoffs_staging_2
GROUP BY company
ORDER BY percentage_laid_off DESC;


-- =====================================================
-- 9. MONTHLY LAYOFF TIMELINE
-- =====================================================

SELECT DATE_FORMAT(date, '%Y/%m') AS month,
       SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging_2
WHERE DATE_FORMAT(date, '%Y/%m') IS NOT NULL
GROUP BY month
ORDER BY month;


-- =====================================================
-- 10. ROLLING LAYOFF ANALYSIS
-- =====================================================

WITH monthly_layoffs AS
(
    SELECT DATE_FORMAT(date, '%Y/%m') AS month,
           SUM(total_laid_off) AS total_layoffs
    FROM layoffs_staging_2
    GROUP BY month
),
rolling_totals AS
(
    SELECT month,
           total_layoffs,
           SUM(total_layoffs) OVER(ORDER BY month) AS rolling_layoffs,
           SUM(total_layoffs) OVER(ORDER BY month) * 100 /
           SUM(total_layoffs) OVER() AS rolling_percentage
    FROM monthly_layoffs
),
rolling_change AS
(
    SELECT month,
           total_layoffs,
           rolling_layoffs,
           ROUND(rolling_percentage, 2) AS rolling_percentage,
           ROUND(
                rolling_percentage -
                LAG(rolling_percentage, 1, 0) OVER(ORDER BY month),
                2
           ) AS percentage_change
    FROM rolling_totals
)

SELECT *
FROM rolling_change
ORDER BY month;


-- =====================================================
-- 11. LAYOFFS BY COMPANY AND YEAR
-- =====================================================

SELECT company,
       YEAR(date) AS year,
       SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging_2
GROUP BY company, YEAR(date)
ORDER BY total_layoffs DESC;


-- =====================================================
-- 12. TOP COMPANIES BY LAYOFFS EACH YEAR
-- =====================================================

WITH company_yearly_layoffs AS
(
    SELECT company,layoffs_staging_2
           YEAR(date) AS year,
           SUM(total_laid_off) AS total_layoffs
    FROM layoffs_staging_2
    GROUP BY company, YEAR(date)
),
ranked_companies AS
(
    SELECT *,
           DENSE_RANK() OVER(
               PARTITION BY year
               ORDER BY total_layoffs DESC
           ) AS rank_
    FROM company_yearly_layoffs
)

SELECT *
FROM ranked_companies
WHERE rank_ <= 5;


-- =====================================================
-- BONUS: SQL STRING MANIPULATION EXERCISE
-- Parsing Address Data
-- =====================================================

CREATE TABLE ADDRESSES (
    address VARCHAR(250)
);

INSERT INTO ADDRESSES (address) VALUES
('123 Main St Suite 5A-New York-NY 12345'),
('456 Park Ave-Minneapolis-MN 34563'),
('789 Elm St-Goldsboro-NC 23578'),
('1010 Broadway-Maples-MA 32167'),
('1111 West St Unit B-Flowertown-FL 94566');

SELECT * FROM ADDRESSES;

SELECT
CASE
    WHEN address LIKE '% Suite 5A%'
        THEN SUBSTRING_INDEX(address, ' Suite 5A', 1)
    WHEN address LIKE '% Unit%'
        THEN SUBSTRING_INDEX(address, ' Unit', 1)
    ELSE SUBSTRING_INDEX(address, '-', 1)
END AS street,

SUBSTRING_INDEX(SUBSTRING_INDEX(address, '-',2),'-', -1) AS city,

SUBSTRING_INDEX(address, ' ', -1) AS postal_code

FROM ADDRESSES;


-- =====================================================
-- ANALYSIS SUMMARY
-- =====================================================

-- Key Insights:
-- 1. Layoffs increased significantly during 2022 and 2023.
-- 2. Technology and consumer industries were among the most affected.
-- 3. The United States experienced the highest number of layoffs.
-- 4. Several startups laid off 100% of their workforce, indicating closures.
-- 5. Monthly rolling analysis shows spikes during economic downturn periods.
