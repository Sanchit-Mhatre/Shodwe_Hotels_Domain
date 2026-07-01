CREATE DATABASE shodwe_hotel_db;
USE shodwe_hotel_db;

CREATE TABLE dim_date (
  date        DATE         PRIMARY KEY,
  mmm_yy      VARCHAR(20),
  week_no     VARCHAR(20),
  day_type    VARCHAR(20)
);

CREATE TABLE dim_hotels (
 property_id INT PRIMARY KEY,
 property_name VARCHAR(100),
 category VARCHAR(50),
 city VARCHAR(50)

);

CREATE TABLE dim_rooms (
 room_id VARCHAR(10) PRIMARY KEY,
 room_class VARCHAR(50)
);

CREATE TABLE fact_aggregated_bookings(
 property_id INT,
 check_in_date DATE,
 room_category VARCHAR(10),
 successful_bookings INT,
 capacity INT,
 remaining_rooms INT,
 FOREIGN KEY(property_id) REFERENCES dim_hotels(property_id),
 FOREIGN KEY(check_in_date) REFERENCES dim_date(date),
  FOREIGN KEY(room_category) REFERENCES dim_rooms(room_id)
);

desc fact_aggregated_bookings;

CREATE TABLE fact_bookings (
  booking_id          VARCHAR(20)  PRIMARY KEY,
  property_id         INT,
  booking_date        DATE,
  check_in_date       DATE,
  checkout_date       DATE,
  no_guests           INT,
  room_category       VARCHAR(10),
  booking_platform    VARCHAR(50),
  ratings_given       INT,
  booking_status      VARCHAR(20),
  revenue_generated   INT,
  revenue_realized    INT,
  customer_id         INT,
  payment_method      VARCHAR(30),
  stay_duration       INT,
  cancellation_reason VARCHAR(100),
  is_loyalty_member   TINYINT(1),
  country             VARCHAR(50),
  customer_age        INT,
  special_requests    VARCHAR(100),
  discount_applied    DECIMAL(5,2),
  booking_channel     VARCHAR(50),
  FOREIGN KEY (property_id)   REFERENCES dim_hotels(property_id),
  FOREIGN KEY (check_in_date)  REFERENCES dim_date(date),
  FOREIGN KEY (room_category)  REFERENCES dim_rooms(room_id)
);

ALTER TABLE fact_bookings 
MODIFY COLUMN is_loyalty_member VARCHAR(5);

describe fact_bookings;


SELECT COUNT(*) FROM dim_date; -- 92
SELECT COUNT(*) FROM dim_hotels; -- 25
SELECT COUNT(*) FROM dim_rooms; -- 4
SELECT COUNT(*) FROM fact_aggregated_bookings; -- 9200
SELECT COUNT(*) FROM fact_bookings; -- 134590

-- Total revenue realized from all checked-out bookings


-- KPI  : TOTAL REVENUE
SELECT
    SUM(revenue_realized) AS total_revenue
FROM fact_bookings;

-- % of available rooms that were successfully booked



-- KPI  : UTILIZED CAPACITY (OCCUPANCY RATE %)
SELECT
    ROUND(
        SUM(successful_bookings) / SUM(capacity) * 100, 2) AS occupancy_rate_pct
FROM fact_aggregated_bookings;

-- % of total bookings that were cancelled


-- KPI 3 : CANCELLATION RATE %
SELECT
    ROUND(
        COUNT(CASE WHEN booking_status = 'Cancelled' THEN 1 END) /
        COUNT(booking_id) * 100,
    2) AS cancellation_rate_pct
FROM fact_bookings;

-- KPI 3 : CANCELLATION RATE % INDETAIL
SELECT
    COUNT(booking_id)     AS Total_Bookings,
    COUNT(CASE WHEN booking_status = 'Cancelled' THEN 1 END)       AS Total_Cancelled_Bookings,
    ROUND(
        COUNT(CASE WHEN booking_status = 'Cancelled' THEN 1 END) /
        COUNT(booking_id) * 100, 2)     AS Cancellation_Rate_Pct
FROM fact_bookings;

-- Count of all reservations regardless of status

-- KPI 4 : TOTAL BOOKINGS
SELECT
    COUNT(booking_id)       AS total_bookings,
    COUNT(CASE WHEN booking_status = 'Checked Out' THEN 1 END) AS checked_out,
    COUNT(CASE WHEN booking_status = 'Cancelled'   THEN 1 END) AS cancelled,
    COUNT(CASE WHEN booking_status = 'No Show'     THEN 1 END) AS no_show
FROM fact_bookings;
-- ─────────────────────────────────────────────
CREATE TABLE KPI5 AS

-- KPI 5 : UTILIZED CAPACITY (Available Rooms)
SELECT
    SUM(capacity)              AS Total_Capacity,
    SUM(successful_bookings)   AS Total_Booked_Rooms,
    SUM(remaining_rooms)       AS Total_Available_Rooms
FROM fact_aggregated_bookings;



