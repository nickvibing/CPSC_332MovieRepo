<?php
require_once __DIR__ . '/../includes/header.php';
require_once __DIR__ . '/../includes/db.php';

echo '<div class="reports-page">';
echo '<h2>Reports</h2>';

echo '<section class="report-section">';
echo '<h3>Top Movies by Tickets Sold</h3>';
$stmt = $pdo->query("
    SELECT movie_id, title, tickets_sold
    FROM vw_movie_ticket_counts
    ORDER BY tickets_sold DESC
    LIMIT 10
");
$movies = $stmt->fetchAll();

if ($movies) {
    echo '<table class="report-table">';
    echo '<thead><tr><th>Movie</th><th>Tickets Sold</th></tr></thead>';
    echo '<tbody>';
    foreach ($movies as $m) {
        echo '<tr>';
        echo '<td>' . esc($m['title']) . '</td>';
        echo '<td>' . esc($m['tickets_sold']) . '</td>';
        echo '</tr>';
    }
    echo '</tbody>';
    echo '</table>';
} else {
    echo info_box('No data available.');
}
echo '</section>';

echo '<section class="report-section">';
echo '<h3>Sold-Out Showtimes</h3>';
$stmt = $pdo->query("
    SELECT theatre_name, auditorium_name, title, start_dt, seats_sold, total_seats
    FROM vw_sold_out_showtimes
    ORDER BY start_dt DESC
");
$soldout = $stmt->fetchAll();

if ($soldout) {
    echo '<table class="report-table">';
    echo '<thead><tr><th>Theatre</th><th>Auditorium</th><th>Movie</th><th>Start Time</th><th>Seats</th></tr></thead>';
    echo '<tbody>';
    foreach ($soldout as $s) {
        echo '<tr>';
        echo '<td>' . esc($s['theatre_name']) . '</td>';
        echo '<td>' . esc($s['auditorium_name']) . '</td>';
        echo '<td>' . esc($s['title']) . '</td>';
        echo '<td>' . esc(date('M d, Y H:i', strtotime($s['start_dt']))) . '</td>';
        echo '<td>' . esc($s['seats_sold']) . ' / ' . esc($s['total_seats']) . '</td>';
        echo '</tr>';
    }
    echo '</tbody>';
    echo '</table>';
} else {
    echo info_box('No sold-out showtimes in the next 7 days.');
}
echo '</section>';

echo '<section class="report-section">';
echo '<h3>Theatre Utilization (Next 7 Days)</h3>';
$stmt = $pdo->query("
    SELECT theatre_name, total_seat_instances, seats_sold, utilization_percent
    FROM vw_theatre_utilization_next7
    ORDER BY utilization_percent DESC
");
$util = $stmt->fetchAll();

if ($util) {
    echo '<table class="report-table">';
    echo '<thead><tr><th>Theatre</th><th>Total Seats</th><th>Seats Sold</th><th>Utilization %</th></tr></thead>';
    echo '<tbody>';
    foreach ($util as $u) {
        echo '<tr>';
        echo '<td>' . esc($u['theatre_name']) . '</td>';
        echo '<td>' . esc($u['total_seat_instances']) . '</td>';
        echo '<td>' . esc($u['seats_sold']) . '</td>';
        echo '<td>' . number_format($u['utilization_percent'], 2) . '%</td>';
        echo '</tr>';
    }
    echo '</tbody>';
    echo '</table>';
} else {
    echo info_box('No data available.');
}
echo '</section>';

echo '</div>';

require_once __DIR__ . '/../includes/footer.php';
?>
