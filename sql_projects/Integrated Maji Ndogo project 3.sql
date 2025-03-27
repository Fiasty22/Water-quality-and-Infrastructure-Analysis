SELECT * FROM md_water_services.auditor_report;

                
DROP TABLE IF EXISTS `auditor_report`;
CREATE TABLE `auditor_report` (
`location_id` VARCHAR(32),
`type_of_water_source` VARCHAR(64),
`true_water_source_score` int DEFAULT NULL,
`statements` VARCHAR(255)
);
SELECT* FROM visits;
-- integrating the auditor's report

SELECT 
    A.location_id,
    V.record_id,
    A.true_water_source_score AS Auditor_score,
    W.subjective_quality_score AS Surveyor_score,
    V.visit_count,
    A.type_of_water_source AS auditor_source,
    WS.type_of_water_source AS survey_source,
    E.employee_name
FROM
    auditor_report AS A
        JOIN
    visits AS V ON A.location_id = V.location_id
        JOIN
    water_quality AS W ON W.record_id = V.record_id
        JOIN
	water_source AS WS ON WS.source_id = V.source_id
		JOIN
    employee AS E ON E.assigned_employee_id = V.assigned_employee_id
    WHERE  A.true_water_source_score != W.subjective_quality_score
	AND V.visit_count = 1;
    
    WITH Incorrect_records AS 
    (SELECT 
    A.location_id,
    V.record_id,
    A.true_water_source_score AS Auditor_score,
    W.subjective_quality_score AS Surveyor_score,
    E.employee_name
FROM
    auditor_report AS A
        JOIN
    visits AS V ON A.location_id = V.location_id
        JOIN
    water_quality AS W ON W.record_id = V.record_id
		JOIN
    employee AS E ON E.assigned_employee_id = V.assigned_employee_id
    WHERE  A.true_water_source_score != W.subjective_quality_score
	AND V.visit_count = 1)
    SELECT employee_name
    FROM Incorrect_records
    ;
    
/*So basically I want to count how many times their name is in
Incorrect_records list, and then group them by name */
    
     WITH Incorrect_records AS 
    (SELECT 
    A.location_id,
    V.record_id,
    A.true_water_source_score AS Auditor_score,
    W.subjective_quality_score AS Surveyor_score,
    E.employee_name
FROM
    auditor_report AS A
        JOIN
    visits AS V ON A.location_id = V.location_id
        JOIN
    water_quality AS W ON W.record_id = V.record_id
		JOIN
    employee AS E ON E.assigned_employee_id = V.assigned_employee_id
    WHERE  A.true_water_source_score != W.subjective_quality_score
	AND V.visit_count = 1)
    SELECT 
    employee_name,
    COUNT(employee_name) AS number_of_mistakes
    FROM Incorrect_records
    GROUP BY employee_name
    ORDER BY number_of_mistakes DESC;
    
    -- Gathering evidence
    CREATE VIEW Incorrect_records AS (
SELECT
auditor_report.location_id,
visits.record_id,
employee.employee_name,
auditor_report.true_water_source_score AS auditor_score,
wq.subjective_quality_score AS surveyor_score,
auditor_report.statements AS statements
FROM
auditor_report
JOIN
visits
ON auditor_report.location_id = visits.location_id
JOIN
water_quality AS wq
ON visits.record_id = wq.record_id
JOIN
employee
ON employee.assigned_employee_id = visits.assigned_employee_id
WHERE
visits.visit_count =1
AND auditor_report.true_water_source_score != wq.subjective_quality_score);
    
WITH error_count AS (SELECT 
    employee_name,
    COUNT(employee_name) AS number_of_mistakes
    FROM Incorrect_records
    GROUP BY employee_name
    ORDER BY number_of_mistakes DESC)
    -- calculating the average number of employees that make mistakes
    SELECT *
    FROM error_count
    WHERE number_of_mistakes > (
							SELECT 
							AVG(number_of_mistakes)
							FROM error_count)
                            ;
   WITH error_count AS (SELECT 
    employee_name,
    COUNT(employee_name) AS number_of_mistakes
    FROM Incorrect_records
    GROUP BY employee_name
    ORDER BY number_of_mistakes DESC)
    
    -- calculating the average number of employees that make mistakes
    SELECT *
    FROM error_count
    WHERE number_of_mistakes != (
							SELECT 
							AVG(number_of_mistakes)
							FROM error_count)
                            ;
                            
-- creating a CTE called suspect list
WITH suspect_list AS (SELECT 
    employee_name,
    COUNT(employee_name) AS number_of_mistakes
    FROM Incorrect_records
    GROUP BY employee_name)
    SELECT *
    FROM Incorrect_records
    WHERE employee_name IN ('Bello Azibo','Malachi Mavuso','Zuriel Matembo','Lalitha Kaburi')

    --  calculating the average number of employees that make mistakes
    SELECT *
    FROM suspect_list
    WHERE number_of_mistakes > (
							SELECT 
							AVG(number_of_mistakes)
							FROM error_count)
                            ;
                            

WITH error_count AS ( -- This CTE calculates the number of mistakes each employee made
SELECT
employee_name,
COUNT(employee_name) AS number_of_mistakes
FROM
Incorrect_records
/*
Incorrect_records is a view that joins the audit report to the database
for records where the auditor and
employees scores are different*/
GROUP BY
employee_name),
suspect_list AS (-- This CTE SELECTS the employees with above−average mistakes
SELECT
employee_name,
number_of_mistakes
FROM
error_count
WHERE
number_of_mistakes > (SELECT
					  AVG(number_of_mistakes) FROM error_count))
-- This query filters all of the records where the "corrupt" employees gathered data.
SELECT
employee_name,
location_id,
statements
FROM
Incorrect_records
WHERE
employee_name NOT IN ('Bello Azibo','Malachi Mavuso','Zuriel Matembo','Lalitha Kaburi')
AND statements LIKE '%cash%'
/*So we can sum up the evidence we have for Zuriel Matembo, Malachi Mavuso, Bello Azibo and Lalitha Kaburi:
1. They all made more mistakes than their peers on average.
2. They all have incriminating statements made against them, and only them.
*/

;

