<?php
require_once __DIR__ . '/../includes/header.php';
require_once __DIR__ . '/../includes/db.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    redirect($config['base_url'] . '/index.php');
}

if (!check_csrf()) {
    echo error_box('CSRF token invalid. Please try again.');
    require_once __DIR__ . '/../includes/footer.php';
    exit;
}

$showtime_id = param('showtime_id', null, 'int');
$seat_select = param('seat_select', '');
$email = param('email', '');
$phone = param('phone', '');
$discount_code = param('discount_code', '');

if (!$showtime_id || !$seat_select || !$email) {
    echo error_box('Missing required fields.');
    require_once __DIR__ . '/../includes/footer.php';
    exit;
}

if (!is_valid_email($email)) {
    echo error_box('Invalid email address.');
    require_once __DIR__ . '/../includes/footer.php';
    exit;
}

if (strpos($seat_select, ':') === false) {
    echo error_box('Invalid seat selection format.');
    require_once __DIR__ . '/../includes/footer.php';
    exit;
}

list($row_label, $seat_no) = explode(':', $seat_select);

if (!$row_label || !$seat_no) {
    echo error_box('Invalid seat selection.');
    require_once __DIR__ . '/../includes/footer.php';
    exit;
}

$seat_no = (int)$seat_no;

if ($seat_no <= 0) {
    echo error_box('Invalid seat number.');
    require_once __DIR__ . '/../includes/footer.php';
    exit;
}

try {
    $pdo->beginTransaction();
    
    $stmt = $pdo->prepare("
        SELECT customer_id FROM CUSTOMER WHERE email = ?
    ");
    $stmt->execute([$email]);
    $customer = $stmt->fetch();
    
    if (!$customer) {
        $stmt = $pdo->prepare("
            INSERT INTO CUSTOMER (email, phone) VALUES (?, ?)
        ");
        $stmt->execute([$email, $phone ?: null]);
        $customer_id = $pdo->lastInsertId();
    } else {
        $customer_id = $customer['customer_id'];
        
        if ($phone) {
            $stmt = $pdo->prepare("UPDATE CUSTOMER SET phone = ? WHERE customer_id = ?");
            $stmt->execute([$phone, $customer_id]);
        }
    }
    
    $discount_code_param = ($discount_code && $discount_code !== '') ? $discount_code : null;
    
    $stmt = $pdo->prepare("
        CALL sell_ticket(?, ?, ?, ?, ?, @p_ticket_id)
    ");
    $stmt->execute([
        $showtime_id,
        $row_label,
        $seat_no,
        $customer_id,
        $discount_code_param
    ]);
    
    $stmt = $pdo->query("SELECT @p_ticket_id as ticket_id");
    $result = $stmt->fetch();
    $ticket_id = $result['ticket_id'];
    
    $pdo->commit();
    
    $stmt = $pdo->prepare("
        SELECT t.ticket_id, t.final_price, t.state, t.purchase_dt,
               m.title, s.start_dt, s.format,
               au.name_number, th.name as theatre_name
        FROM TICKET t
        JOIN SHOWTIME s ON s.showtime_id = t.showtime_id
        JOIN AUDITORIUM au ON au.auditorium_id = s.auditorium_id
        JOIN THEATRE th ON th.theatre_id = au.theatre_id
        JOIN MOVIE m ON m.movie_id = s.movie_id
        WHERE t.ticket_id = ?
    ");
    $stmt->execute([$ticket_id]);
    $ticket = $stmt->fetch();
    
    echo '<div class="confirmation-page">';
    echo '<div class="confirmation-box">';
    echo success_box('Ticket purchased successfully!');
    echo '<h2>Booking Confirmation</h2>';
    echo '<table class="confirmation-table">';
    echo '<tr><th>Confirmation Number:</th><td>' . esc($ticket['ticket_id']) . '</td></tr>';
    echo '<tr><th>Movie:</th><td>' . esc($ticket['title']) . '</td></tr>';
    echo '<tr><th>Theatre:</th><td>' . esc($ticket['theatre_name']) . '</td></tr>';
    echo '<tr><th>Auditorium:</th><td>' . esc($ticket['name_number']) . '</td></tr>';
    echo '<tr><th>Date & Time:</th><td>' . esc(date('M d, Y H:i', strtotime($ticket['start_dt']))) . '</td></tr>';
    echo '<tr><th>Format:</th><td>' . esc($ticket['format']) . '</td></tr>';
    echo '<tr><th>Seat:</th><td>' . esc($row_label) . esc($seat_no) . '</td></tr>';
    echo '<tr><th>Final Price:</th><td>$' . number_format($ticket['final_price'], 2) . '</td></tr>';
    echo '<tr><th>Status:</th><td>' . esc($ticket['state']) . '</td></tr>';
    echo '</table>';
    echo '<p class="confirmation-note">A confirmation email has been sent to ' . esc($email) . '.</p>';
    echo '<p class="confirmation-note">Please save your confirmation number for reference.</p>';
    echo '<div class="confirmation-links">';
    echo '<a href="' . esc($config['base_url']) . '/index.php" class="btn-primary">Back to Home</a>';
    echo '<a href="' . esc($config['base_url']) . '/my_tickets.php?email=' . esc(urlencode($email)) . '" class="btn-secondary">View My Tickets</a>';
    echo '</div>';
    echo '</div>';
    echo '</div>';
    
} catch (PDOException $e) {
    $pdo->rollBack();
    
    $error_msg = 'There was an error processing your purchase.';
    $exception_msg = $e->getMessage();
    
    error_log('Purchase error: ' . $exception_msg);
    
    if (strpos($exception_msg, 'Seat already') !== false) {
        $error_msg = 'That seat has just been sold. Please select another seat.';
    } elseif (strpos($exception_msg, 'Seat does not') !== false) {
        $error_msg = 'The selected seat is not available.';
    } elseif (strpos($exception_msg, 'Invalid discount') !== false) {
        $error_msg = 'Invalid discount code or discount expired.';
    } elseif (strpos($exception_msg, 'Unable to resolve') !== false) {
        $error_msg = 'Unable to retrieve pricing information. Please try again.';
    }
    
    echo error_box($error_msg);
    echo '<p><a href="' . esc($config['base_url']) . '/seats.php?showtime_id=' . esc($showtime_id) . '" class="btn-secondary">Try Again</a></p>';
}

require_once __DIR__ . '/../includes/footer.php';
?>
