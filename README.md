# Theatre Database System - CPSC 332 Project Part B

## Files

- **ddl.sql**: Creates database schema with all tables, constraints, and TICKET_AUDIT
- **seed.sql**: Populates database with 3 theatres, 10 auditoriums, 12 movies, 80 showtimes, 60 customers, and tickets
- **indexes.sql**: Creates 6 performance indexes for queries
- **views.sql**: Defines 3 reporting views (movie popularity, sold-out shows, theatre utilization)
- **procedures.sql**: Implements sell_ticket() stored procedure
- **triggers.sql**: Implements 3 triggers for validation and audit logging
- **backup.sql**: Creates backup tables for all data

## Load Steps

Execute SQL files in this order:

```bash
mysql -u root -p < ddl.sql
mysql -u root -p < seed.sql
mysql -u root -p < indexes.sql
mysql -u root -p < views.sql
mysql -u root -p < procedures.sql
mysql -u root -p < triggers.sql
```

## Test Queries

```sql
USE theatre_db;

-- 1. Check data loaded correctly
SELECT 'THEATRE' AS tbl, COUNT(*) FROM THEATRE
UNION ALL SELECT 'AUDITORIUM', COUNT(*) FROM AUDITORIUM
UNION ALL SELECT 'MOVIE', COUNT(*) FROM MOVIE
UNION ALL SELECT 'SHOWTIME', COUNT(*) FROM SHOWTIME
UNION ALL SELECT 'SEAT', COUNT(*) FROM SEAT
UNION ALL SELECT 'CUSTOMER', COUNT(*) FROM CUSTOMER
UNION ALL SELECT 'TICKET', COUNT(*) FROM TICKET;

-- 2. Test views
SELECT * FROM vw_movie_ticket_counts ORDER BY tickets_sold DESC LIMIT 5;
SELECT * FROM vw_sold_out_showtimes;
SELECT * FROM vw_theatre_utilization_next7;

-- 3. Test stored procedure
CALL sell_ticket(1, 'D', 8, 5, 'SENIOR15', @ticket_id);
SELECT @ticket_id;
SELECT * FROM TICKET WHERE ticket_id = @ticket_id;

-- 4. Test triggers (double-booking should fail)
CALL sell_ticket(1, 'D', 8, 6, NULL, @ticket_id2);

-- 5. Test refund trigger
UPDATE TICKET SET state = 'REFUNDED' WHERE ticket_id = @ticket_id;
SELECT * FROM TICKET_AUDIT WHERE ticket_id = @ticket_id;
```
