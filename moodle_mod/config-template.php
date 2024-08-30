<?php 
unset($CFG);  // Ignore this line
global $CFG;  // This is necessary here for PHPUnit execution
$CFG = new stdClass();

$CFG->dbtype    = getenv('DB_TYPE');
$CFG->dblibrary = getenv('DB_LIBRARY');
$CFG->dbhost    = getenv('DB_HOST');
$CFG->dbname    = getenv('DB_DATABASE');
$CFG->dbuser    = getenv('DB_USERNAME');
$CFG->dbpass    = getenv('DB_PASSWORD');
$CFG->sslproxy = filter_var(getenv('SSL_PROXY'), FILTER_VALIDATE_BOOLEAN);


$CFG->prefix    = 'mdl_';       // prefix to use for all table names
$CFG->dboptions = array(
    'dbpersist' => false,      
    'dbsocket'  => false,      
    'dbport'    => '',          
    'dbhandlesoptions' => false,
    'dbcollation' => 'utf8mb4_unicode_ci', 
);


// Mengubah konfigurasi wwwroot berdasarkan nilai sslproxy
if ($CFG->sslproxy ) {
    $CFG->wwwroot = 'https://' . getenv('DOMAIN_MOODLE');
} else {
    $CFG->wwwroot = 'http://' . getenv('DOMAIN_MOODLE');
}

$CFG->dataroot  = '/var/www/moodledata';
$CFG->dirroot  = '/var/www/html';
$CFG->directorypermissions = 02777;
$CFG->admin = 'admin';


require_once($CFG->dirroot .'/lib/setup.php'); // Do not edit