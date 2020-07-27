<?php
$servername = "localhost";
$username = "lilbeara_styloderento";
$password = "J5G5eG=+a4w=";
$dbname = "lilbeara_styloderento";

$conn = new mysqli($servername,$username,$password,$dbname);
if ($conn -> connect_error){
    die("Connection failed:".$conn ->connect_error);
    
}
?>