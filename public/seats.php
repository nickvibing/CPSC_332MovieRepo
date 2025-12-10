<?php
require_once __DIR__ . '/../includes/header.php';
require_once __DIR__ . '/../includes/db.php';

$showtime_id = param('showtime_id', null, 'int');

if (!$showtime_id) {
    echo error_box('Invalid showtime.');
    require_once __DIR__ . '/../includes/footer.php';
    exit;
}

$stmt = $pdo->prepare("
    SELECT s.showtime_id, s.start_dt, s.format, s.base_price,
           m.title, m.mpaa_rating,
           au.name_number, au.capacity,
           th.name as theatre_name
    FROM SHOWTIME s
    JOIN AUDITORIUM au ON au.auditorium_id = s.auditorium_id
    JOIN THEATRE th ON th.theatre_id = au.theatre_id
    JOIN MOVIE m ON m.movie_id = s.movie_id
    WHERE s.showtime_id = ?
");
$stmt->execute([$showtime_id]);
$showtime = $stmt->fetch();

if (!$showtime) {
    echo error_box('Showtime not found.');
    require_once __DIR__ . '/../includes/footer.php';
    exit;
}

echo '<div class="seats-page">';
echo '<h2>' . esc($showtime['title']) . '</h2>';
echo '<p class="showtime-details">';
echo esc($showtime['theatre_name']) . ' | ' . esc($showtime['name_number']) . ' | ';
echo esc(date('M d, Y H:i', strtotime($showtime['start_dt']))) . ' | ';
echo esc($showtime['format']) . '</p>';

$stmt = $pdo->prepare("
    SELECT se.showtime_id, se.row_label, se.seat_no, se.seat_type_id, st.label as seat_type,
           st.base_price as seat_price,
           CASE WHEN t.ticket_id IS NOT NULL THEN 1 ELSE 0 END as is_sold
    FROM SEAT se
    JOIN SEAT_TYPE st ON st.seat_type_id = se.seat_type_id
    LEFT JOIN TICKET t ON t.seat_showtime_id = se.showtime_id
        AND t.seat_row_label = se.row_label
        AND t.seat_no = se.seat_no
        AND t.state = 'PURCHASED'
    WHERE se.showtime_id = ?
    ORDER BY se.row_label, se.seat_no
");
$stmt->execute([$showtime_id]);
$seats = $stmt->fetchAll();

if (!$seats) {
    echo error_box('Seat map not available.');
    echo '<p>This may mean the database has not been properly initialized. ';
    echo 'Please ensure the SQL migration files (ddl.sql, seed.sql, procedures.sql) have been executed.</p>';
    require_once __DIR__ . '/../includes/footer.php';
    exit;
}

$rows = [];
foreach ($seats as $seat) {
    if (!isset($rows[$seat['row_label']])) {
        $rows[$seat['row_label']] = [];
    }
    $rows[$seat['row_label']][] = $seat;
}

echo '<form method="post" action="' . esc($config['base_url']) . '/purchase.php">';
echo '<input type="hidden" name="showtime_id" value="' . esc($showtime_id) . '">';
echo '<input type="hidden" name="csrf_token" value="' . esc(csrf_token()) . '">';

echo '<div class="seat-map">';
echo '<div class="screen">Screen</div>';

foreach ($rows as $row_label => $row_seats) {
    echo '<div class="seat-row">';
    echo '<span class="row-label">' . esc($row_label) . '</span>';
    
    foreach ($row_seats as $seat) {
        $disabled = $seat['is_sold'] ? 'disabled' : '';
        $class = $seat['is_sold'] ? 'seat sold' : 'seat available';
        
        echo '<label class="' . $class . '">';
        echo '<input type="radio" name="seat_select" ';
        echo 'value="' . esc($seat['row_label']) . ':' . esc($seat['seat_no']) . '" ';
        if ($seat['is_sold']) {
            echo 'disabled';
        }
        echo '>';
        echo '<span class="seat-number">' . esc($seat['seat_no']) . '</span>';
        echo '<span class="seat-type-label">' . esc($seat['seat_type']) . '</span>';
        echo '</label>';
    }
    
    echo '<span class="row-label">' . esc($row_label) . '</span>';
    echo '</div>';
}

echo '</div>';

echo '<div class="seat-legend">';
echo '<div><span class="legend-seat available"></span> Available</div>';
echo '<div><span class="legend-seat sold"></span> Sold</div>';
echo '</div>';

echo '<div class="purchase-form">';
echo '<h3>Booking Details</h3>';

echo '<div class="form-group">';
echo '<label for="email">Email Address (required):</label>';
echo '<input type="email" name="email" id="email" required placeholder="your@email.com">';
echo '</div>';

echo '<div class="form-group">';
echo '<label for="phone">Phone (optional):</label>';
echo '<input type="tel" name="phone" id="phone" placeholder="(555) 123-4567">';
echo '</div>';

echo '<div class="form-group">';
echo '<label for="discount_code">Discount Code (optional):</label>';
echo '<select name="discount_code" id="discount_code">';
echo '<option value="">-- No discount --</option>';

$discounts = $pdo->query("SELECT code, pct_off FROM DISCOUNT ORDER BY code")->fetchAll();
foreach ($discounts as $discount) {
    echo '<option value="' . esc($discount['code']) . '">';
    echo esc($discount['code']) . ' (' . esc($discount['pct_off']) . '% off)';
    echo '</option>';
}
echo '</select>';
echo '</div>';

echo '<div class="price-summary">';
echo '<p><strong>Base Price:</strong> $' . number_format($showtime['base_price'], 2) . '</p>';
echo '<p id="final-price"><strong>Final Price:</strong> $' . number_format($showtime['base_price'], 2) . '</p>';
echo '</div>';

echo '<button type="submit" class="btn-primary">Complete Purchase</button>';
echo '<a href="' . esc($config['base_url']) . '/showtimes.php" class="btn-secondary">Back</a>';

echo '</div>';

echo '</form>';
echo '</div>';

require_once __DIR__ . '/../includes/footer.php';
?>
