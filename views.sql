-- views.sql
USE theatre_db;

-- 1. Top movies by tickets sold
CREATE OR REPLACE VIEW vw_movie_ticket_counts AS
SELECT
    m.movie_id,
    m.title,
    COUNT(t.ticket_id) AS tickets_sold
FROM MOVIE m
LEFT JOIN SHOWTIME s
    ON s.movie_id = m.movie_id
LEFT JOIN TICKET t
    ON t.showtime_id = s.showtime_id
   AND t.state = 'PURCHASED'
GROUP BY m.movie_id, m.title;

-- 2. Upcoming sold-out showtimes per theatre
CREATE OR REPLACE VIEW vw_sold_out_showtimes AS
SELECT
    th.theatre_id,
    th.name          AS theatre_name,
    au.auditorium_id,
    au.name_number   AS auditorium_name,
    s.showtime_id,
    s.start_dt,
    m.title,
    COUNT(DISTINCT se.row_label, se.seat_no) AS total_seats,
    SUM(CASE WHEN t.state = 'PURCHASED' THEN 1 ELSE 0 END) AS seats_sold
FROM SHOWTIME s
JOIN AUDITORIUM au       ON au.auditorium_id = s.auditorium_id
JOIN THEATRE th          ON th.theatre_id   = au.theatre_id
JOIN MOVIE m             ON m.movie_id      = s.movie_id
JOIN SEAT se             ON se.showtime_id  = s.showtime_id
LEFT JOIN TICKET t
    ON t.seat_showtime_id = se.showtime_id
   AND t.seat_row_label   = se.row_label
   AND t.seat_no          = se.seat_no
   AND t.state = 'PURCHASED'
WHERE s.start_dt > NOW()
GROUP BY th.theatre_id, th.name, au.auditorium_id, au.name_number,
         s.showtime_id, s.start_dt, m.title
HAVING seats_sold = total_seats;

-- 3. Theatre utilization next 7 days
CREATE OR REPLACE VIEW vw_theatre_utilization_next7 AS
SELECT
    th.theatre_id,
    th.name AS theatre_name,
    COUNT(DISTINCT se.showtime_id, se.row_label, se.seat_no) AS total_seat_instances,
    SUM(CASE WHEN t.state = 'PURCHASED' THEN 1 ELSE 0 END)   AS seats_sold,
    CASE
        WHEN COUNT(DISTINCT se.showtime_id, se.row_label, se.seat_no) = 0
        THEN 0
        ELSE ROUND(
            100.0 * SUM(CASE WHEN t.state = 'PURCHASED' THEN 1 ELSE 0 END)
            / COUNT(DISTINCT se.showtime_id, se.row_label, se.seat_no),
            2
        )
    END AS utilization_percent
FROM THEATRE th
JOIN AUDITORIUM au ON au.theatre_id = th.theatre_id
JOIN SHOWTIME s    ON s.auditorium_id = au.auditorium_id
JOIN SEAT se       ON se.showtime_id  = s.showtime_id
LEFT JOIN TICKET t
    ON t.seat_showtime_id = se.showtime_id
   AND t.seat_row_label   = se.row_label
   AND t.seat_no          = se.seat_no
   AND t.state = 'PURCHASED'
WHERE s.start_dt BETWEEN NOW() AND DATE_ADD(NOW(), INTERVAL 7 DAY)
GROUP BY th.theatre_id, th.name;
