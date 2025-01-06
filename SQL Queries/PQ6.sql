-- Step 1: Identify the top 5 EV makers based on total sales (2022–2024)
WITH TotalSales_TopMakers AS (
    SELECT 
        evm.maker, -- EV maker name
        -- Calculate total sales for the year 2022
        SUM(CASE WHEN dd.fiscal_year = 2022 THEN evm.electric_vehicles_sold ELSE 0 END) AS Sales_2022,
        -- Calculate total sales for the year 2024
        SUM(CASE WHEN dd.fiscal_year = 2024 THEN evm.electric_vehicles_sold ELSE 0 END) AS Sales_2024,
        -- Calculate total sales for the entire period (2022–2024)
        SUM(evm.electric_vehicles_sold) AS Total_Sales
    FROM 
        electric_vehicle_sales_by_makers evm
    JOIN 
        dim_date dd
    ON 
        dd.date = evm.date
    WHERE 
        dd.fiscal_year BETWEEN 2022 AND 2024
        AND evm.vehicle_category = '4-Wheelers' -- Filter for 4-wheelers
    GROUP BY 
        evm.maker
    ORDER BY 
        Total_Sales DESC -- Rank by total sales in descending order
    LIMIT 5 -- Retain only the top 5 makers
)

-- Step 2: Calculate CAGR for the top 5 EV makers
SELECT 
    maker, -- EV maker name
    Sales_2022, -- Total EV sales in 2022
    Sales_2024, -- Total EV sales in 2024
    Total_Sales, -- Total sales over the entire period (2022–2024)
    -- Calculate CAGR using the formula [(Ending Value / Beginning Value) ** (1/n)] - 1
    ROUND((POW(Sales_2024 * 1.0 / Sales_2022, 1.0 / 2) - 1) * 100, 2) AS CAGR
FROM 
    TotalSales_TopMakers
ORDER BY 
    CAGR DESC; -- Order results by CAGR in descending order
