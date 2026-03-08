-- Exploratory Data Analysis

SELECT * FROM layoffs_stagging_2;

-- Max layoff on a single day
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_stagging_2;

-- 100% employees layoff by company with funds raised in millions
SELECT *
FROM layoffs_stagging_2
WHERE percentage_laid_off = 1
AND funds_raised_millions IS NOT NULL
ORDER BY funds_raised_millions DESC;

-- Layoffs by company. Gives a good insight on leading and know companies in layoff
SELECT company, SUM(total_laid_off)
FROM layoffs_stagging_2
GROUP BY company
ORDER BY 2 DESC;

-- Layoffs by dates. This shows when layoffs are seen in the dataset.
SELECT MIN(`date`), MAX(`date`) 
FROM layoffs_stagging_2;

-- Layoffs by industry. Clearly, consumer and retail were hit badly
SELECT industry, SUM(total_laid_off)
FROM layoffs_stagging_2
GROUP BY industry
ORDER BY 2 DESC;

-- Layoff by country
SELECT country, SUM(total_laid_off)
FROM layoffs_stagging_2
GROUP BY country
ORDER BY 2 DESC;

-- Layoff by year. Interesting to know layoffs began in 2022, 2023 was the worst where it peaked
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_stagging_2
GROUP BY YEAR(`date`)
ORDER BY 2 DESC;

-- Layoff by stage
SELECT stage, SUM(total_laid_off)
FROM layoffs_stagging_2
GROUP BY stage
ORDER BY 2 DESC;

-- Layoffs by percentage of employee in company. This can help compare historical data
SELECT company, ROUND(SUM(percentage_laid_off),2) `%_laid_off`
FROM layoffs_stagging_2
GROUP BY company
ORDER BY 2 DESC;

-- Layoffs by Year/Month and total layoffs. Timeline of layoffs by months
SELECT DATE_FORMAT(date, '%Y/%m') AS `Month`, SUM(total_laid_off) AS total_off
FROM layoffs_stagging_2
WHERE DATE_FORMAT(date, '%Y/%m') IS NOT NULL
GROUP BY `Month`
ORDER BY `Month`;


-- Layoffs totals, rolling totals, rolling percentage and progression in percentage
WITH cte_total_off AS 
(
    SELECT DATE_FORMAT(date, '%Y/%m') AS `Month`, SUM(total_laid_off) AS total_off
    FROM layoffs_stagging_2
    WHERE DATE_FORMAT(date, '%Y/%m') IS NOT NULL
    GROUP BY `Month`
    ORDER BY `Month`
),
cte_rolling_percentage AS
(
    SELECT `Month`, total_off,
    SUM(total_off) OVER(ORDER BY `Month`) AS rolling_off,
    SUM(total_off) OVER(ORDER BY `Month`) * 100 / SUM(total_off) OVER() AS rolling_percentage
    FROM cte_total_off
),
cte_with_difference AS
(
    SELECT `Month`, total_off, rolling_off, ROUND(rolling_percentage, 2) AS rolling_percentage,
    ROUND(rolling_percentage - LAG(rolling_percentage, 1, 0) OVER(ORDER BY `Month`), 2) AS percentage_diff
    FROM cte_rolling_percentage
)
SELECT `Month`, total_off, rolling_off, rolling_percentage, percentage_diff
FROM cte_with_difference
ORDER BY `Month`;


-- Layoffs by company and year

SELECT company, YEAR(`date`) AS 'year', SUM(total_laid_off)
FROM layoffs_stagging_2
GROUP BY company, 'year'
ORDER BY 3 DESC;

-- Layoffs by company, year with higher count. Amzaon for instance had more layoffs in '22 than '23
WITH cte_company_by_year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_stagging_2
GROUP BY company, YEAR(`date`)
),
company_rank_year AS
(
SELECT *,
DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS rnk
FROM cte_company_by_year
WHERE years IS NOT NULL
)
SELECT *
FROM company_rank_year
WHERE rnk <= 5;


-- Very Hard question with substrings


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

SELECT CASE
	WHEN address LIKE '% Suite 5A%' THEN SUBSTRING_INDEX(address, ' Suite 5A', 1)
    WHEN address LIKE '% Unit%' THEN SUBSTRING_INDEX(address, ' Unit', 1)
	ELSE SUBSTRING_INDEX(address, '-', 1)
    END AS street,
    SUBSTRING_INDEX(SUBSTRING_INDEX(address, '-',2),'-', -1) AS city,
    SUBSTRING_INDEX(address, ' ', -1) AS postal_code
FROM ADDRESSES;


SELECT * FROM ADDRESSES;

SELECT CASE
	WHEN address LIKE '% Suite 5A%' THEN SUBSTRING_INDEX(address, ' Suite 5A', 1)
    WHEN address LIKE '% Unit%' THEN SUBSTRING_INDEX(address, ' Unit', 1)
	ELSE SUBSTRING_INDEX(address, '-', 1)
    END AS street,
	SUBSTRING_INDEX(SUBSTRING_INDEX(address, '-',2),'-', -1) AS city,
    SUBSTRING_INDEX(address, ' ', -1) AS postal_code
FROM ADDRESSES;