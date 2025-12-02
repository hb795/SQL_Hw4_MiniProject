#Question 1

select Name, Max(DepDelayMinutes)
from FAA.al_perf, FAA.L_AIRLINE_ID
where DOT_ID_Reporting_Airline = ID
group by Name
order by Max(DepDelay) asc;

#15 rows Returned 

#Question 2
select Name, Min(DepDelay)
from FAA.al_perf, FAA.L_AIRLINE_ID
where DOT_ID_Reporting_Airline = ID
group by Name
order by min(DepDelay) asc;

#15 rows

#Question 3
select Day, count(*),
rank() over (order by count(*) desc) as DayRank
from FAA.al_perf, FAA.L_WEEKDAYS
where DayOfWeek = Code
group by Day
order by DayRank;
              
#7 rows

#Question 4
SELECT
    Name,
    Code,
    AVG(DepDelayMinutes) AS AvgDepartureDelay
FROM FAA.al_perf, FAA.L_AIRPORT
WHERE Origin = Code
GROUP BY Name, Code
ORDER BY AVG(DepDelayMinutes) DESC
LIMIT 1;

#1 row

#Question 5
CREATE TABLE step1_airline AS
SELECT
    f.OriginAirportID,
    a.Name AS AirlineName,
    f.DepDelayMinutes
FROM FAA.al_perf f,
     FAA.L_AIRLINE_ID a
WHERE f.DOT_ID_Reporting_Airline = a.ID;

SELECT * FROM step1_airline LIMIT 20;

CREATE TABLE step2_airport AS
SELECT
    s.AirlineName,
    ap.Name AS AirportName,
    s.DepDelayMinutes
FROM step1_airline s,
     FAA.L_AIRPORT_ID ap
WHERE s.OriginAirportID = ap.ID;

SELECT * FROM step2_airport LIMIT 20;

CREATE TABLE step3_avg AS
SELECT
    AirlineName,
    AirportName,
    AVG(DepDelayMinutes) AS AvgDelay
FROM step2_airport
GROUP BY AirlineName, AirportName;

SELECT * FROM step3_avg LIMIT 20;

CREATE TABLE step4_max AS
SELECT
    AirlineName,
    MAX(AvgDelay) AS MaxAvgDelay
FROM step3_avg
GROUP BY AirlineName;

SELECT
    s1.AirlineName,
    s1.AirportName,
    s1.AvgDelay AS HighestAvgDelay
FROM step3_avg s1,
     step4_max s2
WHERE s1.AirlineName = s2.AirlineName
  AND s1.AvgDelay = s2.MaxAvgDelay
ORDER BY s1.AirlineName;

#15 rows

#Question 6a
SELECT 
    COUNT(*) AS TotalFlights,
    SUM(Cancelled) AS TotalCancelledFlights
FROM FAA.al_perf;

#1 row

#Question 6b
CREATE TABLE step_cancelled AS
SELECT
    f.OriginAirportID,
    f.CancellationCode
FROM FAA.al_perf f
WHERE f.Cancelled = 1;

SELECT * FROM step_cancelled LIMIT 20;

CREATE TABLE cancel_reasons AS
SELECT
    ap.Name AS AirportName,
    c.Reason AS CancelReason
FROM step_cancelled s,
     FAA.L_AIRPORT_ID ap,
     FAA.L_CANCELATION c
WHERE s.OriginAirportID = ap.ID
  AND s.CancellationCode = c.Code;
  
  SELECT * FROM cancel_reasons LIMIT 20;
  
  CREATE TABLE step_cancel_counts AS
SELECT
    AirportName,
    CancelReason,
    COUNT(*) AS NumCancelled
FROM cancel_reasons
GROUP BY AirportName, CancelReason;

SELECT * FROM step_cancel_counts ORDER BY AirportName LIMIT 20;

CREATE TABLE step_cancel_max AS
SELECT
    AirportName,
    MAX(NumCancelled) AS MaxCancelCount
FROM step_cancel_counts
GROUP BY AirportName;

SELECT
    s1.AirportName,
    s1.CancelReason AS MostFrequentReason,
    s1.NumCancelled AS NumberOfCancellations
FROM step_cancel_counts s1,
     step_cancel_max s2
WHERE s1.AirportName = s2.AirportName
  AND s1.NumCancelled = s2.MaxCancelCount
ORDER BY s1.AirportName;

#275 rows

#Qustion 7
CREATE TABLE step_daily_flights AS
SELECT
    STR_TO_DATE(FlightDate, '%Y-%m-%d') AS FlightDate,
    COUNT(*) AS NumFlights
FROM FAA.al_perf
GROUP BY STR_TO_DATE(FlightDate, '%Y-%m-%d')
ORDER BY STR_TO_DATE(FlightDate, '%Y-%m-%d');

SELECT
    FlightDate,
    AVG(NumFlights) OVER (
        ORDER BY FlightDate
        ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING
    ) AS AvgFlightsLast3Days
FROM step_daily_flights;

#32 rows








