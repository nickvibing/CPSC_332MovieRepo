USE theatre_db;

-- 1. THEATRE (3+)


INSERT INTO THEATRE (name, address) VALUES
('Harkins Theatres Chino Hills', '3070 Chino Ave, Chino Hills, CA 91709, CA'),
('Cinemark Chino Movies',  '5546 Philadelphia St, Chino, CA 91710, CA'),
('101 Cinema Club', '15101 Fairfield Ranch Rd Ste0, Chino Hills, CA91709, CA');

-- 2. AUDITORIUM (10 total)

INSERT INTO AUDITORIUM (theatre_id, name_number, capacity) VALUES
(1, 'Aud 1', 96),
(1, 'Aud 2', 120),
(1, 'Aud 3', 80),
(2, 'Aud 1', 150),
(2, 'Aud 2', 120),
(2, 'Aud 3', 96),
(2, 'Aud 4', 80),
(3, 'Aud 1', 120),
(3, 'Aud 2', 96),
(3, 'Aud 3', 80);

-- 3. SEAT_TYPE (4 types)

INSERT INTO SEAT_TYPE (label, description, base_price) VALUES
('Standard', 'Standard seating',          0.00),
('Premium',  'Wider recliner seating',    2.00),
('ADA',      'Accessible seating',        0.00),
('Love Seat','Two-seat couch style seat', 3.00);

-- 4. MOVIE (25 movies)

INSERT INTO MOVIE (title, mpaa_rating, release_date, runtime_min) VALUES
('Predator: Badlands',  'PG',    '2025-11-07', 110),
('Regretting You',      'PG-13', '2025-07-11', 128),
('Lilo & Stitch',       'R',     '2025-07-16', 95),
('Elio',                'PG-13', '2025-07-23', 140),
('Mission Impossible 07','PG',   '2024-07-02', 102),
('The Minecraft Movie', 'PG-13', '2025-10-17', 115),
('Skyrim',              'R',     '2025-07-01', 123),
('Run',                 'R',     '2024-06-11', 90),
('How to Train Dragon', 'PG',    '2025-07-07', 105),
('Tron: Legacy',        'PG-13', '2025-08-20', 132),
('Captain America',     'R',     '2025-09-10', 118),
('Zootopia 2',          'PG',    '2025-10-01', 98),
('Deadpool & Wolverine','R',     '2025-11-15', 128),
('Moana 2',             'PG',    '2025-11-20', 110),
('Wicked',              'PG',    '2025-11-22', 155),
('Gladiator III',       'R',     '2025-11-25', 142),
('The Wild Robot',      'PG',    '2025-10-12', 102),
('Sonic 3',             'PG',    '2024-12-20', 99),
('Nosferatu',           'R',     '2024-12-25', 131),
('Mufasa: The Lion King','PG',   '2024-12-20', 118),
('Homestead',           'PG-13', '2025-11-14', 112),
('A Minecraft Movie 2', 'PG-13', '2025-12-10', 120),
('Avatar 4',            'PG-13', '2025-12-18', 165),
('Interstellar 2',      'PG-13', '2025-11-18', 138),
('The Last Jedi',       'PG-13', '2025-12-15', 152);

-- 5. SHOWTIME (250+ showtimes across 30 days)

INSERT INTO SHOWTIME (movie_id, auditorium_id, start_dt, end_dt, format, language, base_price)
SELECT
    ((n - 1) MOD 25) + 1 AS movie_id,
    a.auditorium_id,
    TIMESTAMP(
        DATE_ADD('2025-12-09', INTERVAL ((n - 1) DIV 10) DAY),
        CASE 
            WHEN a.auditorium_id IN (1,6) THEN '10:00:00'
            WHEN a.auditorium_id IN (2,7) THEN '13:00:00'
            WHEN a.auditorium_id IN (3,8) THEN '16:00:00'
            WHEN a.auditorium_id IN (4,9) THEN '19:00:00'
            ELSE '21:30:00'
        END
    ) AS start_dt,
    TIMESTAMP(
        DATE_ADD('2025-12-09', INTERVAL ((n - 1) DIV 10) DAY),
        CASE 
            WHEN a.auditorium_id IN (1,6) THEN '12:15:00'
            WHEN a.auditorium_id IN (2,7) THEN '15:15:00'
            WHEN a.auditorium_id IN (3,8) THEN '18:15:00'
            WHEN a.auditorium_id IN (4,9) THEN '21:15:00'
            ELSE '23:45:00'
        END
    ) AS end_dt,
    CASE
        WHEN a.auditorium_id IN (5,7) THEN 'IMAX'
        WHEN a.auditorium_id IN (2,4,6,8,10) THEN '3D'
        ELSE '2D'
    END AS format,
    'EN' AS language,
    CASE
        WHEN a.auditorium_id IN (5,7) THEN 16.00
        WHEN a.auditorium_id IN (2,4,6,8,10) THEN 12.50
        ELSE 10.00
    END AS base_price
