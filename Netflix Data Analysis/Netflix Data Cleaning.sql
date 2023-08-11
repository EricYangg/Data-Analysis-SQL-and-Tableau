--Initial view of the dataset
Select *
From Netflix


--check for duplicate movie/show using show_id
----------------------------
Select show_id, count(*)
From Netflix
Group by show_id
Order By count(*)
--no duplicates found


--Checking for null values
----------------------------
Declare @tablename nvarchar(128) = 'Netflix'
Declare @sql nvarchar(max) = ''

Select @sql += 'Select ''' + column_name + ''' as column_name, count(*) as nullcount From ' + @tablename + ' Where ' + column_name + ' is null union all ' 
From INFORMATION_SCHEMA.columns
Where table_name = @tablename

--remove last 'union all' and execute query
Set @sql = Left(@sql, len(@sql) - len('union all '))

Exec sp_executesql @sql

/*
show_id	0
type	0
title	0
director	2634
cast	825
country	831
date_added	98
release_year	0
rating	4
duration	3
listed_in	0
description	0
*/


--There are a total of 8807 entries
--most null values from director, cast, and country
SELECT (COUNT(*) * 100.0) / (SELECT COUNT(*) FROM Netflix) AS percentage_total
FROM Netflix
WHERE director IS NULL
Or cast is null
or country is null


--Deal with null values
----------------------------
/*
40% of the entries have null director or cast or country
so removing the rows would remove a lot of data
director will be updated with 'No Director'
cast will be updated with 'No Cast'
country will be updated with 'No Country'
*/
Update Netflix 
Set director = COALESCE(director, 'No director'),
	cast = COALESCE(cast, 'No cast'),
	country = COALESCE(country, 'No country')
Where director is null or cast is null or country is null


--Delete remaining nulls
--since there aren't that many remaining nulls, will detele them
Delete From Netflix 
Where date_added is null
or rating is null
or duration is null


--Checking for null values
Declare @tablename nvarchar(128) = 'Netflix'
Declare @sql nvarchar(max) = ''

Select @sql += 'Select ''' + column_name + ''' as column_name, count(*) as nullcount From ' + @tablename + ' Where ' + column_name + ' is null union all ' 
From INFORMATION_SCHEMA.columns
Where table_name = @tablename

--remove last 'union all' and execute query
Set @sql = Left(@sql, len(@sql) - len('union all '))

Exec sp_executesql @sql

/*
show_id	0
type	0
title	0
director	0
cast	0
country	0
date_added	0
release_year	0
rating	0
duration	0
listed_in	0
description	0
*/
Select * From Netflix 


--Split multiple values in columns
--Columns of interest to split are director, cast, country and listed_in

--director
SELECT
    show_id,
    TRIM(value) AS director_name
FROM Netflix
CROSS APPLY STRING_SPLIT(director, ',');

--cast
SELECT
    show_id,
    TRIM(value) AS cast
FROM Netflix
CROSS APPLY STRING_SPLIT(cast, ',');

--country
SELECT
    show_id,
    TRIM(value) AS country
FROM Netflix
CROSS APPLY STRING_SPLIT(country, ',');

--listed_in
SELECT
    show_id,
    TRIM(value) AS genre
FROM Netflix
CROSS APPLY STRING_SPLIT(listed_in, ',');


-- Optional choice if wanting to create a new table with these queries instead 
-- Create a temporary table of the above data
CREATE TABLE #TempDirectors (
    show_id NVARCHAR(255),  -- Adjust the size as needed
    director_name NVARCHAR(255)  -- Adjust the size as needed
);

-- Insert data into the temporary table
INSERT INTO #TempDirectors (show_id, director_name)
SELECT
    show_id,
    TRIM(value) AS director_name
FROM Netflix
CROSS APPLY STRING_SPLIT(director, ',');

-- Query the temporary table
SELECT * FROM #TempDirectors;

-- Drop the temporary table when done
DROP TABLE #TempDirectors;

