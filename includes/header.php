<<<<<<< HEAD
<?php
require_once __DIR__ . '/config.php';
require_once __DIR__ . '/functions.php';

$config = require __DIR__ . '/config.php';
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Movie Theatre Ticket System</title>
    <link rel="stylesheet" href="<?php echo esc($config['base_url']); ?>/../assets/styles.css">
</head>
<body>
    <header>
        <nav class="navbar">
            <h1><a href="<?php echo esc($config['base_url']); ?>/index.php">🎬 Theatre Tickets</a></h1>
            <ul class="nav-links">
                <li><a href="<?php echo esc($config['base_url']); ?>/index.php">Home</a></li>
                <li><a href="<?php echo esc($config['base_url']); ?>/movies.php">Browse Movies</a></li>
                <li><a href="<?php echo esc($config['base_url']); ?>/showtimes.php">Showtimes</a></li>
                <li><a href="<?php echo esc($config['base_url']); ?>/my_tickets.php">My Tickets</a></li>
                <li><a href="<?php echo esc($config['base_url']); ?>/reports.php">Reports</a></li>
            </ul>
        </nav>
    </header>
    <main>
=======
<!-- shared <head> + nav -->
>>>>>>> 9e01b81799b3727c238a5cf943a5964e3edfc674
