<?php
require_once __DIR__ . '/../includes/header.php';
require_once __DIR__ . '/../includes/db.php';

$movie_id = param('id', null, 'int');
$rating_filter = param('rating', '');
$theatre_filter = param('theatre_id', null, 'int');

if ($movie_id) {
    $stmt = $pdo->prepare("SELECT * FROM MOVIE WHERE movie_id = ?");
    $stmt->execute([$movie_id]);
    $movie = $stmt->fetch();
    
    if (!$movie) {
        echo error_box('Movie not found.');
        require_once __DIR__ . '/../includes/footer.php';
        exit;
    }
    
    echo '<div class="movie-detail">';
    echo '<h2>' . esc($movie['title']) . '</h2>';
    echo '<p><strong>MPAA Rating:</strong> ' . esc($movie['mpaa_rating']) . '</p>';
    echo '<p><strong>Release Date:</strong> ' . esc($movie['release_date']) . '</p>';
    echo '<p><strong>Runtime:</strong> ' . esc($movie['runtime_min']) . ' minutes</p>';
    
    echo '<h3>Showtimes for this movie</h3>';
    
    $showtimes_query = "
        SELECT s.showtime_id, s.start_dt, s.format, s.base_price,
               au.name_number, th.name, th.theatre_id
        FROM SHOWTIME s
        JOIN AUDITORIUM au ON au.auditorium_id = s.auditorium_id
        JOIN THEATRE th ON th.theatre_id = au.theatre_id
        WHERE s.movie_id = ? AND s.start_dt > NOW()
        ORDER BY s.start_dt
    ";
    $params = [$movie_id];
    
    if ($theatre_filter) {
        $showtimes_query .= " AND th.theatre_id = ?";
        $params[] = $theatre_filter;
    }
    
    $stmt = $pdo->prepare($showtimes_query);
    $stmt->execute($params);
    $showtimes = $stmt->fetchAll();
    
    if ($showtimes) {
        echo '<table class="showtimes-table">';
        echo '<thead><tr><th>Theatre</th><th>Auditorium</th><th>Start Time</th><th>Format</th><th>Price</th><th>Action</th></tr></thead>';
        echo '<tbody>';
        foreach ($showtimes as $showtime) {
            echo '<tr>';
            echo '<td>' . esc($showtime['name']) . '</td>';
            echo '<td>' . esc($showtime['name_number']) . '</td>';
            echo '<td>' . esc(date('M d, Y H:i', strtotime($showtime['start_dt']))) . '</td>';
            echo '<td>' . esc($showtime['format']) . '</td>';
            echo '<td>$' . number_format($showtime['base_price'], 2) . '</td>';
            echo '<td><a href="' . esc($config['base_url']) . '/seats.php?showtime_id=' . esc($showtime['showtime_id']) . '" class="btn-small">Select Seats</a></td>';
            echo '</tr>';
        }
        echo '</tbody>';
        echo '</table>';
    } else {
        echo info_box('No upcoming showtimes for this movie.');
    }
    
    echo '<p><a href="' . esc($config['base_url']) . '/movies.php" class="btn-secondary">Back to Movies</a></p>';
    echo '</div>';
    
} else {
    echo '<div class="movies-browse">';
    echo '<h2>Browse Movies</h2>';
    
    echo '<div class="filters">';
    echo '<form method="get" action="' . esc($config['base_url']) . '/movies.php">';
    echo '<div class="form-group">';
    echo '<label for="rating">Filter by Rating:</label>';
    echo '<select name="rating" id="rating">';
    echo '<option value="">-- All Ratings --</option>';
    
    $ratings = $pdo->query("SELECT DISTINCT mpaa_rating FROM MOVIE ORDER BY mpaa_rating")->fetchAll();
    foreach ($ratings as $r) {
        $selected = ($rating_filter === $r['mpaa_rating']) ? 'selected' : '';
        echo '<option value="' . esc($r['mpaa_rating']) . '" ' . $selected . '>' . esc($r['mpaa_rating']) . '</option>';
    }
    echo '</select>';
    echo '</div>';
    
    echo '<div class="form-group">';
    echo '<label for="theatre_id">Filter by Theatre:</label>';
    echo '<select name="theatre_id" id="theatre_id">';
    echo '<option value="">-- All Theatres --</option>';
    
    $theatres = $pdo->query("SELECT DISTINCT t.theatre_id, t.name FROM THEATRE t
        JOIN AUDITORIUM a ON a.theatre_id = t.theatre_id
        JOIN SHOWTIME s ON s.auditorium_id = a.auditorium_id
        WHERE s.start_dt > NOW()
        ORDER BY t.name")->fetchAll();
    foreach ($theatres as $t) {
        $selected = ($theatre_filter === $t['theatre_id']) ? 'selected' : '';
        echo '<option value="' . esc($t['theatre_id']) . '" ' . $selected . '>' . esc($t['name']) . '</option>';
    }
    echo '</select>';
    echo '</div>';
    
    echo '<button type="submit" class="btn-primary">Filter</button>';
    echo '</form>';
    echo '</div>';
    
    $query = "SELECT m.movie_id, m.title, m.mpaa_rating, m.release_date, m.runtime_min
              FROM MOVIE m
              WHERE 1=1";
    $params = [];
    
    if ($rating_filter) {
        $query .= " AND m.mpaa_rating = ?";
        $params[] = $rating_filter;
    }
    
    if ($theatre_filter) {
        $query .= " AND EXISTS (
            SELECT 1 FROM SHOWTIME s
            JOIN AUDITORIUM a ON a.auditorium_id = s.auditorium_id
            WHERE a.theatre_id = ? AND s.movie_id = m.movie_id AND s.start_dt > NOW()
        )";
        $params[] = $theatre_filter;
    }
    
    $query .= " ORDER BY m.title";
    
    $stmt = $pdo->prepare($query);
    $stmt->execute($params);
    $movies = $stmt->fetchAll();
    
    if ($movies) {
        echo '<div class="movie-grid">';
        foreach ($movies as $m) {
            echo '<div class="movie-card">';
            echo '<h3>' . esc($m['title']) . '</h3>';
            echo '<p><strong>Rating:</strong> ' . esc($m['mpaa_rating']) . '</p>';
            echo '<p><strong>Runtime:</strong> ' . esc($m['runtime_min']) . ' min</p>';
            echo '<p><strong>Released:</strong> ' . esc($m['release_date']) . '</p>';
            echo '<a href="' . esc($config['base_url']) . '/movies.php?id=' . esc($m['movie_id']) . '" class="btn-primary">View Details</a>';
            echo '</div>';
        }
        echo '</div>';
    } else {
        echo info_box('No movies found matching your filters.');
    }
    echo '</div>';
}

require_once __DIR__ . '/../includes/footer.php';
?>
