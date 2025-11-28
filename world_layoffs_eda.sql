-- EDA

-- The process involves a comprehensive analysis of the cleaned World Layoffs dataset to answer questions across the following categories:
-- 1) Global Trends
-- 2) Country-Level Insights
-- 3) Industry Insights
-- 4) Company-Level Insights
-- 5) Funding & Startup Stage Insights


SELECT * 
FROM layoffs_staging_2;


-- Global Trend
-- 1) Total No. of layoffs from 2020 to date all over the world.
SELECT 
	SUM(total_laid_off) AS `Total_Layoffs`
FROM layoffs_staging_2;


-- 2) Total No. of layoffs year-over-year
SELECT 
	YEAR(`date`) AS `YEAR`, 
    SUM(total_laid_off) AS `Total_Layoffs`
FROM layoffs_staging_2
GROUP BY `YEAR` 
ORDER BY `YEAR` DESC;


-- 3) Month wise Layoffs to understand wheather the business cycle has any correlation with layoff numbers
SELECT 
	YEAR(`date`) AS `Year`, 
	MONTHNAME(`date`) AS `Month` , 
    SUM(total_laid_off) AS `Total_Layoffs`
FROM layoffs_staging_2
GROUP BY 
	YEAR(`date`), MONTH(`date`), MONTHNAME(`date`)
ORDER BY 
	MONTH(`date`), YEAR(`date`) DESC;

    
-- Let's add a ranking column to specify which year has maximum layoffs for each months
WITH monthly_layoffs AS (
    SELECT
        YEAR(`date`) AS `Year`,
        MONTHNAME(`date`) AS `Month`,
        MONTH(`date`) AS `Month_No`,
        SUM(total_laid_off) AS `Total_Layoffs`
    FROM layoffs_staging_2
    GROUP BY 
        YEAR(`date`),
        MONTH(`date`),
        MONTHNAME(`date`)
)
SELECT
    `Year`,
    `Month`,
    `Total_Layoffs`,
    DENSE_RANK() OVER (
        PARTITION BY `Month_No`
        ORDER BY `Total_Layoffs` DESC
    ) AS Year_Rank
FROM monthly_layoffs
ORDER BY `Month_No`, `Year` DESC;


-- 4) Let's see the trend of layoffs over the months in year 2025
SELECT 
	MONTHNAME(`date`) AS `Month`, 
    SUM(total_laid_off) AS `Total_Layoffs`,
    DENSE_RANK() OVER(ORDER BY SUM(total_laid_off) DESC)
FROM layoffs_staging_2
WHERE YEAR(`date`) = 2025
GROUP BY MONTH(`date`), MONTHNAME(`date`)
ORDER BY MONTH(`date`);


-- Country-Level Insights
-- Total Countries in the dataset
SELECT 
	COUNT(DISTINCT country) AS No_of_Countries
FROM layoffs_staging_2;


-- 1) Countries that had most layoffs till date
SELECT 
	country, 
	SUM(total_laid_off) AS `Total_Layoffs`
FROM layoffs_staging_2
GROUP BY country
HAVING `Total_Layoffs` IS NOT NULL
ORDER BY `Total_Layoffs` DESC;


-- 2) Year wise layoff trend of the top 3 Countries
WITH yearly_layoffs AS (
	SELECT 
		YEAR(`date`) AS `Year`,
        country, 
		SUM(total_laid_off) AS `Total_Layoffs`
	FROM layoffs_staging_2
	GROUP BY
		YEAR(`date`),
		country
	HAVING 
		`Total_Layoffs` IS NOT NULL AND
        country IN ('United States', 'India', 'Germany'))
SELECT 
	*,
    DENSE_RANK() OVER(
		PARTITION BY country
		ORDER BY `Total_Layoffs` DESC
        ) AS `RANK`
FROM yearly_layoffs
ORDER BY country, `year` DESC;


-- 3) Countries with least layoffs over the years
SELECT 
	country, 
	SUM(total_laid_off) AS `Total_Layoffs`
FROM layoffs_staging_2
GROUP BY country
HAVING 
	`Total_Layoffs` IS NOT NULL AND
    `Total_Layoffs` < 1000
ORDER BY `Total_Layoffs`;


-- Industry Insights
-- Total Industries
SELECT 
	DISTINCT industry 
FROM layoffs_staging_2;


-- Count
SELECT 
	COUNT(DISTINCT industry) 
FROM layoffs_staging_2;


-- 1) Industry that had highest layoff
SELECT 
	industry, SUM(total_laid_off) AS  `Total_Layoffs`
FROM layoffs_staging_2
GROUP BY industry
ORDER BY `Total_Layoffs` DESC;


-- 2) Yearly layoffs over Industries
SELECT 
	YEAR(`date`) AS `Year`,
	industry, 
    SUM(total_laid_off) AS  `Total_Layoffs`
FROM layoffs_staging_2
GROUP BY
	YEAR(`date`),
	industry
ORDER BY 
	industry, 	
    `YEAR` DESC;


-- 3) Industries that had highest Layoff in the past 2 years
WITH industry_layoff AS (
	SELECT 
		YEAR(`date`) AS `Year`,
		industry, 
		SUM(total_laid_off) AS  `Total_Layoffs`,
		DENSE_RANK() OVER(PARTITION BY industry ORDER BY SUM(total_laid_off) DESC) AS `RANK`
	FROM layoffs_staging_2
	GROUP BY
		YEAR(`date`),
		industry)
