Project Overview

This project performs exploratory data analysis on a global layoffs dataset using SQL.
The goal is to analyze layoff trends across companies, industries, and countries to understand patterns in workforce reductions over time.

The analysis focuses on identifying:

companies with the largest layoffs

industries most affected

geographic patterns

yearly layoff trends

companies that shut down entirely

Dataset

The dataset contains information about layoffs across multiple companies worldwide.

Key fields include:

Column	Description
company	Company name
industry	Industry sector
total_laid_off	Number of employees laid off
percentage_laid_off	Percentage of workforce laid off
date	Date of layoffs
country	Country where layoffs occurred
stage	Company funding stage
Tools Used

SQL

MySQL

Exploratory Analysis Questions

The analysis explores several key business questions:

What is the time range of the dataset?

Which companies laid off the most employees?

Which industries experienced the largest layoffs?

Which countries were most affected?

What are the yearly trends in layoffs?

Which companies laid off 100% of their workforce?

Key SQL Techniques Used

This project demonstrates several important SQL concepts:

Aggregate functions (SUM, AVG, COUNT)

GROUP BY

ORDER BY

filtering with WHERE

ranking top results

date functions for trend analysis.

Example Analysis
Companies with the Largest Layoffs
SELECT company, SUM(total_laid_off) AS total_layoffs
FROM layoffs
GROUP BY company
ORDER BY total_layoffs DESC;

Insight

Large technology companies experienced significant layoffs during the dataset period, reflecting broader economic shifts and restructuring in the tech sector.

Layoffs by Industry
SELECT industry, SUM(total_laid_off) AS layoffs
FROM layoffs
GROUP BY industry
ORDER BY layoffs DESC;

Insight

The technology industry shows the highest layoffs, suggesting that tech companies were heavily impacted during economic downturns.

Layoffs by Country
SELECT country, SUM(total_laid_off) AS layoffs
FROM layoffs
GROUP BY country
ORDER BY layoffs DESC;

Insight

The United States experienced the largest number of layoffs, reflecting the concentration of large technology companies in the region.

Key Insights

Technology companies accounted for the majority of layoffs.

The United States had the highest total layoffs.

Several startups laid off 100% of their workforce, indicating company closures.

Layoffs peaked during specific economic downturn periods.


Project Structure
sql-exploratory-data-analysis
│
├── dataset
│   └── layoffs.csv
│
├── sql_queries
│   └── layoffs_eda.sql
│
└── README.md

Author

Hanif S

Portfolio Purpose

This project is part of a SQL analytics portfolio demonstrating how SQL can be used to explore datasets, identify patterns, and generate business insights.
