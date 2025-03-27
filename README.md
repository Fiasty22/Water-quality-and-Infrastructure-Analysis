# Assessment of Water quality and infrastructure

**Introduction**

The project analyzes water quality and infrastructural enhancements in the hypothetical country of Maji Ndogo. A thorough analysis was conducted using the SQL technique to identify data discrepancies. The project emphasizes the examination of water source visits, the enhancement of water sources, and the evaluation of employee performance related to these sources across various geographical locations.

Through SQL, I executed operations to join and filter data across multiple relational tables, enabling me to pinpoint problematic water sources, monitor project progress effectively, and facilitate infrastructure improvements. The analysis helps track performance metrics and supports data-driven decision-making for sustainable water management in Maji Ndogo.

![project overview](./Images/Maji_Ndogo.JPG)

## Project overview:

The analysis focuses on:  
- Evaluating water sources based on pollution results.
- Tracking visit counts for each water source  
- Assessing infrastructural needs for different types of water sources  
- Monitoring employee data to identify discrepancies and areas for improvement  
- Providing recommendations for enhancements (e.g., installing UV filters and taps)  

## Database structure

 There are about eight tables in the database 

- **Visit Table**: Records details of visits to water sources, including queue times and visit days.

- **Well Pollution**: Documents pollution levels and results.
  
- **Water Source**: Contains metadata such as type and populations served.

- **Water Quality**: Provides quality scores and visit counts for data collection.
  
- **Location**: Stores location details including town, province, and address.
  
- **Employee**: Includes employee details like address, phone number, and email.
  
- **Global Water Sources**: Information on populations with basic water access in rural and urban areas.
  
- **Project Progress**: Tracks project improvements for each source, detailing status and comments.

## Tools utilized


1) **My SQL**: Used to write queries for identifying discrepancies in water access, corruption, and operational inefficiencies.  

2) **Power BI**: Utilized to create a dashboard visualizing basic water access, project progress, and improvements in water sources.


## Key findings

- **Water Supply Disparity**: A higher proportion of the population relies on shared taps due to deteriorating infrastructure and contaminated sources, leading to unequal water access across regions.
 
- **Corruption Detection**:The use of SQL to uncover corruption where the employee scores did not align with the auditor scores.

- **Operational Inefficiencies**: Prolonged wait times for water access, with approximately 2,000 individuals per shared tap. This is particularly problematic in rural areas where shared taps are scarce.
 
- **Community Impact**: Despite a greater number of water sources in rural regions, many are in disrepair or contaminated, forcing reliance on inadequate shared taps, resulting in longer wait times and lower basic water availability compared to urban areas.
 
- **Crime Incidents**: Reports of criminal activities, particularly sexual harassment against women, occurring at water point locations.

## Key Features

- Project tracking: Automatically updates improvement recommendations based on water quality results and queue times.

- Employee performance: Monitors employee performance by tracking inconsistencies between auditor and surveyor assessment.

- Infrastructural update. Update data by replacing various data by joining various aspect



## Data Visualization


Power BI dashboards were created to visualize water supply trends, improvement costs, regional infrastructure discrepancies, and project progress.



## How to run the project

1. Import the SQL files provided in the */sql* directory.
2. Populate the database with sample data, following the instructions in the *data_loading.sql*
3. Execute the query files to generate views, track progress, and analyze data.

## Access the full documentation


The dataset was provided by ALX [Project documentation](https://alx.com)


