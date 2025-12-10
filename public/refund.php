<?php
require_once __DIR__ . '/../includes/header.php';
require_once __DIR__ . '/../includes/db.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    redirect($config['base_url'] . '/my_tickets.php');
}

if (!check_csrf()) {
    echo error_box('CSRF token invalid. Please try again.');
    require_once __DIR__ . '/../includes/footer.php';
    exit;
}

$ticket_id = param('ticket_id', null, 'int');

if (!$ticket_id) {
    echo error_box('Invalid ticket ID.');
    require_once __DIR__ . '/../includes/footer.php';
    exit;
}

try {
    $stmt = $pdo->prepare("
        SELECT t.ticket_id, t.state, c.email,
               m.title, s.start_dt,
               th.name as theatre_name, au.name_number
        FROM TICKET t
        JOIN CUSTOMER c ON c.customer_id = t.customer_id
        JOIN SHOWTIME s ON s.showtime_id = t.showtime_id
        JOIN AUDITORIUM au ON au.auditorium_id = s.auditorium_id
        JOIN THEATRE th ON th.theatre_id = au.theatre_id
        JOIN MOVIE m ON m.movie_id = s.movie_id
        WHERE t.ticket_id = ?
    ");
    $stmt->execute([$ticket_id]);
    $ticket = $stmt->fetch();
    
    if (!$ticket) {
        echo error_box('Ticket not found.');
        require_once __DIR__ . '/../includes/footer.php';
        exit;
    }
    
    if ($ticket['state'] !== 'PURCHASED') {
        echo error_box('This ticket cannot be refunded. Only PURCHASED tickets can be refunded.');
        echo '<p><a href="' . esc($config['base_url']) . '/my_tickets.php?email=' . esc(urlencode($ticket['email'])) . '" class="btn-secondary">Back to My Tickets</a></p>';
        require_once __DIR__ . '/../includes/footer.php';
        exit;
    }
    
    $stmt = $pdo->prepare("
        UPDATE TICKET SET state = 'REFUNDED' WHERE ticket_id = ?
    ");
    $stmt->execute([$ticket_id]);
    
    echo '<div class="refund-page">';
    echo success_box('Ticket refunded successfully!');
    echo '<h2>Refund Confirmation</h2>';
    echo '<table class="confirmation-table">';
    echo '<tr><th>Ticket ID:</th><td>' . esc($ticket['ticket_id']) . '</td></tr>';
    echo '<tr><th>Movie:</th><td>' . esc($ticket['title']) . '</td></tr>';
    echo '<tr><th>Theatre:</th><td>' . esc($ticket['theatre_name']) . ' - ' . esc($ticket['name_number']) . '</td></tr>';
    echo '<tr><th>Date & Time:</th><td>' . esc(date('M d, Y H:i', strtotime($ticket['start_dt']))) . '</td></tr>';
    echo '<tr><th>Status:</th><td>REFUNDED</td></tr>';
    echo '</table>';
    echo '<p class="confirmation-note">Your refund has been processed. A confirmation email has been sent to ' . esc($ticket['email']) . '.</p>';
    echo '<p><a href="' . esc($config['base_url']) . '/my_tickets.php?email=' . esc(urlencode($ticket['email'])) . '" class="btn-primary">Back to My Tickets</a></p>';
    echo '</div>';
    
} catch (PDOException $e) {
    echo error_box('There was an error processing your refund. Please try again.');
    redirect($config['base_url'] . '/my_tickets.php');
}

require_once __DIR__ . '/../includes/footer.php';
?>
