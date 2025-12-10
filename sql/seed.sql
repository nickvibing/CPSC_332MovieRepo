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

-- 4. MOVIE (12 movies)

INSERT INTO MOVIE (title, mpaa_rating, release_date, runtime_min) VALUES
('Predator: Badlands',  'PG',    '2025-11-07', 110),
('Regretting You',      'PG-13', '2025-07-11', 128),
('Lilo & Stitch',       'R',     '2025-07-16', 95),
('Elio',                'PG-13', '2025-07-23', 140),
('Mision Impossible 07','PG',    '2024-07-02', 102),
('The Minecraft Movie', 'PG-13', '2025-10-17', 115),
('Skyrim',              'R',     '2025-07-01', 123),
('Run',                 'R',     '2024-06-11', 90),
('HTTYD',               'PG',    '2025-07-07', 105),
('Tron',                'PG-13', '2025-08-20', 132),
('Captain America',     'R',     '2025-09-10', 118),
('Zootopia',            'PG','2025-10-01', 98);

-- 5. SHOWTIME (80 showtimes EXACTLY)

INSERT INTO SHOWTIME (movie_id, auditorium_id, start_dt, end_dt, format, language, base_price)
SELECT
    ((ROW_NUMBER() OVER()) - 1) MOD 12 + 1 AS movie_id,
    a.auditorium_id,
    STR_TO_DATE(
        CONCAT('2025-11-', LPAD(19 + ((ROW_NUMBER() OVER()) - 1) DIV 10, 2, '0'), ' ',
               CASE WHEN a.auditorium_id <= 5 THEN '13:00:00' ELSE '16:00:00' END),
        '%Y-%m-%d %H:%i:%s'
    ) AS start_dt,
    STR_TO_DATE(
        CONCAT('2025-11-', LPAD(19 + ((ROW_NUMBER() OVER()) - 1) DIV 10, 2, '0'), ' ',
               CASE WHEN a.auditorium_id <= 5 THEN '15:00:00' ELSE '18:00:00' END),
        '%Y-%m-%d %H:%i:%s'
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
LIMIT 80;


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
WHERE
    -- Only create tickets for ~70-75% of seats (leave some unsold)
    (se.showtime_id + ASCII(se.row_label) + se.seat_no) MOD 4 != 0

