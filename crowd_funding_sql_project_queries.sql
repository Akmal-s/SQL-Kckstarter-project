create database crowdfunding;

SELECT FROM_UNIXTIME(created_at) AS converted_created_at
FROM projects;

SELECT FROM_UNIXTIME(deadline_at) AS converted_deadline_at
FROM projects;

SELECT FROM_UNIXTIME(successful_at) AS converted_successful_at
FROM projects;

SELECT FROM_UNIXTIME(state_changed_at) AS converted_state_changed_at
FROM projects;

SELECT FROM_UNIXTIME(launched_at) AS converted_launched_at
FROM projects;

SELECT FROM_UNIXTIME(updated_at) AS converted_updated_at
FROM projects;

CREATE TABLE calendar (
    id INT PRIMARY KEY, 
    created_date date
);

INSERT INTO calendar (id, created_date)
SELECT project_id, created_at
FROM projects;


ALTER TABLE calendar
ADD year_column INT;

UPDATE calendar
SET year_column = YEAR(created_at);

alter table calendar
add month_no int;

update calendar
set month_no = month(created_at);

alter table calendar
add month_name text;

update calendar
set month_name = monthname(created_at);

ALTER TABLE calendar ADD Quarter VARCHAR(5);

UPDATE calendar
SET Quarter = CONCAT('Q', QUARTER(created_at));

ALTER TABLE calendar ADD YearMonth VARCHAR(10);
UPDATE calendar SET YearMonth = CONCAT(YEAR(created_at), '-', LEFT(DATENAME(MONTH, created_at), 3));

UPDATE calendar
SET YearMonth = CONCAT(YEAR(created_at), '-', LEFT(MONTHNAME(created_at), 3));

ALTER TABLE calendar ADD WeekdayNo INT;
UPDATE calendar
SET WeekdayNo = DAYOFWEEK(created_at);

ALTER TABLE calendar ADD WeekdayName VARCHAR(20);
UPDATE calendar
SET WeekdayName = DAYNAME(created_at);

ALTER TABLE calendar ADD FinancialMonth VARCHAR(5);
UPDATE calendar
SET FinancialMonth = CASE 
    WHEN MONTH(created_at) = 4 THEN 'FM1'
    WHEN MONTH(created_at) = 5 THEN 'FM2'
    WHEN MONTH(created_at) = 6 THEN 'FM3'
    WHEN MONTH(created_at) = 7 THEN 'FM4'
    WHEN MONTH(created_at) = 8 THEN 'FM5'
    WHEN MONTH(created_at) = 9 THEN 'FM6'
    WHEN MONTH(created_at) = 10 THEN 'FM7'
    WHEN MONTH(created_at) = 11 THEN 'FM8'
    WHEN MONTH(created_at) = 12 THEN 'FM9'
    WHEN MONTH(created_at) = 1 THEN 'FM10'
    WHEN MONTH(created_at) = 2 THEN 'FM11'
    WHEN MONTH(created_at) = 3 THEN 'FM12'
END;


ALTER TABLE calendar ADD FinancialQuarter VARCHAR(5);
UPDATE calendar
SET FinancialQuarter = CASE 
    WHEN FinancialMonth IN ('FM1', 'FM2', 'FM3') THEN 'FQ1'
    WHEN FinancialMonth IN ('FM4', 'FM5', 'FM6') THEN 'FQ2'
    WHEN FinancialMonth IN ('FM7', 'FM8', 'FM9') THEN 'FQ3'
    WHEN FinancialMonth IN ('FM10', 'FM11', 'FM12') THEN 'FQ4'
END;





-- total no of projects based on out come
SELECT state, COUNT(projectID) AS project_state
FROM projects
GROUP BY state
ORDER BY state;


-- total projects based on location
SELECT crowdfunding_location.country, COUNT(projects.projectID) AS total_projects
FROM projects
JOIN crowdfunding_location ON projects.location_id = crowdfunding_location.id
GROUP BY crowdfunding_location.country
ORDER BY total_projects DESC;


-- Total Number of Projects based on  Category
SELECT crowdfunding_category.name AS category_name, COUNT(projects.projectID) AS total_projects
FROM projects
JOIN crowdfunding_category ON projects.category_id = crowdfunding_category.id
GROUP BY crowdfunding_category.name
ORDER BY total_projects DESC;


-- Total Number of Projects created by Year , Quarter , Month
SELECT calendar.year_column, COUNT(projects.projectID) AS total_projects
FROM projects
JOIN calendar ON projects.projectID = calendar.projectid
GROUP BY calendar.year_column
ORDER BY calendar.year_column;


-- amount raised for Successful Projects
SELECT state, COUNT(projectID) AS successful_projects, SUM(usd_pledged) AS amount_raised
FROM projects
WHERE state = 'Successful'
GROUP BY state
ORDER BY state;


-- total backers for successful projects
SELECT SUM(backers_count) AS total_backers
FROM projects
WHERE state = 'Successful';

-- Avg NUmber of Days for successful projects
SELECT AVG(DATEDIFF(converted_successful_at,converted_created_at)) AS avg_days_for_successful_projects
FROM projects
WHERE state = 'Successful';

-- top successful projects based on backers 
SELECT projectID,name, backers_count
FROM projects
WHERE state = 'Successful'
ORDER BY backers_count DESC
LIMIT 5;

-- top successful projects based on amount raised
SELECT projectID,name, usd_pledged
FROM projects
WHERE state = 'Successful'
ORDER BY usd_pledged DESC
LIMIT 5;


-- percentage of successful projects overall
SELECT 
    SUM(CASE WHEN state = 'successful' THEN 1 ELSE 0 END) * 100.0 / COUNT(projectID) AS successful_percentage
FROM 
    projects;
    
    
-- Percentage of Successful Projects  by Category
SELECT 
    crowdfunding_category.name,
    SUM(CASE WHEN projects.state = 'successful' THEN 1 ELSE 0 END) * 100.0 / COUNT(projects.projectID) AS successful_percentage
FROM 
    crowdfunding_category
JOIN 
    projects
ON 
    crowdfunding_category.id = projects.category_id
GROUP BY 
    crowdfunding_category.name
order by successful_percentage desc;


-- Percentage of Successful Projects by Year , Month etc..
SELECT 
    calendar.year_column,
    calendar.month_no,
    SUM(CASE WHEN projects.state = 'successful' THEN 1 ELSE 0 END) * 100.0 / COUNT(projects.projectID) AS successful_percentage
FROM 
    calendar
JOIN 
    projects
ON 
    calendar.projectid = projects.projectID
GROUP BY 
    calendar.year_column, calendar.month_no
order by successful_percentage desc;


-- Percentage of Successful projects by Goal Range
SELECT 
    CASE 
        WHEN goal BETWEEN 0 AND 10000 THEN '0-10000'
        WHEN goal BETWEEN 10001 AND 50000 THEN '10001-50000'
        WHEN goal BETWEEN 50001 AND 100000 THEN '50001-100000'
        ELSE '100001+' 
    END AS goal_range,
    SUM(CASE WHEN state = 'successful' THEN 1 ELSE 0 END) * 100.0 / COUNT(projectID) AS successful_percentage
FROM 
    projects
GROUP BY 
    CASE 
        WHEN goal BETWEEN 0 AND 10000 THEN '0-10000'
        WHEN goal BETWEEN 10001 AND 50000 THEN '10001-50000'
        WHEN goal BETWEEN 50001 AND 100000 THEN '50001-100000'
        ELSE '100001+' 
    END
order by successful_percentage desc;