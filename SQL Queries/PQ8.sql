-- Step 1: Aggregate monthly EV sales for the period 2022-2024
WITH MonthlySales AS (
    SELECT 
        MONTH(dd.date) AS Month_Number, -- Extract the month number from the date
        DATE_FORMAT(dd.date, '%M') AS Month_Name, -- Extract the full month name from the date
        SUM(evs.electric_vehicles_sold) AS Total_EV_Sales -- Total EV sales for the month
    FROM 
        dim_date dd
    JOIN 
        electric_vehicle_sales_by_state evs
    ON 
        dd.date = evs.date
    WHERE 
        dd.fiscal_year BETWEEN 2022 AND 2024 -- Filter data for 2022–2024
    GROUP BY 
        MONTH(dd.date), -- Group by month number
        DATE_FORMAT(dd.date, '%M') -- Group by month name
)

-- Step 2: Identify peak and low seasons
SELECT 
    Month_Name, -- Name of the month
    Total_EV_Sales, -- Total EV sales in the month
    CASE 
        WHEN Total_EV_Sales = (SELECT MAX(Total_EV_Sales) FROM MonthlySales) THEN 'Peak Season'
        WHEN Total_EV_Sales = (SELECT MIN(Total_EV_Sales) FROM MonthlySales) THEN 'Low Season'
        ELSE 'Regular Season'
    END AS Season_Type -- Categorize the season based on sales
FROM 
    MonthlySales
ORDER BY 
    Month_Number; -- Sort results by month number for chronological order
