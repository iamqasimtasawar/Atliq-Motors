-- Step 1: Calculate Total Revenue for 2022, 2023, and 2024
WITH RevenueByYear AS (
    SELECT 
        evm.vehicle_category, -- Vehicle category: 4-Wheelers or 2-Wheelers
        dd.fiscal_year, -- Fiscal year: 2022, 2023, or 2024
        SUM(evm.electric_vehicles_sold) AS Total_Sales, -- Total EV sales for the year
        -- Calculate total revenue using updated average prices
        CASE 
            WHEN evm.vehicle_category = '4-Wheelers' THEN SUM(evm.electric_vehicles_sold) * 1300000 -- ₹1,300,000 per 4-wheeler
            WHEN evm.vehicle_category = '2-Wheelers' THEN SUM(evm.electric_vehicles_sold) * 700000 -- ₹700,000 per 2-wheeler
        END AS Total_Revenue -- Total revenue for the year
    FROM 
        electric_vehicle_sales_by_makers evm
    JOIN 
        dim_date dd
    ON 
        dd.date = evm.date -- Joining sales data with the date dimension
    WHERE 
        dd.fiscal_year BETWEEN 2022 AND 2024 -- Filter data for the specified fiscal years
    GROUP BY 
        evm.vehicle_category, dd.fiscal_year -- Group by vehicle category and fiscal year
),

-- Step 2: Calculate Revenue Growth Rates
GrowthRates AS (
    SELECT 
        r1.vehicle_category, -- Vehicle category: 4-Wheelers or 2-Wheelers
        r1.fiscal_year AS Current_Year, -- Current year
        r1.Total_Revenue AS Current_Revenue, -- Revenue for the current year
        r2.fiscal_year AS Previous_Year, -- Previous year
        r2.Total_Revenue AS Previous_Revenue, -- Revenue for the previous year
        -- Calculate the revenue growth rate
        ROUND(((r1.Total_Revenue - r2.Total_Revenue) * 100.0 / r2.Total_Revenue), 2) AS Growth_Rate_Percent -- Growth rate rounded to 2 decimal places
    FROM 
        RevenueByYear r1
    JOIN 
        RevenueByYear r2
    ON 
        r1.vehicle_category = r2.vehicle_category -- Match the same vehicle category
        AND r1.fiscal_year = r2.fiscal_year + 1 -- Compare consecutive years: (2023 vs 2022, 2024 vs 2023)
)

-- Final Output: Revenue Growth Rates
SELECT 
    vehicle_category, -- Vehicle category: 4-Wheelers or 2-Wheelers
    Current_Year, -- Current year
    Previous_Year, -- Previous year
    Current_Revenue, -- Revenue for the current year
    Previous_Revenue, -- Revenue for the previous year
    Growth_Rate_Percent AS Revenue_Growth_Rate -- Revenue growth rate between the years
FROM 
    GrowthRates
ORDER BY 
    vehicle_category, Current_Year; -- Order by vehicle category and fiscal year
