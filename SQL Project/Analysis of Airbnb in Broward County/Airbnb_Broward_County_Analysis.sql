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
SELECT AVG(365 - availability_365) AS avg_nights_booked FROM [airbnb].[dbo].[listings]

-- Calculate average price per night 
SELECT AVG(price) AS avg_price_per_night FROM [airbnb].[dbo].[listings]

-- Calculate average income 
SELECT AVG(price * (365 - availability_365)) AS avg_income FROM [airbnb].[dbo].[listings]

-- Price Ranges by Room types and Neighborhood 
SELECT room_type, neighbourhood_cleansed, AVG(price) AS avg_price, AVG((30.0 - availability_30) / 30.0 * 100) AS avg_occupancy_rate
FROM [airbnb].dbo.listings
GROUP BY room_type, neighbourhood_cleansed
ORDER BY avg_price DESC, avg_occupancy_rate DESC

-- Occupancy Rate by Neighborhood 
-- Hightlight neighbourhood_cleansed with the highest and lowest occupancy rates. This will help understand demand across locations. 
SELECT neighbourhood_cleansed, AVG((30.0 - availability_30) / 30.0 * 100) AS avg_occupancy_rate
FROM [airbnb].[dbo].[listings]
GROUP BY neighbourhood_cleansed
ORDER BY avg_occupancy_rate DESC


-- Host performance analysis
SELECT 
    host_id, 
    COUNT(id) AS total_listings, 
    AVG(review_scores_rating) AS avg_review_score,
    AVG(price * (365 - availability_365)) AS avg_host_income
FROM [airbnb].[dbo].[listings]
GROUP BY host_id
ORDER BY avg_host_income DESC


-- Revenue maximization by price range
WITH price_brackets AS (
    SELECT 
        id, 
        CASE 
            WHEN price < 50 THEN 'Low'
            WHEN price BETWEEN 50 AND 100 THEN 'Medium'
            ELSE 'High' 
        END AS price_range, 
        price, 
        AVG(price * (365 - availability_365)) AS avg_income
    FROM [airbnb].[dbo].[listings]
    GROUP BY id, price
)
SELECT 
    price_range, 
    AVG(avg_income) AS avg_income_per_bracket
FROM price_brackets
GROUP BY price_range
ORDER BY avg_income_per_bracket DESC

-- Top performers by neighborhood
SELECT 
    neighbourhood_cleansed, 
    AVG(CAST(price AS FLOAT) * (365 - availability_365)) AS avg_income, 
    AVG(CAST(review_scores_rating AS FLOAT)) AS avg_review_score
FROM [airbnb].[dbo].[listings]
GROUP BY neighbourhood_cleansed
ORDER BY avg_income DESC, avg_review_score DESC




-- 3. Main Questions 
SELECT * FROM [airbnb].[dbo].[listings]

-- What is the optimal price range for listings in different neighborhoods to maximize occupancy rates?
SELECT neighbourhood_cleansed, price, AVG((30.0- availability_30) / 30.0 * 100) AS avg_occupancy_rate FROM [airbnb].[dbo].[listings]
GROUP BY neighbourhood_cleansed, price
ORDER BY price DESC

-- Are longer minimum stays more or less successful than short-term stays in terms of occupancy and revenue?
SELECT minimum_nights, 
	   AVG((30 - availability_30) / 30 * 100) AS avg_occupancy_rate, 
	   AVG(price * (30 - availability_30)) AS avg_income
FROM [airbnb].[dbo].[listings]
GROUP BY minimum_nights 
ORDER BY minimum_nights ASC

-- Which property types (apartment, house, etc.) are the most popular in terms of occupancy rate and revenue?
SELECT 
    property_type, 
    AVG((30.0 - availability_30) / 30.0 * 100) AS avg_occupancy_rate,
    AVG(price * (30 - availability_30)) AS avg_income
FROM [airbnb].[dbo].[listings]
GROUP BY property_type
ORDER BY avg_income DESC


-- How can you dynamically adjust prices to maximize both occupancy and revenue?
-- Adjusting prices based on current demand 
-- If availability_30 is low (high demand), increase the price to capitalize on demand. 
-- If availability_30 is high (low demand), decrease the price to capitalize on demand.
SELECT 
    id, 
    price, 
    availability_30, 
    CASE 
        WHEN (30 - availability_30) / 30.0 * 100 > 80 THEN price * 1.20 -- Increase price by 20% for high demand
        WHEN (30 - availability_30) / 30.0 * 100 < 40 THEN price * 0.80 -- Reduce price by 20% for low demand
        ELSE price 
    END AS dynamic_price
FROM [airbnb].[dbo].[listings]


-- Which amenities contribute most to higher occupancy and income?
SELECT amenities, 
	   AVG((30.0 - availability_30) / 30.0 * 100) AS avg_occupancy_rate,
	   AVG(price * (365 - availability_365)) AS avg_income 
FROM [airbnb].[dbo].[listings]
GROUP BY amenities
ORDER BY avg_income DESC
