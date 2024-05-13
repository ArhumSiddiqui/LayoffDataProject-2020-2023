-- DATA CLEANING

SELECT * 
FROM layoffs;

-- Create new table to edit. Do not want to change raw data

CREATE TABLE layoffs_staging 
LIKE layoffs; 

INSERT layoffs_staging 
SELECT * 
FROM layoffs; 

SELECT *
FROM layoffs_staging;

-- REMOVE DUPLICATES 
-- Step 1: Create a temporary table
CREATE TEMPORARY TABLE temp_table LIKE layoffs_staging;

-- Step 2: Insert distinct rows into the temporary table
INSERT INTO temp_table
SELECT DISTINCT *
FROM layoffs_staging;

-- Step 3: Truncate the original table
TRUNCATE TABLE layoffs_staging;

-- Step 4: Insert rows from the temporary table back into the original table
INSERT INTO layoffs_staging
SELECT * FROM temp_table;

-- Drop the temporary table
DROP TEMPORARY TABLE temp_table;

-- NOW THERE ARE NO DUPLICATES IN LAYOFFS_STAGING
SELECT * 
FROM layoffs_staging; 

-- STANDARDIZE DATASET
SELECT company, TRIM(company) 
FROM layoffs_staging; 

UPDATE layoffs_staging 
SET company = TRIM(company); 

SELECT DISTINCT industry 
FROM layoffs_staging
ORDER BY 1;

-- Crypto and crypto currency is the same industry
SELECT * 
FROM layoffs_staging 
WHERE industry LIKE 'Crypto%'; 

UPDATE layoffs_staging 
SET industry = 'Crypto' 
WHERE industry LIKE 'Crypto%'; 

-- Now lets look at date 
SELECT `date`,  
STR_TO_DATE(`date`, '%m/%d/%Y' ) 
FROM layoffs_staging; 

UPDATE layoffs_staging 
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y' ); 

-- Change date from string to date 
ALTER TABLE layoffs_staging
MODIFY COLUMN `date` DATE; 

SELECT `date` 
FROM layoffs_staging; 

-- REMOVING NULLS AND BLANKS
SELECT * 
FROM layoffs_staging
WHERE industry is NULL 
OR industry = '';  

-- CONVERT ALL BLANKS INTO NULL
UPDATE layoffs_staging 
SET industry = NULL 
WHERE industry = ''; 

-- You can get rid of the NULL by checking if there is another row with the same company whose industry is already filled 
SELECT t1.industry, t2.industry
FROM layoffs_staging t1 
JOIN layoffs_staging t2 
	on t1.company = t2.company
WHERE (t1.industry IS NULL AND t2.industry IS NOT NULL); 

UPDATE layoffs_staging t1
JOIN layoffs_staging t2
	ON t1.company = t2.company 
SET t1.industry = t2.industry 
WHERE (t1.industry IS NULL AND t2.industry IS NOT NULL); 

SELECT DISTINCT industry 
FROM layoffs_staging 
ORDER BY industry; 

-- IF total laid off and percentage laid off are both missing, remove bc its not useful data. 
SELECT percentage_laid_off
FROM layoffs_staging 
WHERE percentage_laid_off = ''; 

SELECT total_laid_off
FROM layoffs_staging 
WHERE total_laid_off = ''; 
-- No blanks for these two columns, just nulls

SELECT total_laid_off, percentage_laid_off
FROM layoffs_staging 
WHERE (total_laid_off IS NULL AND percentage_laid_off IS NULL); 

DELETE 
FROM layoffs_staging 
WHERE (total_laid_off IS NULL AND percentage_laid_off IS NULL); 

SELECT * 
FROM layoffs_staging; 

