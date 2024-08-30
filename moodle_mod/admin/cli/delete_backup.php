<?php
define('CLI_SCRIPT', true);
require('../../config.php');
require_once($CFG->libdir . '/clilib.php');
require_once($CFG->dirroot . '/course/lib.php');

// Ensure the user is logged in as admin
\core\session\manager::set_user(get_admin());

// Function to delete a file and its associated records
function delete_file($fileid)
{
    global $DB;

    $fs = get_file_storage();
    $file = $fs->get_file_by_id($fileid);

    if ($file) {
        $filepath = $file->get_filepath() . $file->get_filename();
        $filesize = $file->get_filesize();
        if ($file->delete()) {  // Ensure file is deleted before removing records
            $DB->delete_records('files', ['id' => $fileid]);
            return [$filepath, $filesize];
        }
    }

    return false;
}

// Single query to get both aggregate data and individual file records
$sql = "SELECT 
            f.id, 
            f.contenthash, 
            f.pathnamehash, 
            f.filename, 
            f.filesize, 
            f.filepath,
            COUNT(*) OVER () as file_count,
            SUM(f.filesize) OVER () as total_size
        FROM {files} f
        WHERE f.component = 'backup' AND f.filearea = 'course'";

$backup_files = $DB->get_records_sql($sql);

// The first record will contain the aggregate data
$first_record = reset($backup_files);
$file_count = $first_record->file_count;
$total_size = $first_record->total_size;

echo "Total backup files: " . $file_count . "\n";
echo "Total backup size: " . display_size($total_size) . "\n\n";

// Prompt for confirmation
$continue = cli_input("Do you want to continue with the deletion? (yes/no): ");

if (strtolower($continue) !== 'yes') {
    echo "Operation cancelled.\n";
    exit;
}

$deleted_count = 0;
$deleted_size = 0;

foreach ($backup_files as $file) {
    $result = delete_file($file->id);
    if ($result) {
        list($filepath, $filesize) = $result;
        echo "Deleted file: " . $filepath . " (" . display_size($filesize) . ")\n";
        $deleted_count++;
        $deleted_size += $filesize;
    }
}

echo "\nBackup cleanup completed.\n";
echo "Deleted files: " . $deleted_count . "\n";
echo "Freed space: " . display_size($deleted_size) . "\n";

$sqlDeleteControllers = "DELETE FROM {backup_controllers} WHERE CAST(progress AS UNSIGNED) = 1";
$DB->execute($sqlDeleteControllers);
echo "Also deleted completed backup controllers where progress equals 1.\n";

