# created construction_crm database
CREATE DATABASE construction_crm;

# setting the construction_crm database as default database for existing session
USE construction_crm;

# creating project_raw table
CREATE TABLE projects_raw (
    project_id INT,
    client_name VARCHAR(100),
    project_type VARCHAR(100),
    city VARCHAR(100),
    estimated_cost DECIMAL(10,2),
    actual_cost DECIMAL(10,2),
    start_date VARCHAR(50),
    end_date VARCHAR(50),
    project_status VARCHAR(50),
    contractor VARCHAR(100)
);

# inserting data into project_raw table
INSERT INTO projects_raw
VALUES
(101,'ABC Holdings','Renovation','Cape Town',50000,52000,'2024-01-10','2024-02-15','Completed','BuildPro'),

(102,'abc holdings','renovation','cape town',50000,52000,'2024-01-10','2024-02-15','completed','BuildPro'),

(103,'XYZ Corp','New Build','Johannesburg',150000,NULL,'2024/03/01','2024/08/30','In Progress',''),

(104,'XYZ Corp ','NEW BUILD','Johannesburg',150000,NULL,'2024/03/01','2024/08/30','In Progress',NULL),

(105,'Delta Ltd',NULL,'Durban',75000,80000,'15-04-2024','30-06-2024','Completed','ConstructCo'),

(106,'Delta Ltd',NULL,'Durban',75000,80000,'15-04-2024','30-06-2024','Completed','ConstructCo'),

(107,'Omega Group','Maintenance',' ',25000,27000,'2024-05-10','2024-05-25','Delayed','FixIt'),

(108,NULL,'Maintenance','Pretoria',30000,29000,'2024-06-01','2024-06-20','Completed','FixIt');

# checking for errors in the table
SELECT * 
FROM projects_raw;

#checking for duplicates
SELECT 
	project_id,
    client_name, 
    COUNT(*) AS duplicate_count
FROM projects_raw
GROUP BY project_id,client_name
HAVING COUNT(*) > 1;

#identifying which records to keep
SELECT *,
ROW_NUMBER() OVER(
    PARTITION BY
        client_name,
        project_type,
        city,
        estimated_cost,
        actual_cost
    ORDER BY project_id
) AS rn
FROM projects_clean;

DELETE p1
FROM projects_clean p1
JOIN projects_clean p2
ON p1.client_name = p2.client_name
AND p1.project_type = p2.project_type
AND p1.city = p2.city
AND p1.estimated_cost = p2.estimated_cost
AND p1.project_id > p2.project_id;

#trim client_name column
UPDATE projects_clean
SET client_name = TRIM(client_name);

# trim & capitalise project_type column
UPDATE projects_clean
SET project_type = UPPER(TRIM(project_type));

#identify blank values in contractor column
SELECT *
FROM projects_clean
WHERE contractor = '';

#replace blank values with NULL in contractor column
UPDATE projects_clean
SET contractor = NULL 
WHERE contractor = '';

# finding missing values in contractor column
SELECT *
FROM projects_clean
WHERE contractor IS NULL;

#finding missing values in actual_cost column
SELECT *
FROM projects_clean
WHERE actual_cost IS NULL;

#filling missing values in contractor column 
UPDATE projects_clean
SET contractor = 'Unknown'
WHERE contractor IS NULL;

#filling missing values in project type
UPDATE projects_clean
SET project_type = 'Unknown'
WHERE project_type  IS NULL;

#identifying blank cities
SELECT *
FROM projects_clean
WHERE TRIM(city) = '';

#filling blank cities with Unknown
UPDATE projects_clean
SET city = 'Uknown' 
WHERE TRIM(city) = '';

#checking the date column format
SELECT DISTINCT start_date
FROM projects_clean;

#add new column 
ALTER TABLE projects_clean
ADD COLUMN start_date_clean DATE;

#converting different formats in the start date clean column using CASE
UPDATE projects_clean
SET start_date_clean =
CASE

    WHEN start_date LIKE '%/%'
    THEN STR_TO_DATE(start_date,'%Y/%m/%d')

    WHEN start_date REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$'
    THEN STR_TO_DATE(start_date,'%d-%m-%Y')

    WHEN start_date REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
    THEN STR_TO_DATE(start_date,'%Y-%m-%d')

    ELSE NULL

END;

#verify results
SELECT 
	start_date,
    start_date_clean
FROM projects_clean;

#add a new end date clean column 
ALTER TABLE projects_clean
ADD COLUMN end_date_clean Date;

#converting different formats in the end date clean column using CASE
UPDATE projects_clean
SET end_date_clean =
CASE

    WHEN end_date LIKE '%/%'
    THEN STR_TO_DATE(end_date,'%Y/%m/%d')

    WHEN end_date REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$'
    THEN STR_TO_DATE(end_date,'%d-%m-%Y')

    WHEN end_date REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
    THEN STR_TO_DATE(end_date,'%Y-%m-%d')

    ELSE NULL

END;

#deleting the old date formats
ALTER TABLE projects_clean
DROP start_date;
ALTER TABLE projects_clean
DROP end_date;