SELECT * FROM industry_layoff
WHERE 
	`rank` IN (1, 2) AND
    `Year` IN (2024, 2025)
ORDER BY
	`industry`,
	`Year` DESC;



-- Company-Level Insights
SELECT 
	DISTINCT company 
FROM layoffs_staging_2;


SELECT 
	COUNT(DISTINCT company) AS `No_of_Companies`
FROM layoffs_staging_2;


-- 1) Companies that Laidoff the most
SELECT 
	company,
	SUM(total_laid_off) AS `Total_Layoffs`
FROM layoffs_staging_2
GROUP BY company
HAVING `Total_Layoffs` IS NOT NULL
ORDER BY `Total_Layoffs` DESC;


-- 2) The yearly trend in the layoffs of top companies (Amazon, Google, Meta)
SELECT 
	YEAR(`date`) AS `Year`,
	company,
	SUM(total_laid_off) AS `Total_Layoffs`,
    DENSE_RANK() OVER(PARTITION BY company ORDER BY SUM(total_laid_off) DESC)
FROM layoffs_staging_2
WHERE company IN ('Amazon', 'Google', 'Meta')
GROUP BY
	YEAR(`date`),
	company
ORDER BY 
	company, 
	`Year` DESC;
    

-- Funding & Startup Stage Insights
-- Companies Stages
SELECT DISTINCT stage 
FROM layoffs_staging_2
ORDER BY stage;

-- 1) Let's group the stages into appropriate categories (Eg. Early Stage, Growth Stage etc) 
SELECT 
	company, 
    stage,
	CASE
        WHEN stage IN ('Seed', 'Series A') THEN 'Early Stage'
        WHEN stage IN ('Series B', 'Series C') THEN 'Growth Stage'
        WHEN stage IN ('Series D', 'Series E', 'Series F', 'Series G', 'Series H', 'Series I', 'Series J') THEN 'Late Stage'
        WHEN stage = 'Post-IPO' THEN 'Public'
        WHEN stage IN ('Acquired', 'Subsidiary', 'Private Equity') THEN 'Owned / Non-Startup'
        ELSE 'Unknown'
    END AS `Stage_Category`
FROM layoffs_staging_2;


-- Let's see which stage category had major layoffs
WITH stage_layoff AS (
	SELECT 
		total_laid_off,
        `date`,
        stage,
		CASE
			WHEN stage IN ('Seed', 'Series A') THEN 'Early Stage'
			WHEN stage IN ('Series B', 'Series C') THEN 'Growth Stage'
			WHEN stage IN ('Series D', 'Series E', 'Series F', 'Series G', 'Series H', 'Series I', 'Series J') THEN 'Late Stage'
			WHEN stage = 'Post-IPO' THEN 'Public'
			WHEN stage IN ('Acquired', 'Subsidiary', 'Private Equity') THEN 'Owned / Non-Startup'
			ELSE 'Unknown'
		END AS `Stage_Category`
	FROM layoffs_staging_2)
SELECT 
	stage_category, 
    SUM(total_laid_off) AS `Total_Layoff`
FROM stage_layoff
WHERE stage_category != 'Unknown'
GROUP BY stage_category
ORDER BY `Total_Layoff` DESC;


-- 2) Stage category that had most layoff in 2025
WITH stage_layoff AS (
	SELECT 
		total_laid_off,
        `date`,
        stage,
		CASE
			WHEN stage IN ('Seed', 'Series A') THEN 'Early Stage'
			WHEN stage IN ('Series B', 'Series C') THEN 'Growth Stage'
			WHEN stage IN ('Series D', 'Series E', 'Series F', 'Series G', 'Series H', 'Series I', 'Series J') THEN 'Late Stage'
			WHEN stage = 'Post-IPO' THEN 'Public'
			WHEN stage IN ('Acquired', 'Subsidiary', 'Private Equity') THEN 'Owned / Non-Startup'
			ELSE 'Unknown'
		END AS `Stage_Category`
	FROM layoffs_staging_2)
SELECT 
	stage_category, 
    SUM(total_laid_off) AS `Total_Layoff`
FROM stage_layoff
WHERE stage_category != 'Unknown' AND YEAR(`date`) = 2025
GROUP BY stage_category
ORDER BY `Total_Layoff` DESC;


-- 3) The stage category with the highest number of layoffs in India during 2024 and 2025
WITH stage_layoff AS (
	SELECT 
		total_laid_off,
        `date`,
        stage,
        country,
		CASE
			WHEN stage IN ('Seed', 'Series A') THEN 'Early Stage'
			WHEN stage IN ('Series B', 'Series C') THEN 'Growth Stage'
			WHEN stage IN ('Series D', 'Series E', 'Series F', 'Series G', 'Series H', 'Series I', 'Series J') THEN 'Late Stage'
			WHEN stage = 'Post-IPO' THEN 'Public'
			WHEN stage IN ('Acquired', 'Subsidiary', 'Private Equity') THEN 'Owned / Non-Startup'
			ELSE 'Unknown'
		END AS `Stage_Category`
	FROM layoffs_staging_2)
SELECT 
	YEAR(`date`) AS `Year`,
	stage_category, 
    SUM(total_laid_off) AS `Total_Layoff`
FROM stage_layoff
WHERE stage_category != 'Unknown' AND country = 'India'
GROUP BY 
	YEAR(`date`),
	stage_category
HAVING `Year` IN (2024, 2025)
ORDER BY 	
	`Year` DESC,
	`Total_Layoff` DESC;