-- KPI ADDITIONAL : REVENUE LOST (LEAKAGE) -- KPI ADDITIONAL-- KPI ADDITIONAL-- KPI ADDITIONAL
-- Revenue lost due to cancellations and no-shows

SELECT
    SUM(revenue_generated - revenue_realized) AS revenue_lost
FROM fact_bookings
WHERE booking_status IN ('Cancelled', 'No Show');


-- KPI 6 : TREND ANALYSIS (Weekly)
-- ─────────────────────────────────────────────


SELECT
    d.week_no                                                             AS Week_No,
    COUNT(fb.booking_id)                                                  AS Total_Bookings,
    SUM(fb.revenue_realized)                                              AS Weekly_Revenue,
    ROUND(SUM(fab.successful_bookings) / SUM(fab.capacity) * 100, 2)     AS Occupancy_Rate_Pct,
    ROUND(
        SUM(fb.revenue_realized) /
        NULLIF(COUNT(CASE WHEN fb.booking_status = 'Checked Out' THEN 1 END), 0),
    2)                                                                    AS ADR,
    ROUND(
        SUM(fb.revenue_realized) / NULLIF(SUM(fab.capacity), 0),
    2)                                                                    AS RevPAR
FROM fact_bookings fb
JOIN dim_date d
    ON DATE(fb.check_in_date) = d.date
JOIN fact_aggregated_bookings fab
    ON fb.property_id          = fab.property_id
    AND DATE(fb.check_in_date) = fab.check_in_date
    AND fb.room_category       = fab.room_category
GROUP BY d.week_no
ORDER BY d.week_no;

-- KPI 7 : WEEKDAY & WEEKEND REVENUE AND BOOKINGS
-- ─────────────────────────────────────────────
DROP TABLE IF EXISTS KPI7;

CREATE TABLE KPI7 AS
SELECT
    d.day_type                              AS Day_Type,
    COUNT(fb.booking_id)                    AS Total_Bookings,
    SUM(fb.revenue_generated)               AS Total_Revenue
FROM fact_bookings fb
JOIN dim_date d
    ON DATE(fb.check_in_date) = d.date
GROUP BY d.day_type;

SELECT * FROM KPI7;

-- KPI 8 : REVENUE BY STATE & HOTEL
SELECT
    h.city                        AS City,
    h.property_name               AS Hotel_Name,
    h.category                    AS Hotel_Category,
    SUM(fb.revenue_realized)      AS Total_Revenue,
    COUNT(fb.booking_id)          AS Total_Bookings
FROM fact_bookings fb
JOIN dim_hotels h
    ON fb.property_id = h.property_id
GROUP BY h.city, h.property_name, h.category
ORDER BY city ASC,Total_Revenue DESC;
 
SELECT * FROM KPI8;


-- KPI 9 : CLASS WISE REVENUE
SELECT
    r.room_class                      AS Room_Class,
    COUNT(fb.booking_id)                     AS Total_Bookings,
    SUM(fb.revenue_realized)                   AS Total_Revenue,
    SUM(fb.revenue_generated)                   AS Actual_Total_Revenue,
    ROUND(
        SUM(fb.revenue_realized) /
        (SELECT SUM(revenue_realized) FROM fact_bookings) * 100, 2)      AS Revenue_Pct
FROM fact_bookings fb
JOIN dim_rooms r
    ON fb.room_category = r.room_id
GROUP BY r.room_class
ORDER BY Total_Revenue DESC;


-- KPI 10 : CHECKED OUT / CANCELLED / NO SHOW
SELECT
    booking_status                                                        AS Booking_Status,
    COUNT(booking_id)                                                     AS Total_Bookings,
    ROUND(COUNT(booking_id) / (SELECT COUNT(*) FROM fact_bookings) * 100, 2) AS Status_Pct
FROM fact_bookings
GROUP BY booking_status;
 
-- ADDITIONAL- 2 --------- : BOOKING % BY PLATFORM
SELECT
    booking_platform,
    COUNT(booking_id)                                               AS Total_Bookings,
    ROUND(COUNT(booking_id) /
        (SELECT COUNT(*) FROM fact_bookings) * 100, 2)             AS Booking_Pct
FROM fact_bookings
GROUP BY booking_platform
ORDER BY Booking_Pct DESC;


-- ADDITIONAL- 3 --------- : AVERAGE RATING
SELECT
    h.property_name,ROUND(AVG(ratings_given), 2) AS Average_Rating
FROM fact_bookings fb
join dim_hotels h
on fb.property_id = h.property_id
WHERE booking_status = 'Checked Out'
AND ratings_given > 0
group by property_name;

-- ADDITIONAL- -------- 4 : RevPAR
-- ─────────────────────────────────────────────
CREATE TABLE METRIC_REVPAR AS
SELECT
    ROUND(
        (SELECT SUM(revenue_realized) FROM fact_bookings) /
        SUM(capacity), 2)                                           AS RevPAR
FROM fact_aggregated_bookings;