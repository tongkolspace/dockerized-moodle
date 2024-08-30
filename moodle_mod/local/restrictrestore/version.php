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
 * Version information for RestrictRestore.
 *
 * @package    local_restrictrestore
 * @copyright  2024 Tonjoo. https://www.tonjoo.com
 * @author     Tofan Wahyu
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */

defined('MOODLE_INTERNAL') || die();

$plugin->component = 'local_restrictrestore';  // To check on upgrade, that module sits in correct place.
$plugin->version   = 20240801400;        // The current module version (Date: YYYYMMDDXX).
$plugin->requires  = 2015111600;        // Requires Moodle version 3.0.
$plugin->release   = '1.0.0';
$plugin->maturity  = MATURITY_STABLE;
$plugin->cron      = 0;
