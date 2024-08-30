<?php
// This file is part of RestrictRestore plugin for Moodle - http://moodle.org/
//
// RestrictRestore is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// eMailTest is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with eMailTest.  If not, see <http://www.gnu.org/licenses/>.

/**
 * Library of functions for RestrictRestore.
 *
 * @package    local_restrictrestore
 * @copyright  2024 Tonjoo. https://www.tonjoo.com
 * @author     Tofan Wahyu
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */

defined('MOODLE_INTERNAL') || die();

function local_restrictrestore_extend_navigation(global_navigation $nav)
{
	// This function is just a placeholder to ensure Moodle recognizes the plugin
}

function local_restrictrestore_check_access()
{
	global $PAGE;

	$currenturl = $PAGE->url->out_as_local_url(false);
	if (strpos($currenturl, 'backup/restorefile.php') !== false) {
		$password = optional_param('password', '', PARAM_ALPHANUM); // Adjust PARAM type if necessary
		if ($password !== '123456') {
			print_error('nopermissions', 'error', '', get_string('cannotaccessrestore', 'local_restrictrestore'));
			die;
		}
	}
}

function local_restrictrestore_before_standard_html_head() {
    local_restrictrestore_check_access();
}