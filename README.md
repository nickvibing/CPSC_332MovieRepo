# Movie Theatre Ticket System

A flat PHP web application for browsing movies, selecting showtimes, purchasing tickets, and managing refunds using an existing movie theatre database.

## Prerequisites

- PHP 7.4+
- MySQL 5.7+
- A web server (Apache, Nginx, or PHP built-in server)

## Installation & Setup

### 1. Database Setup

Run the SQL files in this exact order to initialize the database:

```bash
mysql -u root -p < sql/ddl.sql
mysql -u root -p < sql/seed.sql
mysql -u root -p < sql/indexes.sql
mysql -u root -p < sql/views.sql
mysql -u root -p < sql/procedures.sql
mysql -u root -p < sql/triggers.sql
```

This will:
- Create the `theatre_db` database with all necessary tables
- Insert sample data (3 theatres, 10 auditoriums, 12 movies, 80 showtimes, etc.)
- Create performance indexes
- Create reporting views
- Create the `sell_ticket()` stored procedure
- Set up audit triggers for tickets

### 2. Configure Database Connection

Edit `includes/config.php` and update the database credentials:

```php
'db' => [
    'host'   => 'localhost',
    'port'   => 3306,
    'user'   => 'root',        // Your MySQL username
    'pass'   => '',            // Your MySQL password
    'dbname' => 'theatre_db',
],
```

### 3. Web Server Setup

**Using PHP built-in server:**
```bash
cd public
php -S localhost:8000
```

Then visit: `http://localhost:8000/index.php`

**Using Apache/Nginx:**
Point your document root to the `public` directory in this project.

## Directory Structure

```
project-partc/
├── public/                 # Web-accessible pages
│   ├── index.php          # Landing page with quick showtime finder
│   ├── movies.php         # Browse & filter movies, movie details
│   ├── showtimes.php      # Find showtimes by theatre & date
│   ├── seats.php          # Interactive seat map for a showtime
│   ├── purchase.php       # POST handler for ticket purchase
│   ├── my_tickets.php     # Look up tickets by email or ID
│   ├── refund.php         # POST handler for ticket refund
│   └── reports.php        # Reports (top movies, sold-out shows, utilization)
├── includes/              # Shared PHP code
│   ├── config.php         # Database & app configuration
│   ├── db.php             # PDO database connection
│   ├── functions.php      # Helper functions (esc, csrf, param, etc.)
│   ├── header.php         # HTML header & navigation
│   └── footer.php         # HTML footer
├── assets/
│   └── styles.css         # Complete CSS styling
├── sql/                   # Database schema & data (do not modify)
│   ├── ddl.sql           # Tables & constraints
│   ├── seed.sql          # Sample data
│   ├── indexes.sql       # Performance indexes
│   ├── views.sql         # Reporting views
│   ├── procedures.sql    # Stored procedures
│   ├── triggers.sql      # Audit & validation triggers
│   └── backup.sql        # Backup tables
└── README.md             # This file
```

## Features

### 1. Browse Movies
- **Movies page** (`movies.php`): List all movies or filter by:
  - MPAA rating (G, PG, PG-13, R)
  - Theatre location
- **Movie details**: Click a movie to see:
  - Movie info (rating, runtime, release date)
  - All showtimes at different theatres
  - Links to select seats

### 2. Showtime Finder
- **Showtimes page** (`showtimes.php`): Search by:
  - Theatre location
  - Date (date picker)
  - Optional: specific movie
- Shows:
  - Movie title, format (2D/3D/IMAX), language
  - Start time, auditorium, base price
  - Seat availability count
  - **"Sold Out"** indicator for fully booked shows

### 3. Seat Selection & Purchase
- **Seat map** (`seats.php`): Interactive grid layout showing:
  - **Green seats**: Available (clickable)
  - **Red seats**: Sold (disabled, non-clickable)
  - Row and seat numbers
  - Screen orientation
  - Legend explaining seat states
- **Purchase form**:
  - Select one seat via radio button (keyboard-navigable)
  - Enter email (required, validated)
  - Enter phone (optional)
  - Choose discount code (optional) from valid codes:
    - `STUDENT5` (5% off)
    - `SENIOR15` (15% off)
    - `BULK20` (20% off)
    - `PROMO5` (5% off)
  - Displays base price + seat surcharge + discount calculation
  - CSRF protection on the form

### 4. Ticket Purchase Processing
- **Purchase handler** (`purchase.php`):
  - Validates email format
  - Creates customer record if new
  - Calls `sell_ticket()` stored procedure to:
    - Verify seat exists and is available
    - Calculate final price (showtime base + seat type surcharge - discount)
    - Insert ticket record
  - Returns **confirmation page** with:
    - Confirmation number (ticket ID)
    - Full booking details
    - Final price
    - Link to "My Tickets"
  - **Error handling**:
    - "Seat already sold" → User selects another
    - "Invalid discount code" → Friendly error message
    - Database errors → User-friendly messages

### 5. My Tickets
- **Lookup page** (`my_tickets.php`):
  - Search by email address (shows all tickets)
  - Or search by ticket ID
  - Displays table with:
    - Ticket ID, movie, theatre, date/time, seat, price
    - Status badge: **PURCHASED** (green) or **REFUNDED** (red)
- **Refund button** (if PURCHASED):
  - POST to `refund.php`
  - Updates ticket state to **REFUNDED**
  - Triggers audit log
  - Shows confirmation page

