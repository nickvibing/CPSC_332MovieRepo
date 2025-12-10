-- indexes.sql
-- Additional indexes to support reporting views and common lookups

USE theatre_db;

-- 1. Filter showtimes by date (upcoming / next 7 days)
CREATE INDEX idx_showtime_start_dt
ON SHOWTIME(start_dt);

-- 2. Count purchased tickets per showtime
CREATE INDEX idx_ticket_showtime_state
ON TICKET(showtime_id, state);

-- 3. Get all seats for a showtime quickly
CREATE INDEX idx_seat_showtime_id
ON SEAT(showtime_id);

-- 4. Group tickets/showtimes by movie
CREATE INDEX idx_showtime_movie_id
ON SHOWTIME(movie_id);

-- 5. Get all auditoriums for a theatre
CREATE INDEX idx_auditorium_theatre_id
ON AUDITORIUM(theatre_id);

-- 6. Look up discounts by code in sell_ticket
CREATE INDEX idx_discount_code
ON DISCOUNT(code);
