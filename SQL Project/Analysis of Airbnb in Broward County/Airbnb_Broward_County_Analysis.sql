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
	SUM(CASE WHEN availability_30 IS NULL THEN 1 ELSE 0 END) AS availabilty_30_missing,
	SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END) AS price_missing
FROM [airbnb].[dbo].[listings]

-- Fill in the missing values 
UPDATE [airbnb].[dbo].[listings]
SET description = 'No Description'
WHERE description IS NULL

UPDATE [airbnb].[dbo].[listings]
SET neighborhood_overview = 'No overview provided'
WHERE neighborhood_overview IS NULL 

UPDATE [airbnb].[dbo].[listings]
SET host_about = 'No host information'
WHERE host_about IS NULL 

UPDATE [airbnb].[dbo].[listings]
SET host_neighbourhood = 'No host neighbourhood information'
WHERE host_neighbourhood IS NULL 

UPDATE [airbnb].[dbo].[listings]
SET price = (SELECT AVG(price) FROM [airbnb].[dbo].listings)
WHERE price IS NULL


-- Check for Duplicates
;WITH CTE AS (
	SELECT id, ROW_NUMBER() OVER (PARTITION BY id ORDER BY id) AS row_num
	FROM [airbnb].[dbo].[listings]
)
DELETE FROM CTE
WHERE row_num > 1;

SELECT id, COUNT(*) AS count FROM [airbnb].[dbo].[listings]
GROUP BY id
HAVING COUNT(*) > 1

-- 2.Data Exploration 

-- Looking how many number for each room type 
SELECT room_type, COUNT(room_type) as Count_room_type FROM [airbnb].[dbo].[listings]
GROUP BY room_type
ORDER BY Count_room_type DESC

-- Calculate average nights booked 
SELECT AVG(365 - availability_365) AS avg_nights_booked FROM [airbnb].[dbo].[listings];

-- Calculate average price per night 
SELECT AVG(price) AS avg_price_per_nigh FROM [airbnb].[dbo].[listings];

-- 






-- 3. Main Questions 
SELECT * FROM [airbnb].[dbo].[listings]

-- What is the optimal price range for listings in different neighborhoods to maximize occupancy rates?
SELECT neighbourhood_cleansed, price, AVG((30.0- availability_30) / 30.0 * 100) AS avg_occupancy_rate FROM [airbnb].[dbo].[listings]
GROUP BY neighbourhood_cleansed, price
ORDER BY neighbourhood_cleansed, price

-- 
SELECT 
    price,
    AVG((30.0 - availability_30) / 30.0 * 100) AS avg_occupancy_rate,
    AVG(price * (30.0 - availability_30) / 30.0 * 100) AS avg_revenue
FROM [airbnb].[dbo].[listings]
GROUP BY price
ORDER BY price;






