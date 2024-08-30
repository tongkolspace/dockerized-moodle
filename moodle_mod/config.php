<?php
// Fungsi untuk mendapatkan host request
function getRequestHost() {
    if (isset($_SERVER['HTTP_X_FORWARDED_HOST'])) {
        return $_SERVER['HTTP_X_FORWARDED_HOST'];
    } elseif (isset($_SERVER['HTTP_HOST'])) {
        return $_SERVER['HTTP_HOST'];
    }
    return '';
}

$requestHost = getRequestHost();

// Load Config dynamic
if (getenv('DB_TYPE')) {
    // runing on docker
    require "config-docker.php";
} elseif ($requestHost === 'lmsspada.kemdikbud.go.id') {
    // Konfigurasi untuk lmsspada.kemdikbud.go.id
    require "config-lmsspada.php";
} elseif ($requestHost === 'dummy-lmmspada.kemdikbud.go.id') {
    // Konfigurasi untuk dummy-lmmspada.kemdikbud.go.id
    require "config-dummy-lmsspada.php";
} else {
    // Default configuration
    require "config-standard.php";
}
