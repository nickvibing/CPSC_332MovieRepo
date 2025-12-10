-- procedures.sql
USE theatre_db;

DELIMITER $$

CREATE PROCEDURE sell_ticket (
    IN  p_showtime_id    INT,
    IN  p_row_label      VARCHAR(10),
    IN  p_seat_no        INT,
    IN  p_customer_id    INT,
    IN  p_discount_code  VARCHAR(50),
    OUT p_ticket_id      INT
)
BEGIN
    DECLARE v_seat_type_id INT;
    DECLARE v_base_showtime DECIMAL(8,2);
    DECLARE v_base_seat     DECIMAL(8,2);
    DECLARE v_pct_off       DECIMAL(5,2);
    DECLARE v_discount_id   INT;
    DECLARE v_price_before  DECIMAL(8,2);
    DECLARE v_final_price   DECIMAL(8,2);
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    -- 1. Verify seat exists for this showtime
    SELECT seat_type_id
    INTO v_seat_type_id
    FROM SEAT
    WHERE showtime_id = p_showtime_id
      AND row_label   = p_row_label COLLATE utf8mb4_general_ci
      AND seat_no     = p_seat_no
    LIMIT 1;

    IF v_seat_type_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Seat does not exist for this showtime.';
    END IF;

    -- 2. Ensure no existing ticket for this seat (enforced also by UNIQUE)
    IF EXISTS (
        SELECT 1
        FROM TICKET t
        WHERE t.seat_showtime_id = p_showtime_id
          AND t.seat_row_label   = p_row_label COLLATE utf8mb4_general_ci
          AND t.seat_no          = p_seat_no
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Seat already has a ticket.';
    END IF;

    -- 3. Get prices
    SELECT base_price INTO v_base_showtime
    FROM SHOWTIME
    WHERE showtime_id = p_showtime_id;

    SELECT base_price INTO v_base_seat
    FROM SEAT_TYPE
    WHERE seat_type_id = v_seat_type_id;

    IF v_base_showtime IS NULL OR v_base_seat IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Unable to resolve base prices.';
    END IF;

    SET v_price_before = v_base_showtime + v_base_seat;

    -- 4. Optional discount
    SET v_discount_id = NULL;
    SET v_pct_off     = 0;

    IF p_discount_code IS NOT NULL AND p_discount_code <> '' THEN
        SELECT discount_id, pct_off
        INTO v_discount_id, v_pct_off
        FROM DISCOUNT
        WHERE code = p_discount_code COLLATE utf8mb4_general_ci
        LIMIT 1;

        IF v_discount_id IS NULL THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Invalid discount code.';
        END IF;
    END IF;

    IF v_discount_id IS NOT NULL THEN
        SET v_final_price = v_price_before * (1 - (v_pct_off / 100));
    ELSE
        SET v_final_price = v_price_before;
    END IF;

    -- 5. Insert ticket
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
    ) VALUES (
        p_showtime_id,
        p_showtime_id,
        p_row_label,
        p_seat_no,
        p_customer_id,
        v_discount_id,
        NOW(),
        'PURCHASED',
        v_final_price
    );

    SET p_ticket_id = LAST_INSERT_ID();
END$$

DELIMITER ;
