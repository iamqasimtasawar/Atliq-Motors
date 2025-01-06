-- Step 1: Calculate Penetration Rate for the years 2022 and 2024
WITH PenetrationRate AS (
    SELECT 
        evs.state, -- State name
        dd.fiscal_year, -- Fiscal year
        SUM(evs.electric_vehicles_sold) AS Electric_Vehicles_Sold, -- Total EVs sold
        SUM(evs.total_vehicles_sold) AS Total_Vehicles_Sold, -- Total vehicles sold (EV + non-EV)
        -- Calculate the penetration rate as a percentage
        (SUM(evs.electric_vehicles_sold) * 100) / SUM(evs.total_vehicles_sold) AS Penetration_Rate
    FROM 
        electric_vehicle_sales_by_state evs
    JOIN 
        dim_date dd
    ON 
        dd.date = evs.date
    WHERE 
        dd.fiscal_year IN (2022, 2024) -- Focus on the years 2022 and 2024
    GROUP BY 
        evs.state, dd.fiscal_year
),

-- Step 2: Analyze the decline in penetration rate between 2022 and 2024
DeclineAnalysis AS (
    SELECT 
        pr_2022.state, -- State name
        pr_2022.Penetration_Rate AS Penetration_Rate_2022, -- Penetration rate in 2022
        pr_2024.Penetration_Rate AS Penetration_Rate_2024, -- Penetration rate in 2024
        -- Calculate the decline in penetration rate
        pr_2024.Penetration_Rate - pr_2022.Penetration_Rate AS Penetration_Decline
    FROM 
        PenetrationRate pr_2022
    JOIN 
        PenetrationRate pr_2024
    ON 
        pr_2022.state = pr_2024.state -- Match states between 2022 and 2024
        AND pr_2022.fiscal_year = 2022 -- Filter for 2022 data
        AND pr_2024.fiscal_year = 2024 -- Filter for 2024 data
)

-- Step 3: Select states with a negative penetration decline
SELECT 
    state, -- State name
    Penetration_Rate_2022, -- Penetration rate in 2022
    Penetration_Rate_2024, -- Penetration rate in 2024
    Penetration_Decline -- Decline in penetration rate
FROM 
    DeclineAnalysis
ORDER BY 
    Penetration_Decline ASC; -- Order by largest decline first
