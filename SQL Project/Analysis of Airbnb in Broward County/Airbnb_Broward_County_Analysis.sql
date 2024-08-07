SELECT * FROM [airbnb].[dbo].[listings]

-- 1. Data Cleaning 

--Drop irrelevant columns 
-- ALTER TABLE [airbnb].[dbo].[listings] DROP COLUMN scrape_id
-- ALTER TABLE [airbnb].[dbo].[listings] DROP COLUMN source
-- ALTER TABLE [airbnb].[dbo].[listings] DROP COLUMN last_scraped
-- ALTER TABLE [airbnb].[dbo].[listings] DROP COLUMN neighbourhood_group_cleansed
-- ALTER TABLE [airbnb].[dbo].[listings] DROP COLUMN neighbourhood
-- ALTER TABLE [airbnb].[dbo].[listings] DROP COLUMN bathrooms_text
-- ALTER TABLE [airbnb].[dbo].[listings] DROP COLUMN calendar_updated
-- ALTER TABLE [airbnb].[dbo].[listings] DROP COLUMN license

-- Check for Missing values 

SELECT 
    COUNT(*) AS total_count,
	SUM(CASE WHEN description IS NULL THEN 1 ELSE 0 END) AS description_missing,
    SUM(CASE WHEN neighborhood_overview IS NULL THEN 1 ELSE 0 END) AS neighborhood_overview_missing,
	SUM(CASE WHEN host_about IS  NULL THEN 1 ELSE 0 END) AS host_about_missing,
	SUM(CASE WHEN host_neighbourhood IS NULL THEN 1 ELSE 0 END) AS host_neighbourhood_missing,
    SUM(CASE WHEN reviews_per_month IS NULL THEN 1 ELSE 0 END) AS reviews_per_month_missing,
	SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END) AS price_missing
FROM [airbnb].[dbo].[listings]

-- Fill in the missing values 
UPDATE [airbnb].[dbo].[listings]
SET description = 'No Description'
WHERE description IS NULL

UPDATE [airbnb].[dbo].[listings]
SET 








