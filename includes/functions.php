<?php

function esc($str) {
    return htmlspecialchars($str, ENT_QUOTES, 'UTF-8');
}

function param($name, $default = null, $type = 'string') {
    $value = $_GET[$name] ?? $_POST[$name] ?? $default;
    
    if ($value === $default) {
        return $default;
    }
    
    if ($type === 'int') {
        return (int)$value;
    } elseif ($type === 'float') {
        return (float)$value;
    }
    
    return trim((string)$value);
}

function csrf_token() {
    if (session_status() === PHP_SESSION_NONE) {
        session_start();
    }
    
    if (!isset($_SESSION['csrf_token'])) {
        $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
    }
    
    return $_SESSION['csrf_token'];
}

function check_csrf() {
    if (session_status() === PHP_SESSION_NONE) {
        session_start();
    }
    
    $token = $_POST['csrf_token'] ?? null;
    $expected = $_SESSION['csrf_token'] ?? null;
    
    if (!$token || !$expected || $token !== $expected) {
        return false;
    }
    
    unset($_SESSION['csrf_token']);
    return true;
}

function redirect($path) {
    header("Location: $path", true, 303);
    exit;
}

function is_valid_email($email) {
    return filter_var($email, FILTER_VALIDATE_EMAIL) !== false;
}

function error_box($message) {
    return '<div class="error-box">' . esc($message) . '</div>';
}

function success_box($message) {
    return '<div class="success-box">' . esc($message) . '</div>';
}

function info_box($message) {
    return '<div class="info-box">' . esc($message) . '</div>';
}
