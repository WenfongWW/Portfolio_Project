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


-- How many accomdation with 0?
SELECT COUNT(accommodates) AS Count_accommodates
FROM [airbnb].dbo.listings
WHERE accommodates = 0 

-- How many price with 0?
SELECT COUNT(price) AS Count_price
FROM [airbnb].dbo.listings
WHERE price = 0 


-- Looking how many number for each room type 
SELECT room_type, COUNT(room_type) AS Count_room_type 
FROM [airbnb].[dbo].[listings]
GROUP BY room_type
ORDER BY Count_room_type DESC

--  How many number for each property type?
SELECT property_type, COUNT(property_type) AS Count_property_type 
FROM [airbnb].[dbo].[listings]
GROUP BY property_type
ORDER BY Count_property_type DESC

-- Calculate average nights booked 
SELECT AVG(30 - availability_30) AS avg_nights_booked 
FROM [airbnb].[dbo].[listings]

-- Calculate average price per night 
SELECT AVG(price) AS avg_price_per_night 
FROM [airbnb].[dbo].[listings]

-- Calculate average income 
SELECT AVG(price * (30 - availability_30)) AS avg_income 
FROM [airbnb].[dbo].[listings]

-- Most expensive average price ranges by Room types and Neighborhood 
SELECT top 5 room_type, neighbourhood_cleansed, AVG(price) AS avg_price
FROM [airbnb].dbo.listings
GROUP BY room_type, neighbourhood_cleansed
ORDER BY avg_price DESC

-- Least expensive average price ranges by Room and Neighborhood
SELECT top 5 room_type, neighbourhood_cleansed, AVG(price) AS avg_price
FROM [airbnb].dbo.listings
GROUP BY room_type, neighbourhood_cleansed
ORDER BY avg_price ASC


-- Occupancy Rate by Neighborhood 
-- Hightlight neighbourhood_cleansed with the highest and lowest occupancy rates. This will help understand demand across locations. 
SELECT neighbourhood_cleansed, AVG((30.0 - availability_30) / 30.0 * 100) AS avg_occupancy_rate
FROM [airbnb].[dbo].[listings]
GROUP BY neighbourhood_cleansed
ORDER BY avg_occupancy_rate DESC


-- Calculate the highest expensive mean price for each neighborhood and accommodates group
WITH MeanPrice AS (
	SELECT 
	neighbourhood_cleansed AS neighbourhood,
	accommodates,
	AVG(price) AS avg_price
	FROM [airbnb].dbo.listings
	GROUP BY neighbourhood_cleansed, accommodates
),

Most_Expensives_neighborhood AS (
	SELECT neighbourhood,
	accommodates,
	avg_price,
	ROW_NUMBER() OVER (PARTITION BY accommodates ORDER BY avg_price DESC) AS rank_row
	FROM MeanPrice
)

SELECT * 
FROM Most_Expensives_neighborhood
WHERE rank_row = 1
ORDER BY accommodates

-- Calculate the lowest expensive mean price for each neighborhood and accommodates group
WITH MeanPrice AS (
	SELECT 
	neighbourhood_cleansed AS neighbourhood,
	accommodates,
	AVG(price) AS avg_price
	FROM [airbnb].dbo.listings
	GROUP BY neighbourhood_cleansed, accommodates
),

Lowest_Expensives_neighborhood AS (
	SELECT neighbourhood,
	accommodates,
	avg_price,
	ROW_NUMBER() OVER (PARTITION BY accommodates ORDER BY avg_price ASC) AS rank_row
	FROM MeanPrice
)

SELECT * 
FROM Lowest_Expensives_neighborhood
WHERE rank_row = 1
ORDER BY accommodates


-- Top neighborhood based on average price and average reviews 
SELECT 
    neighbourhood_cleansed AS Neighborhood,
    ROUND(AVG(CAST(REPLACE(price, '$', '') AS FLOAT)), 2) AS Average_Price,
    ROUND(AVG(review_scores_rating), 2) AS Average_Reviews
FROM [airbnb].[dbo].[listings]
WHERE price IS NOT NULL AND reviews_per_month IS NOT NULL
GROUP BY neighbourhood_cleansed
ORDER BY Average_Price DESC, Average_Reviews DESC

-- What are the most common types of amenities that highly-rated properties offer?
WITH ParsedAmenities AS (
    SELECT
        l.id AS listing_id,
        l.review_scores_rating,
        TRIM(value) AS amenity
    FROM [airbnb].[dbo].[listings] AS l
    CROSS APPLY STRING_SPLIT(l.amenities, ',') AS s
    WHERE l.review_scores_rating > 4.5
)
SELECT amenity, COUNT(*) AS occurrence
FROM ParsedAmenities
GROUP BY amenity
ORDER BY occurrence DESC

-- Host performance analysis
SELECT 
    host_id, 
	room_type,
    COUNT(id) AS total_listings, 
    AVG(review_scores_rating) AS avg_review_score,
    AVG(price * (30 - availability_30)) AS avg_host_income,
	AVG(minimum_nights) AS avg_minimum_nights
FROM [airbnb].[dbo].[listings]
GROUP BY host_id, room_type
ORDER BY total_listings DESC


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
        AVG(price * (30 - availability_30)) AS avg_income
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
    AVG(CAST(price AS FLOAT) * (30 - availability_30)) AS avg_income, 
    AVG(CAST(review_scores_rating AS FLOAT)) AS avg_review_score
FROM [airbnb].[dbo].[listings]
GROUP BY neighbourhood_cleansed
ORDER BY avg_income DESC, avg_review_score DESC

