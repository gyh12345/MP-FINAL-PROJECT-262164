<?php
error_reporting(0);
include_once("dbconnect.php");
$email = $_POST['email'];
$password = sha1($_POST['password']);

$login = "SELECT * FROM USER WHERE EMAIL = '$email' AND PASSWORD = '$password'";
$result = $conn -> query($login);

if ($result -> num_rows>0) {
    while($row = $result -> fetch_assoc()){
        echo $data = "success%"
                    .$row["EMAIL"]."%"
                    .$row["NAME"]."%"
                    .$row["PHONE"]."%"
                    .$row["CREDIT"]."%"
                    .$row["VERIFY"]."%"
                    .$row["QUANTITY"]."%"
                    .$row["USERADDRESS"]."%"
                    .$row["DATEREG"];
    }
}
else {
    echo  "failed";
}