FROM AUDITORIUM a
CROSS JOIN (
    SELECT 1 n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 
    UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10
    UNION ALL SELECT 11 UNION ALL SELECT 12 UNION ALL SELECT 13 UNION ALL SELECT 14 UNION ALL SELECT 15
    UNION ALL SELECT 16 UNION ALL SELECT 17 UNION ALL SELECT 18 UNION ALL SELECT 19 UNION ALL SELECT 20
    UNION ALL SELECT 21 UNION ALL SELECT 22 UNION ALL SELECT 23 UNION ALL SELECT 24 UNION ALL SELECT 25
    UNION ALL SELECT 26 UNION ALL SELECT 27 UNION ALL SELECT 28 UNION ALL SELECT 29 UNION ALL SELECT 30
    UNION ALL SELECT 31 UNION ALL SELECT 32 UNION ALL SELECT 33 UNION ALL SELECT 34 UNION ALL SELECT 35
    UNION ALL SELECT 36 UNION ALL SELECT 37 UNION ALL SELECT 38 UNION ALL SELECT 39 UNION ALL SELECT 40
    UNION ALL SELECT 41 UNION ALL SELECT 42 UNION ALL SELECT 43 UNION ALL SELECT 44 UNION ALL SELECT 45
    UNION ALL SELECT 46 UNION ALL SELECT 47 UNION ALL SELECT 48 UNION ALL SELECT 49 UNION ALL SELECT 50
    UNION ALL SELECT 51 UNION ALL SELECT 52 UNION ALL SELECT 53 UNION ALL SELECT 54 UNION ALL SELECT 55
    UNION ALL SELECT 56 UNION ALL SELECT 57 UNION ALL SELECT 58 UNION ALL SELECT 59 UNION ALL SELECT 60
) AS days(n)
LIMIT 600;


--    col_nums: A..J  (seat numbers)

DROP TABLE IF EXISTS row_nums;
DROP TABLE IF EXISTS col_nums;

CREATE TABLE row_nums (
    n TINYINT UNSIGNED PRIMARY KEY
);

CREATE TABLE col_nums (
    n TINYINT UNSIGNED PRIMARY KEY
);

INSERT INTO row_nums (n) VALUES
(1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12);

INSERT INTO col_nums (n) VALUES
(1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12),(13),(14),(15),(16),(17),(18),(19),(20);

-- 7. SEAT (multiple auditorium sizes)
--    Three different auditorium sizes based on capacity:
--    Small (80-96):  8 rows × 12 seats = 96 seats
--    Medium (120):   10 rows × 16 seats = 160 seats
--    Large (150):    12 rows × 20 seats = 240 seats
--
--    Seat types:
--       rows 1-2: Premium
--       last row: ADA
--       others:  Standard

-- Small auditoriums (capacity 80-96): 8×12 grid
INSERT INTO SEAT (showtime_id, row_label, seat_no, seat_type_id)
SELECT
    s.showtime_id,
    CHAR(64 + r.n) AS row_label,
    c.n            AS seat_no,
    CASE
        WHEN r.n BETWEEN 1 AND 2 THEN 2
        WHEN r.n = 8 THEN 3
        ELSE 1
    END
FROM SHOWTIME s
JOIN AUDITORIUM a ON a.auditorium_id = s.auditorium_id
CROSS JOIN row_nums r
CROSS JOIN col_nums c
WHERE a.capacity BETWEEN 80 AND 96
  AND r.n <= 8
  AND c.n <= 12;

-- Medium auditoriums (capacity 120): 10×16 grid
INSERT INTO SEAT (showtime_id, row_label, seat_no, seat_type_id)
SELECT
    s.showtime_id,
    CHAR(64 + r.n) AS row_label,
    c.n            AS seat_no,
    CASE
        WHEN r.n BETWEEN 1 AND 2 THEN 2
        WHEN r.n = 10 THEN 3
        ELSE 1
    END
FROM SHOWTIME s
JOIN AUDITORIUM a ON a.auditorium_id = s.auditorium_id
CROSS JOIN row_nums r
CROSS JOIN col_nums c
WHERE a.capacity = 120
  AND r.n <= 10
  AND c.n <= 16;

