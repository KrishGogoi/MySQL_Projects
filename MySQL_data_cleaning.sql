-- SQL Project - Data Cleaning


SELECT * 
FROM world_layoffs.layoffs;



-- first thing we want to do is create a copy table. This is the one we will work in and clean the data. We want a table with the raw data in case something happens
CREATE TABLE world_layoffs.layoffs_copy 
LIKE world_layoffs.layoffs;


INSERT layoffs_copy 
SELECT * FROM world_layoffs.layoffs;


-- now when we are data cleaning we usually follow a few steps
-- 1. check for duplicates and remove any
-- 2. standardize data and fix errors
-- 3. Look at null values and see what 
-- 4. remove any columns and rows that are not necessary - few ways



-- 1. Remove Duplicates

-- First let's check for duplicates

SELECT *
FROM world_layoffs.layoffs_copy;


-- Checking every row for any duplicate row by adding 1 to row_num
SELECT company, industry, total_laid_off, `date`,
ROW_NUMBER() OVER(PARTITION BY company, industry, total_laid_off,`date`) AS row_num
FROM world_layoffs.layoffs_copy;



WITH duplicate_cte AS
(
SELECT company, 
	   industry,
       total_laid_off,
       `date`,
ROW_NUMBER() OVER (PARTITION BY company, industry, total_laid_off, `date`) AS row_num
FROM world_layoffs.layoffs_copy
) 
SELECT *
FROM duplicate_cte
WHERE row_num > 1;
    
    
-- let's just look at oda to confirm
SELECT *
FROM world_layoffs.layoffs_copy
WHERE company = 'Oda';
-- it looks like these are all legitimate entries as 'percentage_laid_off' and 'funds_raised_millions' are different and shouldn't be deleted. We need to really look at every single row to be accurate


-- these are our real duplicates 
SELECT *
FROM (
SELECT company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions,
ROW_NUMBER() OVER (
			PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions
			) AS row_num
FROM world_layoffs.layoffs_copy
) AS duplicates
WHERE row_num > 1;

-- these are the ones we want to delete where the row number is > 1 or 2 or greater essentially






-- one solution is to create a new table and add those row numbers in. Then delete where row numbers are over 2, then delete that column
-- to preserve the second raw data


SELECT *
FROM world_layoffs.layoffs_copy;


CREATE TABLE `world_layoffs`.`layoffs_copy2` (
`company` text,
`location`text,
`industry`text,
`total_laid_off` INT,
`percentage_laid_off` text,
`date` text,
`stage`text,
`country` text,
`funds_raised_millions` int,
row_num INT
);

INSERT INTO `world_layoffs`.`layoffs_copy2`
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
FROM world_layoffs.layoffs_copy;


-- now that we have this we can delete rows were row_num is greater than 2
SELECT *
FROM layoffs_copy2
WHERE row_num > 1;


-- Now lets delete the duplicates
DELETE FROM world_layoffs.layoffs_copy2
WHERE row_num >= 2;






-- 2. Standardize Data

SELECT * 
FROM world_layoffs.layoffs_copy2;

-- if we look at industry it looks like we have some null and empty rows, let's take a look at these
SELECT DISTINCT industry
FROM world_layoffs.layoffs_copy2
ORDER BY industry;

SELECT *
FROM world_layoffs.layoffs_copy2
WHERE industry IS NULL 
OR industry = ''
ORDER BY industry;

-- let's take a look at these
SELECT *
FROM world_layoffs.layoffs_copy2
WHERE company LIKE 'Bally%';

-- nothing wrong here
SELECT *
FROM world_layoffs.layoffs_copy2
WHERE company LIKE 'airbnb%';


-- we should set the blanks to nulls since those are typically easier to work with
UPDATE world_layoffs.layoffs_copy2
SET industry = NULL
WHERE industry = '';

-- now if we check those are all null

SELECT *
FROM world_layoffs.layoffs_copy2
WHERE industry IS NULL 
OR industry = ''
ORDER BY industry;

-- now we need to populate those nulls if possible

UPDATE layoffs_copy2 t1
JOIN layoffs_copy2 t2
ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- and if we check it looks like Bally's was the only one without a populated row to populate this null values
SELECT *
FROM world_layoffs.layoffs_copy2
WHERE industry IS NULL 
OR industry = ''
ORDER BY industry;

-- ---------------------------------------------------

-- Crypto has multiple different variations. We need to standardize that - let's change all to Crypto
SELECT DISTINCT industry
FROM world_layoffs.layoffs_copy2
ORDER BY industry;

UPDATE layoffs_copy2
SET industry = 'Crypto'
WHERE industry IN ('Crypto Currency', 'CryptoCurrency');

-- now that's taken care of:
SELECT DISTINCT industry
FROM world_layoffs.layoffs_copy2
ORDER BY industry;

-- --------------------------------------------------
-- we also need to look at 

SELECT *
FROM world_layoffs.layoffs_copy2;

-- everything looks good except apparently we have some "United States" and some "United States." with a period at the end. Let's standardize this.
SELECT DISTINCT country
FROM world_layoffs.layoffs_copy2
ORDER BY country;

UPDATE layoffs_copy2
SET country = TRIM(TRAILING '.' FROM country);

-- now if we run this again it is fixed
SELECT DISTINCT country
FROM world_layoffs.layoffs_copy2
ORDER BY country;


-- Let's also fix the date columns:
SELECT *
FROM world_layoffs.layoffs_copy2;

-- we can use str to date to update this field
UPDATE layoffs_copy2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- now we can convert the data type properly
ALTER TABLE layoffs_copy2
MODIFY COLUMN `date` DATE;


SELECT *
FROM world_layoffs.layoffs_copy2;





-- 3. Look at Null Values

-- the null values in total_laid_off, percentage_laid_off, and funds_raised_millions all look normal. I don't think I want to change that
-- I like having them null because it makes it easier for calculations during the EDA phase

-- so there isn't anything I want to change with the null values




-- 4. remove any columns and rows we need to

SELECT *
FROM world_layoffs.layoffs_copy2
WHERE total_laid_off IS NULL;


SELECT *
FROM world_layoffs.layoffs_copy2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Delete Useless data we can't really use
DELETE FROM world_layoffs.layoffs_copy2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT * 
FROM world_layoffs.layoffs_copy2;

ALTER TABLE layoffs_copy2
DROP COLUMN row_num;


SELECT * 
FROM world_layoffs.layoffs_copy2;

-- Now we are done with our Data Cleaning 
