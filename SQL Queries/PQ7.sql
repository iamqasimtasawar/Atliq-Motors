-- Step 1: Calculate total vehicle sales for 2022 and 2024 for each state
WITH TotalSales_TopStates AS (
    SELECT 
        evs.state, -- State name
        -- Total vehicles sold in 2022
        SUM(CASE WHEN dd.fiscal_year = 2022 THEN evs.total_vehicles_sold ELSE 0 END) AS Sales_2022,
        -- Total vehicles sold in 2024
        SUM(CASE WHEN dd.fiscal_year = 2024 THEN evs.total_vehicles_sold ELSE 0 END) AS Sales_2024
    FROM 
        electric_vehicle_sales_by_state evs
    JOIN 
        dim_date dd
    ON 
        dd.date = evs.date
    WHERE 
        dd.fiscal_year BETWEEN 2022 AND 2024 -- Filter for years 2022 and 2024
    GROUP BY 
        evs.state -- Group by state
)

-- Step 2: Calculate CAGR and rank the top 10 states
SELECT 
    state, -- State name
    Sales_2022, -- Total vehicles sold in 2022
    Sales_2024, -- Total vehicles sold in 2024
    -- Calculate CAGR using the formula [(Ending Value / Beginning Value) ** (1/n)] - 1
    ROUND((POW(Sales_2024 * 1.0 / NULLIF(Sales_2022, 0), 1.0 / 2) - 1) * 100, 2) AS CAGR
FROM 
    TotalSales_TopStates
WHERE 
    Sales_2022 > 0 -- Exclude cases where Sales_2022 is zero to avoid division errors
ORDER BY 
    CAGR DESC -- Rank states by CAGR in descending order
LIMIT 10; -- Select the top 10 states
