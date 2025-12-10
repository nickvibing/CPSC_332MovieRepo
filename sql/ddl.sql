    -- ddl.sql

    -- Optional: drop and recreate the database for clean runs
    DROP DATABASE IF EXISTS theatre_db;
    CREATE DATABASE theatre_db
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_general_ci;

    USE theatre_db;

    -- Drop tables in dependency order (for reruns)
    DROP TABLE IF EXISTS TICKET;
    DROP TABLE IF EXISTS SEAT;
    DROP TABLE IF EXISTS DISCOUNT;
    DROP TABLE IF EXISTS CUSTOMER;
    DROP TABLE IF EXISTS SHOWTIME;
    DROP TABLE IF EXISTS SEAT_TYPE;
    DROP TABLE IF EXISTS MOVIE;
    DROP TABLE IF EXISTS AUDITORIUM;
    DROP TABLE IF EXISTS THEATRE;

    -- THEATRE
    CREATE TABLE THEATRE (
        theatre_id INT UNSIGNED AUTO_INCREMENT,
        name       VARCHAR(100) NOT NULL,
        address    VARCHAR(255) NOT NULL,
        PRIMARY KEY (theatre_id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

    -- AUDITORIUM
    CREATE TABLE AUDITORIUM (
        auditorium_id INT UNSIGNED AUTO_INCREMENT,
        theatre_id    INT UNSIGNED NOT NULL,
        name_number   VARCHAR(50) NOT NULL,
        capacity      INT UNSIGNED NOT NULL,
        PRIMARY KEY (auditorium_id),
        CONSTRAINT fk_auditorium_theatre
            FOREIGN KEY (theatre_id)
            REFERENCES THEATRE(theatre_id)
            ON DELETE RESTRICT
            ON UPDATE CASCADE,
        CONSTRAINT chk_auditorium_capacity
            CHECK (capacity > 0)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

    -- MOVIE
    CREATE TABLE MOVIE (
        movie_id     INT UNSIGNED AUTO_INCREMENT,
        title        VARCHAR(200) NOT NULL,
        mpaa_rating  VARCHAR(10)  NOT NULL,
        release_date DATE         NOT NULL,
        runtime_min  INT UNSIGNED NOT NULL,
        PRIMARY KEY (movie_id),
        CONSTRAINT chk_movie_runtime
            CHECK (runtime_min > 0)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

    -- SEAT_TYPE
    CREATE TABLE SEAT_TYPE (
        seat_type_id INT UNSIGNED AUTO_INCREMENT,
        label        VARCHAR(50)  NOT NULL,
        description  VARCHAR(255),
        base_price   DECIMAL(8,2) NOT NULL,
        PRIMARY KEY (seat_type_id),
        CONSTRAINT chk_seat_type_price
            CHECK (base_price >= 0)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

    -- SHOWTIME
    CREATE TABLE SHOWTIME (
        showtime_id   INT UNSIGNED AUTO_INCREMENT,
        movie_id      INT UNSIGNED NOT NULL,
        auditorium_id INT UNSIGNED NOT NULL,
        start_dt      DATETIME     NOT NULL,
        end_dt        DATETIME     NOT NULL,
        format        VARCHAR(20),
        language      VARCHAR(20),
        base_price    DECIMAL(8,2) NOT NULL,
        PRIMARY KEY (showtime_id),
        CONSTRAINT fk_showtime_movie
            FOREIGN KEY (movie_id)
            REFERENCES MOVIE(movie_id)
            ON DELETE RESTRICT
            ON UPDATE CASCADE,
        CONSTRAINT fk_showtime_auditorium
            FOREIGN KEY (auditorium_id)
            REFERENCES AUDITORIUM(auditorium_id)
            ON DELETE RESTRICT
            ON UPDATE CASCADE,
        CONSTRAINT chk_showtime_price
            CHECK (base_price >= 0),
        CONSTRAINT chk_showtime_time
            CHECK (end_dt > start_dt)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

    -- SEAT (weak entity: PK is (showtime_id, row_label, seat_no))
    CREATE TABLE SEAT (
        showtime_id  INT UNSIGNED NOT NULL,
        row_label    VARCHAR(10)  NOT NULL,
        seat_no      INT UNSIGNED NOT NULL,
        seat_type_id INT UNSIGNED NOT NULL,
        notes        VARCHAR(255),
        PRIMARY KEY (showtime_id, row_label, seat_no),
        CONSTRAINT fk_seat_showtime
            FOREIGN KEY (showtime_id)
            REFERENCES SHOWTIME(showtime_id)
            ON DELETE CASCADE
            ON UPDATE CASCADE,
        CONSTRAINT fk_seat_type
            FOREIGN KEY (seat_type_id)
            REFERENCES SEAT_TYPE(seat_type_id)
            ON DELETE RESTRICT
            ON UPDATE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

    -- CUSTOMER
    CREATE TABLE CUSTOMER (
        customer_id INT UNSIGNED AUTO_INCREMENT,
        email       VARCHAR(255) NOT NULL,
        phone       VARCHAR(30),
        PRIMARY KEY (customer_id),
        CONSTRAINT uq_customer_email UNIQUE (email)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

    -- DISCOUNT
    CREATE TABLE DISCOUNT (
        discount_id INT UNSIGNED AUTO_INCREMENT,
        code        VARCHAR(50)  NOT NULL,
        pct_off     DECIMAL(5,2) NOT NULL,
        PRIMARY KEY (discount_id),
        CONSTRAINT uq_discount_code UNIQUE (code),
        CONSTRAINT chk_discount_pct
            CHECK (pct_off >= 0 AND pct_off <= 100)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

    -- TICKET
    CREATE TABLE TICKET (
        ticket_id        INT UNSIGNED AUTO_INCREMENT,
        showtime_id      INT UNSIGNED NOT NULL,
        seat_showtime_id INT UNSIGNED NOT NULL,
        seat_row_label   VARCHAR(10)  NOT NULL,
        seat_no          INT UNSIGNED NOT NULL,
        customer_id      INT UNSIGNED,
        discount_id      INT UNSIGNED,
        purchase_dt      DATETIME     NOT NULL,
        state            VARCHAR(20)  NOT NULL,
        final_price      DECIMAL(8,2) NOT NULL,
        PRIMARY KEY (ticket_id),

        CONSTRAINT fk_ticket_showtime
            FOREIGN KEY (showtime_id)
            REFERENCES SHOWTIME(showtime_id)
            ON DELETE RESTRICT
            ON UPDATE CASCADE,

        CONSTRAINT fk_ticket_seat
            FOREIGN KEY (seat_showtime_id, seat_row_label, seat_no)
            REFERENCES SEAT(showtime_id, row_label, seat_no)
            ON DELETE RESTRICT
            ON UPDATE CASCADE,

        CONSTRAINT fk_ticket_customer
            FOREIGN KEY (customer_id)
            REFERENCES CUSTOMER(customer_id)
            ON DELETE SET NULL
            ON UPDATE CASCADE,

        CONSTRAINT fk_ticket_discount
            FOREIGN KEY (discount_id)
            REFERENCES DISCOUNT(discount_id)
            ON DELETE SET NULL
            ON UPDATE CASCADE,

        CONSTRAINT uq_ticket_seat_per_showtime
            UNIQUE (seat_showtime_id, seat_row_label, seat_no),

        CONSTRAINT chk_ticket_price
            CHECK (final_price >= 0),

        CONSTRAINT chk_ticket_state
            CHECK (state IN ('PENDING', 'PURCHASED', 'REFUNDED'))
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

    -- TICKET_AUDIT
    -- Tracks all ticket state changes for audit purposes
    CREATE TABLE TICKET_AUDIT (
        audit_id INT UNSIGNED AUTO_INCREMENT,
        ticket_id INT UNSIGNED NOT NULL,
        action_type ENUM('INSERT','UPDATE','DELETE') NOT NULL,
        old_state VARCHAR(20),
        new_state VARCHAR(20),
        old_price DECIMAL(8,2),
        new_price DECIMAL(8,2),
        changed_at DATETIME NOT NULL,
        note VARCHAR(255),
        PRIMARY KEY (audit_id),
        CONSTRAINT fk_audit_ticket
            FOREIGN KEY (ticket_id)
            REFERENCES TICKET(ticket_id)
            ON DELETE CASCADE
            ON UPDATE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

