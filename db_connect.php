<?php
// DATABASE CONNECTION - Nexsus WMS
// the actual connection file. Goes in an includes/ folder in your repo, and any page that needs the database just adds require 'includes/db_connect.php'; at the top.
// connects to the nexsus_wms database as a starting point for whoever's doing the backend.
//it will talk to the database, e.g.: require 'includes/db_connect.php';

// These match XAMPP's default MySQL setup - localhost, username
// 'root', and NO password, unless you changed it in phpMyAdmin.
$host = "localhost";
$username = "root";
$password = "";
$database = "nexsus_wms";

// mysqli_connect() opens the actual connection. If XAMPP's MySQL
// isn't running, or the database name is wrong, this is where
// it will fail.
$conn = mysqli_connect($host, $username, $password, $database);

// die() stops the whole script immediately and prints the error -
// without this check, every page would fail with confusing
// errors further down if the connection didn't work.
if (!$conn) {
    die("Connection failed: " . mysqli_connect_error());
}
?>