### 6. Reports (Read-Only)
- **Reports page** (`reports.php`) displays three views:
  1. **Top Movies by Tickets Sold** (vw_movie_ticket_counts)
     - Shows movies with highest ticket sales
  2. **Sold-Out Showtimes** (vw_sold_out_showtimes)
     - Upcoming showtimes with 100% seat occupancy
  3. **Theatre Utilization (Next 7 Days)** (vw_theatre_utilization_next7)
     - Seat occupancy % per theatre

## Database Schema Highlights

### Key Tables
- **THEATRE**: Cinema locations
- **AUDITORIUM**: Screens within theatres (varying capacities: 80, 96, 120, 150 seats)
- **MOVIE**: Films with MPAA ratings
- **SHOWTIME**: Movie + Auditorium + Date/Time
- **SEAT**: Individual seats (weak entity: showtime, row, seat_no)
- **CUSTOMER**: Email + optional phone
- **TICKET**: Transaction record with price, state (PURCHASED/REFUNDED), discount
- **TICKET_AUDIT**: Audit trail of all ticket changes
- **DISCOUNT**: Code + % off

### Important Constraints
- Seats are soft-deleted via state change on TICKET (no physical deletion)
- Unique constraint: one ticket per seat per showtime
- TICKET.state IN ('PENDING', 'PURCHASED', 'REFUNDED')
- All seat surcharges and discounts applied via `sell_ticket()` procedure
- Triggers log all state & price changes to TICKET_AUDIT

## Security Features

1. **CSRF Protection**: All POST forms include CSRF tokens
2. **SQL Injection Prevention**: PDO prepared statements everywhere
3. **XSS Protection**: All output escaped with `htmlspecialchars` via `esc()` helper
4. **Email Validation**: `FILTER_VALIDATE_EMAIL` on purchase
5. **Session Management**: CSRF tokens stored in `$_SESSION`
6. **Error Handling**: User-friendly messages, no raw SQL errors

## Code Quality

- **Flat PHP architecture**: No frameworks, clean separation of concerns
- **Includes**:
  - `config.php`: Configuration (no hardcoded secrets)
  - `db.php`: PDO connection with error handling
  - `functions.php`: Reusable helpers (esc, csrf, param, etc.)
  - `header.php` & `footer.php`: Shared HTML templates
- **Public pages**: Focused on orchestration + rendering
- **Naming conventions**: Consistent, descriptive, readable
- **Comments**: Added where logic is non-obvious

## Testing & Demo Walkthrough

### Sample Test Flow

1. **Start**: Open `http://localhost:8000/index.php`

2. **Browse Movies**:
   - Click "Browse Movies" in navigation
   - Filter by rating (e.g., "PG-13")
   - Click on "Elio" to see details

3. **Find Showtimes**:
   - On movie detail, click "Select Seats" for any showtime
   - Or use homepage quick search:
     - Theatre: "Harkins Theatres Chino Hills"
     - Date: 2025-11-19 (date from seeded data)
     - Click "Find Showtimes"

4. **Select Seat & Purchase**:
   - Click "Select Seats" on a showtime
   - Review seat map (green = available, red = sold)
   - Click a green seat to select
   - Enter email: `test@example.com` (or use existing `First_Last*@example.com`)
   - Optionally select discount: `STUDENT5` (5% off)
   - Click "Complete Purchase"
   - See confirmation page with ticket ID and final price

5. **Look Up Ticket**:
   - Click "My Tickets" in navigation
   - Search by email: `test@example.com`
   - See your purchased ticket in the table
   - Click "Refund" button to request refund
   - Ticket state changes to **REFUNDED**
   - View audit log if desired

6. **View Reports**:
   - Click "Reports" in navigation
   - See:
     - Top-selling movies
     - Sold-out showtimes (if any)
     - Theatre utilization percentages

### Seeded Sample Data

**Sample Customers** (60 created):
- `First_Last1@example.com` through `First_Last60@example.com`
- Phones: `909-555-0001` through `909-555-0060`

**Sample Movies** (12):
- Predator: Badlands (PG), Lilo & Stitch (R), Elio (PG-13), etc.

**Sample Theatres** (3):
- Harkins Theatres Chino Hills
- Cinemark Chino Movies
- 101 Cinema Club

**Sample Discounts**:
- STUDENT5: 5% off
- SENIOR15: 15% off
- BULK20: 20% off
- PROMO5: 5% off

**Sample Showtimes** (80):
- November 19–28, 2025
- Multiple formats: 2D, 3D, IMAX
- Price ranges: $10–$16 base

## Troubleshooting

### Database Connection Error
- Check `includes/config.php` credentials match your MySQL setup
- Ensure `theatre_db` database was created successfully
- Verify MySQL is running

### SQL Errors on Procedure Call
- Ensure `procedures.sql` was loaded after `ddl.sql`
- Check that the `sell_ticket()` procedure exists: `SHOW PROCEDURE STATUS WHERE DB='theatre_db';`

### Seat Map Not Loading
- Verify seats were created in seed.sql
- Check that the showtime_id exists and has an auditorium

### Session/CSRF Issues
- Ensure PHP sessions are enabled
- Clear browser cookies/session if testing repeatedly

## Performance Considerations

- **Indexes**: Composite indexes on foreign keys and showtime.start_dt
- **Views**: Pre-computed for reports page
- **Pagination**: Not implemented (assume <10k records); add LIMIT if needed
- **Database**: Supports concurrent ticket purchases via triggers and unique constraints

## Future Enhancements (Not Implemented)

- Payment gateway integration (currently simulated)
- Email notifications
- Admin dashboard for theatre management
- Advanced filtering (genre, runtime, etc.)
- Seat type selection (premium, ADA, etc.)
- Bulk discounts/group bookings
- User accounts & login

## License

This is an educational project for a assignment.
=======
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
