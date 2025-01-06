-- Step 1: Create a Common Table Expression (CTE) to rank makers based on sales
WITH RankedMakers AS (
    SELECT 
        em.maker, -- Name of the manufacturer
        dd.fiscal_year, -- Fiscal year of the sales data
        em.vehicle_category, -- Vehicle category (e.g., 2-Wheelers)
        SUM(em.electric_vehicles_sold) AS Vehicle_Sold, -- Total electric vehicles sold by the maker
        ROW_NUMBER() OVER (
            PARTITION BY dd.fiscal_year 
            ORDER BY SUM(em.electric_vehicles_sold) DESC
        ) AS rank_desc, -- Rank based on descending order of sales
        ROW_NUMBER() OVER (
            PARTITION BY dd.fiscal_year 
            ORDER BY SUM(em.electric_vehicles_sold) ASC
        ) AS rank_asc -- Rank based on ascending order of sales
    FROM
        dim_date dd
    JOIN
        electric_vehicle_sales_by_makers em 
    ON 
        dd.date = em.date -- Join condition: Matching dates between tables
    WHERE
        em.vehicle_category = '2-Wheelers' -- Filter for 2-Wheelers only
        AND dd.fiscal_year IN (2023, 2024) -- Consider data for fiscal years 2023 and 2024
    GROUP BY 
        dd.fiscal_year, em.maker -- Group data by fiscal year and maker
)

-- Step 2: Select the top 3 and bottom 3 makers for each fiscal year
SELECT 
    maker, -- Name of the manufacturer
    fiscal_year, -- Fiscal year of the sales data
    vehicle_category, -- Vehicle category (e.g., 2-Wheelers)
    Vehicle_Sold, -- Total number of vehicles sold
    CASE
        WHEN rank_desc <= 3 THEN 'TOP' -- Label as 'TOP' if in top 3 by sales
        WHEN rank_asc <= 3 THEN 'BOTTOM' -- Label as 'BOTTOM' if in bottom 3 by sales
        ELSE NULL -- No label otherwise
    END AS Position -- Indicates whether the maker is in 'TOP' or 'BOTTOM'
FROM 
    RankedMakers
WHERE 
    rank_desc <= 3 OR rank_asc <= 3 -- Filter for only top 3 and bottom 3 makers
ORDER BY 
    fiscal_year, -- Sort results by fiscal year
    CASE 
        WHEN Position = 'TOP' THEN 1 -- Ensure 'TOP' appears before 'BOTTOM'
        WHEN Position = 'BOTTOM' THEN 2 
        ELSE 3 
    END,
    Vehicle_Sold DESC; -- Sort by sales in descending order within each position
