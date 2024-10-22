# Airbnb Listings SQL Project - Broward County Analysis

## Overview
This project focuses on analyzing Airbnb listings in Broward County using SQL to derive insights on occupancy rates, pricing, host performance, and dynamic pricing strategies. The objective is to optimize both revenue and occupancy for Airbnb hosts by analyzing the key factors influencing booking trends.

## Steps Involved

### 1. Data Cleaning
- **Irrelevant columns** were removed, such as `scrape_id`, `source`, `license`, and others.
- **Missing values** in columns like `description`, `price`, `availability_30` were identified and handled:
  - Filled missing `price` with the average price from the dataset.
  - Replaced missing text fields (`description`, `neighborhood_overview`, `host_about`) with default placeholders.
- **Duplicates** were removed by identifying rows with the same `id` using a `ROW_NUMBER()` CTE query.

### 2. Data Exploration
- **Room Type Distribution**: Counted the number of listings for each room type.
- **Average Nights Booked**: Computed the average number of nights booked annually.
- **Average Price per Night**: Calculated the average price per listing.
- **Average Income per Listing**: Used availability data to estimate income using `(365 - availability_365)`.

### 3. Key Questions Explored
- **Price Ranges by Room Type and Neighborhood**: Identified the average price and occupancy rates across room types and neighborhoods.
- **Occupancy Rate by Neighborhood**: Analyzed neighborhoods with the highest and lowest occupancy rates.
- **Host Performance**: Evaluated hosts based on the number of listings they manage, their review scores, and their income.
- **Revenue Maximization by Price Range**: Grouped listings into price brackets to see which price ranges maximize revenue.
- **Top Performing Neighborhoods**: Analyzed which neighborhoods generate the highest income and have the best reviews.

### 4. Advanced Analysis
- **Optimal Price Range for Maximum Occupancy**: Determined the price ranges that yield the highest occupancy rates in different neighborhoods.
- **Long-Term vs. Short-Term Stays**: Compared the occupancy rates and revenue for listings with longer minimum stays vs. shorter ones.
- **Property Type Performance**: Identified which property types (e.g., houses, apartments) have the best occupancy and income performance.
- **Dynamic Pricing Strategy**: Implemented a dynamic pricing algorithm that adjusts prices based on occupancy rates:
  - Increase price by 20% if the occupancy rate is above 80%.
  - Decrease price by 20% if the occupancy rate is below 40%.
- **Amenities Impact**: Analyzed which amenities lead to higher occupancy and income, helping hosts improve their listings.
