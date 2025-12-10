<?php
require_once __DIR__ . '/../includes/header.php';
require_once __DIR__ . '/../includes/db.php';
?>

<section class="landing">
    <h2>Welcome to Movie Theatre Tickets</h2>
    <p>Book your cinema experience today!</p>
    
    <div class="quick-search">
        <h3>Quick Showtime Finder</h3>
        <form method="get" action="<?php echo esc($config['base_url']); ?>/showtimes.php">
            <div class="form-group">
                <label for="theatre_id">Theatre:</label>
                <select name="theatre_id" id="theatre_id" required>
                    <option value="">-- Select a theatre --</option>
                    <?php
                    $theatres = $pdo->query("SELECT theatre_id, name FROM THEATRE ORDER BY name")->fetchAll();
                    foreach ($theatres as $theatre) {
                        echo '<option value="' . esc($theatre['theatre_id']) . '">' . esc($theatre['name']) . '</option>';
                    }
                    ?>
                </select>
            </div>
            <div class="form-group">
                <label for="show_date">Date:</label>
                <input type="date" name="show_date" id="show_date" required>
            </div>
            <button type="submit" class="btn-primary">Find Showtimes</button>
        </form>
    </div>
    
    <div class="featured-section">
        <h3>Featured Movies</h3>
        <div class="movie-grid">
            <?php
            $movies = $pdo->query("SELECT movie_id, title, mpaa_rating FROM MOVIE ORDER BY release_date DESC LIMIT 6")->fetchAll();
            foreach ($movies as $movie) {
                echo '<a href="' . esc($config['base_url']) . '/movies.php?id=' . esc($movie['movie_id']) . '" class="movie-card">';
                echo '<h4>' . esc($movie['title']) . '</h4>';
                echo '<p class="rating">' . esc($movie['mpaa_rating']) . '</p>';
                echo '</a>';
            }
            ?>
        </div>
    </div>
    
    <div class="links-section">
        <h3>Quick Links</h3>
        <ul>
            <li><a href="<?php echo esc($config['base_url']); ?>/movies.php">Browse All Movies</a></li>
            <li><a href="<?php echo esc($config['base_url']); ?>/my_tickets.php">Look Up My Tickets</a></li>
            <li><a href="<?php echo esc($config['base_url']); ?>/reports.php">View Reports</a></li>
        </ul>
    </div>
</section>

<?php require_once __DIR__ . '/../includes/footer.php'; ?>
