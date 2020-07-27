<?php
error_reporting(0);
include_once ("dbconnect.php");
$email = $_POST['email'];

$getCredit = "SELECT CREDIT FROM USER WHERE EMAIL = '$email'";
$result = $conn -> query($getCredit);

if ($result -> num_rows > 0){
    while ($row = $result -> fetch_assoc()){
        echo $data = "success,".$row["CREDIT"];
    }
} 
else {
    echo "failed";
}
?>