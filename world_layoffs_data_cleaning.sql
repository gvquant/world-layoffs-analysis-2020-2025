-- Data Cleaning --

-- The process involves:
-- 1) Removing Duplicates
-- 2) Standardization
-- 3) Handling Missing Values 
-- 4) Remove Insignificant Columns

USE world_layoff;

SELECT * 
FROM layoffs;

-- Total Records
SELECT COUNT(*) 
FROM layoffs;

-- Lets create an Staging Table to work on, so that the raw data is not modified or altered.
DROP TABLE IF EXISTS layoffs_staging;
CREATE TABLE layoffs_staging AS
SELECT *
FROM layoffs;


-- 1) Removing Duplicates
-- Lets identify duplicate records using the Window function & Subquery. 
SELECT * 
FROM
(
SELECT *, ROW_NUMBER() OVER(PARTITION BY `company`, `location`, `date`, `industry`, `country` order by `total_laid_off` Desc) AS Row_Num
FROM layoffs_staging
) AS Duplicates
WHERE Row_Num > 1;

-- Delete Duplicates by creating a new staging tabe along with the Row_Num column
DROP TABLE IF EXISTS layoffs_staging_2;
CREATE TABLE layoffs_staging_2 AS
(
SELECT *, ROW_NUMBER() OVER(PARTITION BY `company`, `location`, `date`, `industry`, `country` order by `total_laid_off` Desc) AS Row_Num
FROM layoffs_staging
);

DELETE 
FROM layoffs_staging_2
WHERE Row_Num > 1;


-- 2) Standardization
-- Now let's focus on standardizing the columns by changing them to appropriate data types.
SHOW COLUMNS FROM layoffs_staging_2;
-- or
DESCRIBE layoffs_staging_2;

-- Updating empty rows with Null followed by altering the data type
-- Total Laid Off Column
UPDATE layoffs_staging_2 
SET total_laid_off = NULL
WHERE total_laid_off = '';

ALTER TABLE layoffs_staging_2
MODIFY COLUMN total_laid_off INT;

-- Percentage Laid Off Column
UPDATE layoffs_staging_2 
SET percentage_laid_off = NULL
WHERE percentage_laid_off = '';

UPDATE layoffs_staging_2 
SET percentage_laid_off = SUBSTRING(percentage_laid_off, 1, 5)
WHERE percentage_laid_off IS NOT NULL;

ALTER TABLE layoffs_staging_2
MODIFY COLUMN percentage_laid_off DECIMAL(10, 3);

-- Date Columns
UPDATE layoffs_staging_2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging_2
MODIFY COLUMN `date` DATE;

-- Industry Column
UPDATE layoffs_staging_2
SET industry = 'Consumer'
WHERE company = 'Appsmith';

-- Company Column
UPDATE layoffs_staging_2
SET company = TRIM(company);

-- Stage Column
UPDATE layoffs_staging_2
SET stage = 'Series B'
WHERE stage = '';

-- Country Column
UPDATE layoffs_staging_2
SET country = 'United Arab Emirates'
WHERE country = 'UAE';

UPDATE layoffs_staging_2
SET country = 'Canada'
WHERE country = '';


-- 3)
-- Lets look at each columns and the number of null values in it
SELECT 
	SUM(company IS NULL) AS company,
    SUM(location IS NULL) AS location,
    SUM(total_laid_off IS NULL) AS total_laid_off,
    SUM(`date` IS NULL) AS `date`,
    SUM(percentage_laid_off IS NULL) AS percentage_laid_off,
    SUM(industry IS NULL) AS industry,
    SUM(`source` IS NULL) AS `source`,
    SUM(stage IS NULL) AS stage,
    SUM(funds_raised IS NULL) AS funds_raised,
    SUM(country IS NULL) AS country
FROM layoffs_staging_2;

SELECT COUNT(*) 
FROM layoffs_staging_2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

-- There are total 585 records having both total_laid_off and percentage_laid_off value as Null. We can't perform any transformation on it to make it valuabe. So it is better to remove those records from the table.
DELETE 
FROM layoffs_staging_2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;


-- 4)
-- Removing insignificant columns, which includes source, date_added, row_num.
ALTER TABLE layoffs_staging_2
DROP COLUMN `source`,
DROP COLUMN `date_added`,
DROP COLUMN `Row_Num`;

SELECT *
FROM layoffs_staging_2;