-- Step 1: Calculate the penetration rate for each state and vehicle category in FY 2024
WITH PenetrationRate AS (
    SELECT 
        evs.state, -- State name
        evs.vehicle_category, -- Vehicle category (e.g., 2-Wheelers, 4-Wheelers)
        SUM(evs.electric_vehicles_sold) AS Electric_Vehicles, -- Total number of EVs sold in the state
        SUM(evs.total_vehicles_sold) AS Total_Vehicles, -- Total number of vehicles (EV + non-EV) sold in the state
        (SUM(evs.electric_vehicles_sold) * 100) / SUM(evs.total_vehicles_sold) AS Penetration_Rate -- Calculate penetration rate
    FROM
        electric_vehicle_sales_by_state evs
    JOIN
        dim_date dd ON dd.date = evs.date -- Join with the date dimension to filter data by fiscal year
    WHERE
        dd.fiscal_year = 2024 -- Filter for fiscal year 2024
    GROUP BY
        evs.state, evs.vehicle_category -- Group data by state and vehicle category
),

-- Step 2: Rank states based on penetration rate within each vehicle category
RankedStates AS (
    SELECT 
        pr.state, -- State name
        pr.vehicle_category, -- Vehicle category
        pr.Penetration_Rate, -- Penetration rate for the state and category
        ROW_NUMBER() OVER (PARTITION BY pr.vehicle_category ORDER BY Penetration_Rate DESC) AS state_rank -- Assign rank based on penetration rate
    FROM 
        PenetrationRate pr
)

-- Step 3: Select the top 5 states with the highest penetration rates for each vehicle category
SELECT 
    rs.state, -- State name
    rs.vehicle_category, -- Vehicle category (e.g., 2-Wheelers, 4-Wheelers)
    rs.Penetration_Rate -- Penetration rate
FROM 
    RankedStates AS rs
WHERE 
    state_rank <= 5 -- Filter to include only the top 5 states in each category
ORDER BY
    rs.vehicle_category, -- Sort results by vehicle category
    state_rank; -- Sort within each category by rank
