<?php
require_once __DIR__ . '/../includes/header.php';
require_once __DIR__ . '/../includes/db.php';

$email = param('email', '');
$ticket_id = param('ticket_id', null, 'int');

echo '<div class="my-tickets-page">';
echo '<h2>My Tickets</h2>';

echo '<div class="lookup-form">';
echo '<form method="get" action="' . esc($config['base_url']) . '/my_tickets.php">';
echo '<div class="form-group">';
echo '<label for="email">Search by Email:</label>';
echo '<input type="email" name="email" id="email" value="' . esc($email) . '" placeholder="your@email.com">';
echo '</div>';
echo '<div class="form-group">';
echo '<label for="ticket_id">or by Ticket ID:</label>';
echo '<input type="text" name="ticket_id" id="ticket_id" placeholder="e.g., 12345">';
echo '</div>';
echo '<button type="submit" class="btn-primary">Search</button>';
echo '</form>';
echo '</div>';

$tickets = [];

if ($email) {
    if (!is_valid_email($email)) {
        echo error_box('Invalid email address.');
    } else {
        $stmt = $pdo->prepare("
            SELECT t.ticket_id, t.final_price, t.state, t.purchase_dt,
                   t.seat_row_label, t.seat_no,
                   m.title, s.start_dt, s.format,
                   au.name_number, th.name as theatre_name
            FROM TICKET t
            JOIN CUSTOMER c ON c.customer_id = t.customer_id
            JOIN SHOWTIME s ON s.showtime_id = t.showtime_id
            JOIN AUDITORIUM au ON au.auditorium_id = s.auditorium_id
            JOIN THEATRE th ON th.theatre_id = au.theatre_id
            JOIN MOVIE m ON m.movie_id = s.movie_id
            WHERE c.email = ?
            ORDER BY t.purchase_dt DESC
        ");
        $stmt->execute([$email]);
        $tickets = $stmt->fetchAll();
    }
} elseif ($ticket_id) {
    $stmt = $pdo->prepare("
        SELECT t.ticket_id, t.final_price, t.state, t.purchase_dt,
               t.seat_row_label, t.seat_no,
               m.title, s.start_dt, s.format,
               au.name_number, th.name as theatre_name,
               c.email
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
    if ($ticket) {
        $tickets = [$ticket];
        $email = $ticket['email'];
    } else {
        echo error_box('Ticket not found.');
    }
}

if (count($tickets) > 0) {
    echo '<h3>Tickets for ' . esc($email) . '</h3>';
    echo '<table class="tickets-table">';
    echo '<thead>';
    echo '<tr>';
    echo '<th>Ticket ID</th>';
    echo '<th>Movie</th>';
    echo '<th>Theatre</th>';
    echo '<th>Date & Time</th>';
    echo '<th>Seat</th>';
    echo '<th>Price</th>';
    echo '<th>Status</th>';
    echo '<th>Action</th>';
    echo '</tr>';
    echo '</thead>';
    echo '<tbody>';
    
    foreach ($tickets as $ticket) {
        echo '<tr>';
        echo '<td>' . esc($ticket['ticket_id']) . '</td>';
        echo '<td>' . esc($ticket['title']) . '</td>';
        echo '<td>' . esc($ticket['theatre_name']) . ' - ' . esc($ticket['name_number']) . '</td>';
        echo '<td>' . esc(date('M d, Y H:i', strtotime($ticket['start_dt']))) . '</td>';
        echo '<td>' . esc($ticket['seat_row_label']) . esc($ticket['seat_no']) . '</td>';
        echo '<td>$' . number_format($ticket['final_price'], 2) . '</td>';
        echo '<td><span class="status-' . strtolower($ticket['state']) . '">' . esc($ticket['state']) . '</span></td>';
        echo '<td>';
        
        if ($ticket['state'] === 'PURCHASED') {
            echo '<form method="post" action="' . esc($config['base_url']) . '/refund.php" style="display:inline;">';
            echo '<input type="hidden" name="ticket_id" value="' . esc($ticket['ticket_id']) . '">';
            echo '<input type="hidden" name="csrf_token" value="' . esc(csrf_token()) . '">';
            echo '<button type="submit" class="btn-small" onclick="return confirm(\'Are you sure you want to refund this ticket?\')">Refund</button>';
            echo '</form>';
        } else {
            echo '<span class="btn-disabled">--</span>';
        }
        
        echo '</td>';
        echo '</tr>';
    }
    
    echo '</tbody>';
    echo '</table>';
} elseif ($email || $ticket_id) {
    echo info_box('No tickets found.');
}

echo '</div>';

require_once __DIR__ . '/../includes/footer.php';
?>
