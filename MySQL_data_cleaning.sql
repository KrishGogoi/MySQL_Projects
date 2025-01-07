CREATE TABLE `dataset_copy2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO dataset_copy2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM dataset_copy;

DELETE 
FROM dataset_copy2
WHERE row_num > 1;

SELECT *
FROM dataset_copy2
WHERE row_num > 1;

-- Standardizing data

SELECT company, TRIM(company)
FROM dataset_copy2;

UPDATE dataset_copy2
SET company = TRIM(company);

SELECT *
FROM dataset_copy2
WHERE industry LIKE 'Crypto%';

UPDATE dataset_copy2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT distinct country, TRIM(TRAILING '.' FROM country)
FROM dataset_copy2
ORDER BY 1;

UPDATE dataset_copy2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%'; 

SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM dataset_copy2;

UPDATE dataset_copy2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE dataset_copy2
MODIFY COLUMN `date` DATE;

SELECT *
FROM dataset_copy2
WHERE industry IS NULL
OR industry = '';

SELECT *
FROM dataset_copy2
WHERE company LIKE 'Bally%';

UPDATE dataset_copy2
SET industry = NULL
WHERE industry = '';

SELECT t1.industry, t2.industry
FROM dataset_copy2 t1
JOIN dataset_copy2 t2
	ON t1.company = t2.company
    AND t1.location = t2.location
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

UPDATE dataset_copy2 t1
JOIN dataset_copy2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;


SELECT *
FROM dataset_copy2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


DELETE
FROM dataset_copy2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM dataset_copy2;

ALTER TABLE dataset_copy2
DROP COLUMN row_num;


