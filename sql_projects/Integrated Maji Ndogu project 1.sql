USE md_water_services
;

-- Write an SQL query that retrieves all records from this table where the time_in_queue is more than some crazy time, say 500 min. How
-- would it feel to queue 8 hours for water?
SELECT
*
FROM visits;

SELECT
*
FROM water_source
WHERE source_id IN ('AkKi00881224','SoRu37635224','SoRu36096224','AkLu02523224','AkRu05234224','HaZa21742224','AkLu01628224')
;
SELECT *
FROM water_quality;

-- So please write a query to find records where the subject_quality_score is 10 -- only looking for home taps -- and where the source
-- was visited a second time. What will this tell us?
SELECT *
FROM water_quality
WHERE  subjective_quality_score = 10
AND visit_count = 2 AND subjective_quality_score =10;

SELECT *
FROM well_pollution
LIMIT 5;

-- write a query that checks if the results is Clean but the biological column is > 0.01.

SELECT *
FROM well_pollution
WHERE results = "clean" 
AND biological >0.01;

-- We need to identify the records that mistakenly have the word Clean in the description
SELECT *
FROM well_pollution
WHERE results = "clean" 
AND biological >0.01
AND description LIKE "Clean%"
;


SET SESSION sql_safe_updates = OFF;
-- Case 1a: Update descriptions that mistakenly mention `Clean Bacteria: E. coli` to `Bacteria: E. coli`
UPDATE well_pollution
SET description = 'Bacteria: E. coli'
WHERE description = 'Clean Bacteria: E. coli';

-- Case 1b: Update the descriptions that mistakenly mention Clean Bacteria: Giardia Lamblia` to `Bacteria: Giardia Lamblia
UPDATE well_pollution

SET description = 'Bacteria: Giardia Lamblia'
WHERE description = 'Clean Bacteria: Giardia Lamblia';

-- Case 2: Update the `result` to `Contaminated: Biological` where`biological` is greater than 0.01 plus current results is `Clean`
UPDATE well_pollution
SET results = 'Contaminated: Biological'
WHERE biological> 0.01
AND results = 'Clean';

