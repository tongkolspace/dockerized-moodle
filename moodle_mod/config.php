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
} elseif ($requestHost === 'domain.com') {
    require "config-domain.php";
} elseif ($requestHost === 'domain-2.com') {
    require "domain-domain-2.php";
} else {
    // Default configuration
    require "config-standard.php";
}
