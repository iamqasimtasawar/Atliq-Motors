-- Step 1: Identify the top 5 EV makers based on total sales volume from 2022 to 2024
WITH TotalSales AS (
    SELECT 
        evm.maker, -- Name of the EV maker
        SUM(evm.electric_vehicles_sold) AS Total_Sales -- Total sales volume across all years
    FROM 
        dim_date dd
    JOIN 
        electric_vehicle_sales_by_makers evm
    ON 
        dd.date = evm.date
    WHERE 
        dd.fiscal_year BETWEEN 2022 AND 2024 -- Filter for fiscal years 2022 to 2024
        AND evm.vehicle_category = '4-Wheelers' -- Include only 4-wheelers
    GROUP BY 
        evm.maker
    ORDER BY 
        Total_Sales DESC -- Order by total sales in descending order
    LIMIT 5 -- Select the top 5 EV makers
),

-- Step 2: Calculate quarterly trends for the top 5 EV makers
QuarterlyTrends AS (
    SELECT 
        evm.maker, -- Name of the EV maker
        dd.fiscal_year, -- Fiscal year
        dd.quarter, -- Fiscal quarter (Q1, Q2, Q3, Q4)
        SUM(evm.electric_vehicles_sold) AS Quarterly_Sales -- Total sales for the quarter
    FROM 
        dim_date dd
    JOIN 
        electric_vehicle_sales_by_makers evm
    ON 
        dd.date = evm.date
    WHERE 
        dd.fiscal_year BETWEEN 2022 AND 2024 -- Filter for fiscal years 2022 to 2024
        AND evm.vehicle_category = '4-Wheelers' -- Include only 4-wheelers
        AND evm.maker IN (SELECT maker FROM TotalSales) -- Include only top 5 makers
    GROUP BY 
        dd.fiscal_year, 
        dd.quarter, 
        evm.maker -- Group by year, quarter, and maker
    ORDER BY 
        evm.maker, -- Sort by EV maker
        dd.fiscal_year, -- Then by fiscal year
        dd.quarter -- Then by quarter
)

-- Step 3: Display the quarterly sales trends for the top 5 makers
SELECT 
    maker, -- Name of the EV maker
    fiscal_year, -- Fiscal year
    quarter, -- Fiscal quarter
    Quarterly_Sales -- Sales volume for the quarter
FROM 
    QuarterlyTrends;
