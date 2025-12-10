-- triggers.sql
USE theatre_db;

DELIMITER $$

-- TRIGGER 1: Enforce seat availability on INSERT

CREATE TRIGGER trg_ticket_before_insert
BEFORE INSERT ON TICKET
FOR EACH ROW
BEGIN
    DECLARE seat_exists INT;
    DECLARE ticket_exists INT;

    -- Check if the seat exists for this showtime
    SELECT COUNT(*) INTO seat_exists
    FROM SEAT
    WHERE showtime_id = NEW.seat_showtime_id
      AND row_label = NEW.seat_row_label
      AND seat_no = NEW.seat_no;

    IF seat_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Seat does not exist for this showtime';
    END IF;

    -- Check if ticket already exists for this seat
    SELECT COUNT(*) INTO ticket_exists
    FROM TICKET
    WHERE seat_showtime_id = NEW.seat_showtime_id
      AND seat_row_label = NEW.seat_row_label
      AND seat_no = NEW.seat_no;

    IF ticket_exists > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Seat already has a ticket - double booking not allowed';
    END IF;
END$$

-- TRIGGER 2: Log ticket creation to audit table

CREATE TRIGGER trg_ticket_after_insert
AFTER INSERT ON TICKET
FOR EACH ROW
BEGIN
    INSERT INTO TICKET_AUDIT (
        ticket_id,
        action_type,
        old_state,
        new_state,
        old_price,
        new_price,
        changed_at,
        note
    ) VALUES (
        NEW.ticket_id,
        'INSERT',
        NULL,
        NEW.state,
        NULL,
        NEW.final_price,
        NOW(),
        CONCAT('Ticket created for showtime ', NEW.showtime_id,
               ', seat ', NEW.seat_row_label, NEW.seat_no)
    );
END$$


-- TRIGGER 3: Handle ticket refunds and audit

CREATE TRIGGER trg_ticket_after_update
AFTER UPDATE ON TICKET
FOR EACH ROW
BEGIN
    -- Log any state change
    IF OLD.state <> NEW.state THEN
        INSERT INTO TICKET_AUDIT (
            ticket_id,
            action_type,
            old_state,
            new_state,
            old_price,
            new_price,
            changed_at,
            note
        ) VALUES (
            OLD.ticket_id,
            'UPDATE',
            OLD.state,
            NEW.state,
            OLD.final_price,
            NEW.final_price,
            NOW(),
            CASE
                WHEN NEW.state = 'REFUNDED' THEN
                    CONCAT('Ticket refunded - was ', OLD.state)
                ELSE
                    CONCAT('State changed from ', OLD.state, ' to ', NEW.state)
            END
        );
    END IF;

    -- Log price changes (even without state change)
    IF OLD.final_price <> NEW.final_price THEN
        INSERT INTO TICKET_AUDIT (
            ticket_id,
            action_type,
            old_state,
            new_state,
            old_price,
            new_price,
            changed_at,
            note
        ) VALUES (
            OLD.ticket_id,
            'UPDATE',
            OLD.state,
            NEW.state,
            OLD.final_price,
            NEW.final_price,
            NOW(),
            CONCAT('Price adjusted from ', OLD.final_price, ' to ', NEW.final_price)
        );
    END IF;
END$$

DELIMITER ;

-- End of triggers.sql
