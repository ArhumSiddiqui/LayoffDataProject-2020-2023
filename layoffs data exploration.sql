-- DATA EXPLORATION 
SELECT * 
FROM layoffs_staging; 

SELECT MAX(total_laid_off), MAX(percentage_laid_off) 
FROM layoffs_staging; 

-- companys where the whole company went under in descending order of funds raised in millions
SELECT * 
FROM layoffs_staging 
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- total laid off employees for companies over the duration of the dataset
SELECT company, SUM(total_laid_off) 
FROM layoffs_staging
GROUP BY company
ORDER BY 2 DESC; 

-- duration of the dataset is the following... 
SELECT MIN(`date`), MAX(`date`) 
FROM layoffs_staging; 

-- laid off employees in each industry 2020/03 - 2023/03
SELECT industry, SUM(total_laid_off) 
FROM layoffs_staging
GROUP BY industry
ORDER BY 2 DESC; 

-- laid off employees in each country 2020/03 - 2023/03
SELECT country, SUM(total_laid_off) 
FROM layoffs_staging
GROUP BY country
ORDER BY 2 DESC; 

-- Number of laid off employees during each year 
SELECT YEAR(`date`), SUM(total_laid_off) 
FROM layoffs_staging
GROUP BY YEAR(`date`)
ORDER BY 1 DESC; 

-- Number of employees laid off in accordance to the stage of the company 
SELECT stage, SUM(total_laid_off) 
FROM layoffs_staging
GROUP BY stage
ORDER BY 2 DESC; 

SELECT company, avg(percentage_laid_off) 
FROM layoffs_staging 
GROUP BY company
ORDER BY 2 DESC; 

SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off) 
FROM layoffs_staging
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
;

-- # laid off each month and the rolling total. 
SELECT `MONTH`, 
       total_laid_off,
       (SELECT SUM(total_laid_off) 
        FROM layoffs_staging AS ls 
        WHERE SUBSTRING(ls.`date`,1,7) <= rt.`MONTH`
        ) AS rolling_total
FROM (
    SELECT SUBSTRING(`date`,1,7) AS `MONTH`, 
           SUM(total_laid_off) as total_laid_off
    FROM layoffs_staging
    WHERE SUBSTRING(`date`,1,7) IS NOT NULL
    GROUP BY `MONTH`
    ORDER BY 1 ASC
) AS rt;


SELECT company,  YEAR(`date`),  SUM(total_laid_off) 
FROM layoffs_staging 
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC; 


-- TOP 5 layoffs each year by company. 
WITH Company_Year (company, years, total_laid_off) AS 
(
SELECT company,  YEAR(`date`),  SUM(total_laid_off) 
FROM layoffs_staging 
GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS 
(SELECT *, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
FROM Company_Year
WHERE years IS NOT NULL
) 
SELECT * 
FROM Company_Year_Rank
WHERE ranking <= 5; 

