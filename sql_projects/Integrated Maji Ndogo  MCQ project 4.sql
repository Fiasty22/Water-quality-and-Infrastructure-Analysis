USE md_water_services;

CREATE VIEW combined_analysis_table AS
    SELECT 
        L.province_name,
        L.town_name,
        Ws.type_of_water_source,
        L.location_type,
        Ws.number_of_people_served,
        V.time_in_queue,
        Wp.results
    FROM
        location AS L
            JOIN
        visits AS V ON V.location_id = L.location_id
            JOIN
        water_source AS Ws ON Ws.source_id = V.source_id
            LEFT JOIN
        well_pollution AS Wp ON Wp.source_id = V.source_id
    WHERE
        V.visit_count = 1
;

WITH province_totals AS (
SELECT
province_name,
SUM(number_of_people_served) AS Total_ppl_served
FROM
combined_analysis_table
GROUP BY province_name
)
SELECT ct.province_name,
-- These case statements create columns for each type of source.
-- The results are aggregated and percentages are calculated
ROUND((SUM(CASE WHEN type_of_water_source = 'river'
THEN number_of_people_served ELSE 0 END) * 100.0 /Total_ppl_served), 0) AS River,
ROUND((SUM(CASE WHEN type_of_water_source = 'tap_in_home'
THEN number_of_people_served ELSE 0 END) * 100.0 /Total_ppl_served),0) AS tap_in_home,
ROUND((SUM(CASE WHEN type_of_water_source = 'tap_in_home_broken'
THEN number_of_people_served ELSE 0 END) * 100.0 /Total_ppl_served),0) AS tap_in_home_broken,
ROUND((SUM(CASE WHEN type_of_water_source = 'well'
THEN number_of_people_served ELSE 0 END) * 100.0 /Total_ppl_served),0) AS Well,
ROUND((SUM(CASE WHEN type_of_water_source = 'shared_tap'
THEN number_of_people_served ELSE 0 END) * 100.0 /Total_ppl_served),0) AS shared_tap
FROM combined_analysis_table AS ct
JOIN Province_totals AS pt ON ct.province_name = pt.province_name
GROUP BY ct.province_name 
ORDER BY ct.province_name
; 

