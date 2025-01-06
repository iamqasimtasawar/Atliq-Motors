-- Step 1: Calculate EV sales, total vehicle sales, and penetration rates for Delhi and Karnataka
WITH Total_Sales AS (
    SELECT 
        evs.state, -- State name
        SUM(evs.electric_vehicles_sold) AS Total_EV_Sales, -- Total EV sales
        SUM(evs.total_vehicles_sold) AS Total_Vehicles_Sold, -- Total vehicle sales
        (SUM(evs.electric_vehicles_sold) * 100.0) / SUM(evs.total_vehicles_sold) AS Penetration_Rate -- Penetration rate
    FROM 
        dim_date dd
    JOIN 
        electric_vehicle_sales_by_state evs
    ON 
        dd.date = evs.date
    WHERE 
        dd.fiscal_year = 2024 -- Filter for the fiscal year 2024
        AND evs.state IN ('Delhi', 'Karnataka') -- Focus on Delhi and Karnataka
    GROUP BY 
        evs.state -- Group data by state
)

-- Step 2: Select and display the results
SELECT 
    state, -- State name
    Total_EV_Sales, -- Total EV sales
    Penetration_Rate -- Penetration rate
FROM 
    Total_Sales
ORDER BY 
    Penetration_Rate DESC; -- Sort by penetration rate for better comparison