-- Large auditoriums (capacity 150): 12×20 grid
INSERT INTO SEAT (showtime_id, row_label, seat_no, seat_type_id)
SELECT
    s.showtime_id,
    CHAR(64 + r.n) AS row_label,
    c.n            AS seat_no,
    CASE
        WHEN r.n BETWEEN 1 AND 2 THEN 2
        WHEN r.n = 12 THEN 3
        ELSE 1
    END
FROM SHOWTIME s
JOIN AUDITORIUM a ON a.auditorium_id = s.auditorium_id
CROSS JOIN row_nums r
CROSS JOIN col_nums c
WHERE a.capacity = 150
  AND r.n <= 12
  AND c.n <= 20;


-- 8. CUSTOMER (60 customers, auto-generated)

SET @cust_i := 0;

INSERT INTO CUSTOMER (email, phone)
SELECT
    CONCAT('First_Last', @cust_i := @cust_i + 1, '@example.com') AS email,
    CONCAT('909-555-', LPAD(@cust_i, 4, '0'))              AS phone
FROM row_nums r
CROSS JOIN col_nums c
LIMIT 60;

-- 9. DISCOUNT (4 discounts)

INSERT INTO DISCOUNT (code, pct_off) VALUES
('STUDENT5', 5.00),
('SENIOR15',  15.00),
('BULK20',    20.00),
('PROMO5',     5.00);

-- 10. TICKET (partial occupancy - leaves some seats unsold)
--     Generate tickets for approximately 70-75% of available seats
--     to satisfy "ensure some seats remain unsold" requirement.
--     Uses RAND() with seed for reproducible results.


SET @t_i := 0;

INSERT INTO TICKET (
    showtime_id,
    seat_showtime_id,
    seat_row_label,
    seat_no,
    customer_id,
    discount_id,
    purchase_dt,
    state,
    final_price
)
SELECT
    se.showtime_id,
    se.showtime_id,
    se.row_label,
    se.seat_no,
    ((@t_i := @t_i + 1) MOD 60) + 1 AS customer_id,
    CASE
        WHEN MOD(@t_i, 20) = 0 THEN 1   -- every 20th ticket gets STUDENT5
        WHEN MOD(@t_i, 30) = 0 THEN 2   -- every 30th ticket gets SENIOR15
        ELSE NULL
    END AS discount_id,
    NOW() AS purchase_dt,
    'PURCHASED' AS state,
    sh.base_price + st.base_price AS final_price
FROM SEAT se
JOIN SHOWTIME sh   ON sh.showtime_id   = se.showtime_id
JOIN SEAT_TYPE st  ON st.seat_type_id  = se.seat_type_id
LEFT JOIN (
    SELECT showtime_id FROM SHOWTIME 
    WHERE start_dt BETWEEN '2025-12-10' AND '2025-12-15 23:59:59'
    ORDER BY showtime_id ASC
    LIMIT 2
) reserved ON sh.showtime_id = reserved.showtime_id
WHERE
    -- Only create tickets for ~70-75% of seats (leave some unsold)
    (se.showtime_id + ASCII(se.row_label) + se.seat_no) MOD 4 != 0
    -- Exclude first 2 showtimes in Dec 10-15 range (reserve for sold-out demo)
    AND reserved.showtime_id IS NULL;

-- 11. Sold-out showtimes (for testing reports)
--     Sell 100% of seats for first 2 showtimes in Dec 10-15 range
SET @soldout_i := 0;

INSERT INTO TICKET (
    showtime_id,
    seat_showtime_id,
    seat_row_label,
    seat_no,
    customer_id,
    discount_id,
    purchase_dt,
    state,
    final_price
)
SELECT
    se.showtime_id,
    se.showtime_id,
    se.row_label,
    se.seat_no,
    ((@soldout_i := @soldout_i + 1) MOD 60) + 1 AS customer_id,
    NULL AS discount_id,
    NOW() AS purchase_dt,
    'PURCHASED' AS state,
    sh.base_price + st.base_price AS final_price
FROM SEAT se
JOIN SHOWTIME sh   ON sh.showtime_id   = se.showtime_id
JOIN SEAT_TYPE st  ON st.seat_type_id  = se.seat_type_id
JOIN (
    SELECT showtime_id FROM SHOWTIME 
    WHERE start_dt BETWEEN '2025-12-10' AND '2025-12-15 23:59:59'
    ORDER BY showtime_id ASC
    LIMIT 2
) sold_out ON sh.showtime_id = sold_out.showtime_id