WITH town_totals AS (-- This CTE calculates the population of each town
-- Since there are two Harare towns, it have to group by province_name and town_name
SELECT province_name, town_name, 
SUM(number_of_people_served) AS total_ppl_serv
FROM combined_analysis_table
GROUP BY province_name,town_name
)
SELECT
ct.province_name,
ct.town_name,
ROUND((SUM(CASE WHEN type_of_water_source = 'river'
THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS river,
ROUND((SUM(CASE WHEN type_of_water_source  = 'shared_tap'
THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS shared_tap,
ROUND((SUM(CASE WHEN type_of_water_source = 'tap_in_home'
THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home,
ROUND((SUM(CASE WHEN type_of_water_source = 'tap_in_home_broken'
THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home_broken,
ROUND((SUM(CASE WHEN type_of_water_source = 'well' AND ct.results != "Clean" 
THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS well
FROM
combined_analysis_table AS ct
JOIN -- Since the town names are not unique, we have to join on a composite key
town_totals AS tt ON ct.province_name = tt.province_name AND ct.town_name = tt.town_name
GROUP BY  -- We group by province first, then by town.
ct.province_name,
ct.town_name
ORDER BY
ct.town_name;

CREATE TEMPORARY TABLE town_aggregated_water_access
WITH town_totals AS (-- This CTE calculates the population of each town
-- Since there are two Harare towns, we have to group by province_name and town_name
SELECT province_name, town_name, SUM(number_of_people_served) AS total_ppl_serv
FROM combined_analysis_table
GROUP BY province_name,town_name
)
SELECT
ct.province_name,
ct.town_name,
ROUND((SUM(CASE WHEN type_of_water_source = 'river'
THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS river,
ROUND((SUM(CASE WHEN type_of_water_source  = 'shared_tap'
THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS shared_tap,
ROUND((SUM(CASE WHEN type_of_water_source = 'tap_in_home'
THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home,
ROUND((SUM(CASE WHEN type_of_water_source = 'tap_in_home_broken'
THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home_broken,
ROUND((SUM(CASE WHEN type_of_water_source = 'well' AND ct.results != "Clean" 
THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS well
FROM
combined_analysis_table AS ct
JOIN -- Since the town names are not unique, we have to join on a composite key
town_totals AS tt ON ct.province_name = tt.province_name AND ct.town_name = tt.town_name
GROUP BY  -- We group by province first, then by town.
ct.province_name,
ct.town_name
ORDER BY
ct.town_name;

DROP TABLE town_aggregated_water_access;

SELECT 
    *
FROM
    town_aggregated_water_access
;

/*There are still many gems hidden in this table. For example, which town has the highest ratio of people who have taps, but have no running water?
Running this*/
SELECT 
    province_name,
    town_name,
    ROUND(tap_in_home_broken / (tap_in_home_broken + tap_in_home) * 100,
            0) AS Pct_broken_taps
FROM
    town_aggregated_water_access;

-- Summary Report
/*Insights
Ok, so let's sum up the data we have.
A couple of weeks ago we found some interesting insights:
1. Most water sources are rural in Maji Ndogo.
2. 43% of our people are using shared taps. 2000 people often share one tap.
3. 31% of our population has water infrastructure in their homes, but within that group,
4. 45% face non-functional systems due to issues with pipes, pumps, and reservoirs. Towns like Amina, the rural parts of Amanzi, and a couple
of towns across Akatsi and Hawassa have broken infrastructure.
5. 18% of our people are using wells of which, but within that, only 28% are clean. These are mostly in Hawassa, Kilimani and Akatsi.
6. Our citizens often face long wait times for water, averaging more than 120 minutes:
• Queues are very long on Saturdays.
• Queues are longer in the mornings and evenings.
• Wednesdays and Sundays have the shortest queues.
*/

CREATE TABLE Project_progress (
    Project_id SERIAL PRIMARY KEY,
    source_id VARCHAR(20) NOT NULL REFERENCES water_source (source_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
    Address VARCHAR(50),
    Town VARCHAR(30),
    Province VARCHAR(30),
    Source_type VARCHAR(50),
    Improvement VARCHAR(50),
    Source_status VARCHAR(50) DEFAULT 'Backlog' CHECK (Source_status IN ('Backlog' , 'In progress', 'Complete')),
    Date_of_completion DATE,
    Comments TEXT
)

SELECT
location.address,
location.town_name,
location.province_name,
water_source.source_id,
water_source.type_of_water_source,
well_pollution.results
FROM
water_source
LEFT JOIN
well_pollution ON water_source.source_id = well_pollution.source_id
INNER JOIN
visits ON water_source.source_id = visits.source_id
INNER JOIN
location ON location.location_id = visits.location_id
WHERE visits.visit_count = 1
AND (well_pollution.results != 'Clean'
OR water_source.type_of_water_source IN ('river', 'tap_in_home_broken')
OR ( water_source.type_of_water_source = 'shared_tap' AND time_in_queue >= 30)
);

SELECT
water_source.source_id,
location.address,
location.town_name,
location.province_name,
water_source.type_of_water_source,
CASE
WHEN (type_of_water_source ='well' AND well_pollution.results = 'Contaminated: Biological')
THEN "Install RO filter"
WHEN (type_of_water_source ='well' AND well_pollution.results = 'Contaminated: Chemical')
THEN "Install UV and RO filter"
WHEN (type_of_water_source ='river')
THEN "Drill wells"
WHEN (type_of_water_source ='tap_in_home_broken')  
THEN "Diagnose local infrastructure"
WHEN (type_of_water_source ='shared_tap' AND time_in_queue >= 30)
THEN
CASE 
		WHEN FLOOR(visits.time_in_queue / 30) <= 1
				THEN (CONCAT("Install ", FLOOR(visits.time_in_queue/30), " tap nearby"))
				ELSE (CONCAT("Install ", FLOOR(visits.time_in_queue/30), " taps nearby"))
END
ELSE NULL
END AS Improvements
FROM
water_source
LEFT JOIN
well_pollution ON water_source.source_id = well_pollution.source_id
INNER JOIN
visits ON water_source.source_id = visits.source_id
INNER JOIN
location ON location.location_id = visits.location_id
WHERE visits.visit_count = 1
AND (well_pollution.results != 'Clean' OR water_source.type_of_water_source IN ('river', 'tap_in_home_broken')
AND ('shared_tap'=1 OR 'shared_tap'>1)
OR ( water_source.type_of_water_source = 'shared_tap' AND time_in_queue >= 30)

);
