<?php
require_once __DIR__ . '/../includes/header.php';
require_once __DIR__ . '/../includes/db.php';

$theatre_id = param('theatre_id', null, 'int');
$show_date = param('show_date', '');
$movie_id = param('movie_id', null, 'int');

echo '<div class="showtimes-page">';
echo '<h2>Find Showtimes</h2>';

echo '<div class="search-form">';
echo '<form method="get" action="' . esc($config['base_url']) . '/showtimes.php">';
echo '<div class="form-group">';
echo '<label for="theatre_id">Theatre:</label>';
echo '<select name="theatre_id" id="theatre_id">';
echo '<option value="">-- Select a theatre --</option>';

$theatres = $pdo->query("SELECT DISTINCT t.theatre_id, t.name FROM THEATRE t
    JOIN AUDITORIUM a ON a.theatre_id = t.theatre_id
    JOIN SHOWTIME s ON s.auditorium_id = a.auditorium_id
    WHERE s.start_dt > NOW()
    ORDER BY t.name")->fetchAll();
foreach ($theatres as $t) {
    $selected = ($theatre_id === $t['theatre_id']) ? 'selected' : '';
    echo '<option value="' . esc($t['theatre_id']) . '" ' . $selected . '>' . esc($t['name']) . '</option>';
}
echo '</select>';
echo '</div>';

echo '<div class="form-group">';
echo '<label for="show_date">Date:</label>';
echo '<input type="date" name="show_date" id="show_date" value="' . esc($show_date) . '">';
echo '</div>';

echo '<div class="form-group">';
echo '<label for="movie_id">Movie (optional):</label>';
echo '<select name="movie_id" id="movie_id">';
echo '<option value="">-- Any Movie --</option>';

$movies = $pdo->query("SELECT DISTINCT m.movie_id, m.title FROM MOVIE m
    JOIN SHOWTIME s ON s.movie_id = m.movie_id
    WHERE s.start_dt > NOW()
    ORDER BY m.title")->fetchAll();
foreach ($movies as $m) {
    $selected = ($movie_id === $m['movie_id']) ? 'selected' : '';
    echo '<option value="' . esc($m['movie_id']) . '" ' . $selected . '>' . esc($m['title']) . '</option>';
}
echo '</select>';
echo '</div>';

echo '<button type="submit" class="btn-primary">Search Showtimes</button>';
echo '</form>';
echo '</div>';

if ($theatre_id && $show_date) {
    $query = "
        SELECT s.showtime_id, s.start_dt, s.format, s.base_price, s.language,
               m.title, m.mpaa_rating,
               au.name_number, au.capacity,
               COUNT(DISTINCT CASE WHEN t.state = 'PURCHASED' THEN t.ticket_id END) as seats_sold
        FROM SHOWTIME s
        JOIN AUDITORIUM au ON au.auditorium_id = s.auditorium_id
        JOIN MOVIE m ON m.movie_id = s.movie_id
        LEFT JOIN TICKET t ON t.showtime_id = s.showtime_id AND t.state = 'PURCHASED'
        WHERE au.theatre_id = ?
          AND DATE(s.start_dt) = ?
    ";
    
    $params = [$theatre_id, $show_date];
    
    if ($movie_id) {
        $query .= " AND s.movie_id = ?";
        $params[] = $movie_id;
    }
    
    $query .= " GROUP BY s.showtime_id
                ORDER BY s.start_dt";
    
    $stmt = $pdo->prepare($query);
    $stmt->execute($params);
    $showtimes = $stmt->fetchAll();
    
    if ($showtimes) {
        echo '<h3>Available Showtimes</h3>';
        echo '<div class="showtimes-list">';
        foreach ($showtimes as $showtime) {
            $available_seats = $showtime['capacity'] - $showtime['seats_sold'];
            $status_class = ($available_seats > 0) ? 'available' : 'sold-out';
            
            echo '<div class="showtime-card ' . $status_class . '">';
            echo '<div class="showtime-info">';
            echo '<h4>' . esc($showtime['title']) . '</h4>';
            echo '<p><strong>Time:</strong> ' . esc(date('H:i', strtotime($showtime['start_dt']))) . '</p>';
            echo '<p><strong>Auditorium:</strong> ' . esc($showtime['name_number']) . '</p>';
            echo '<p><strong>Format:</strong> ' . esc($showtime['format']) . ' | ' . esc($showtime['language']) . '</p>';
            echo '<p><strong>Rating:</strong> ' . esc($showtime['mpaa_rating']) . '</p>';
            echo '<p><strong>Price:</strong> $' . number_format($showtime['base_price'], 2) . '</p>';
            echo '<p><strong>Seats:</strong> ' . esc($available_seats) . ' / ' . esc($showtime['capacity']) . ' available</p>';
            
            if ($available_seats > 0) {
                echo '<a href="' . esc($config['base_url']) . '/seats.php?showtime_id=' . esc($showtime['showtime_id']) . '" class="btn-primary">Select Seats</a>';
            } else {
                echo '<span class="btn-disabled">Sold Out</span>';
            }
            echo '</div>';
            echo '</div>';
        }
        echo '</div>';
    } else {
        echo info_box('No showtimes found for the selected date and theatre.');
    }
} else {
    echo info_box('Please select a theatre and date to view showtimes.');
}

echo '</div>';

require_once __DIR__ . '/../includes/footer.php';
?>
