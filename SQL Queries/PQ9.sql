-- Step 1: Calculate Penetration Rate and Identify Top 10 States
WITH StatePenetrationRate AS (
    SELECT 
        evs.state, -- State name
        SUM(evs.electric_vehicles_sold) AS Total_EV_Sales, -- Total EV sales for the state
        SUM(evs.total_vehicles_sold) AS Total_Vehicle_Sales, -- Total vehicle sales (including EVs and others)
        (SUM(evs.electric_vehicles_sold) * 100.0) / SUM(evs.total_vehicles_sold) AS Penetration_Rate -- Percentage of EVs sold
    FROM 
        electric_vehicle_sales_by_state evs
    JOIN 
        dim_date dd
    ON 
        dd.date = evs.date -- Joining to align sales data with date information
    WHERE 
        dd.fiscal_year BETWEEN 2022 AND 2024 -- Focus only on the specified fiscal years
    GROUP BY 
        evs.state -- Group by state to calculate penetration rate for each state
    ORDER BY 
        Penetration_Rate DESC -- Order by highest penetration rate
    LIMIT 10 -- Keep only the top 10 states with the highest penetration rates
),

-- Step 2: Calculate CAGR for EV Sales in Top 10 States
StateCAGR AS (
    SELECT 
        evs.state, -- State name
        SUM(CASE WHEN dd.fiscal_year = 2022 THEN evs.electric_vehicles_sold ELSE 0 END) AS Sales_2022, -- EV sales in 2022
        SUM(CASE WHEN dd.fiscal_year = 2024 THEN evs.electric_vehicles_sold ELSE 0 END) AS Sales_2024, -- EV sales in 2024
        -- Calculate CAGR using the formula
        ROUND(POW(SUM(CASE WHEN dd.fiscal_year = 2024 THEN evs.electric_vehicles_sold ELSE 0 END) * 1.0 / 
                 SUM(CASE WHEN dd.fiscal_year = 2022 THEN evs.electric_vehicles_sold ELSE 0 END), 
                 1.0 / 2) - 1, 4) AS CAGR -- Compound annual growth rate rounded to 4 decimal places
    FROM 
        electric_vehicle_sales_by_state evs
    JOIN 
        dim_date dd
    ON 
        dd.date = evs.date -- Joining to align sales data with date information
    WHERE 
        evs.state IN (SELECT state FROM StatePenetrationRate) -- Restrict to top 10 states by penetration rate
        AND dd.fiscal_year BETWEEN 2022 AND 2024 -- Focus only on the specified fiscal years
    GROUP BY 
        evs.state -- Group by state to calculate CAGR for each state
),

-- Step 3: Project EV Sales for 2030
ProjectedSales2030 AS (
    SELECT 
        state, -- State name
        Sales_2024, -- Latest sales figure from 2024
        CAGR, -- Compound annual growth rate
        -- Project sales for 2030 using the formula: Sales_2024 * (1 + CAGR)^(2030 - 2024)
        ROUND(Sales_2024 * POW(1 + CAGR, 2030 - 2024)) AS Projected_Sales_2030 -- Projected EV sales for 2030
    FROM 
        StateCAGR
)

-- Final Output: Top 10 States and Projected EV Sales for 2030
SELECT 
    state, -- State name
    Sales_2024 AS Latest_Sales, -- Latest EV sales figure from 2024
    CAGR AS Growth_Rate, -- Compound annual growth rate
    Projected_Sales_2030 AS Projected_Sales -- Projected EV sales for 2030
FROM 
    ProjectedSales2030
ORDER BY 
    Projected_Sales DESC; -- Order by projected sales in descending order
