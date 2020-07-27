<?php
error_reporting(0);
include_once("dbconnect.php");

$email = $_POST['email'];
$prodid = $_POST['prodid'];
$quantity = $_POST['quantity'];
$day2rent = $_POST['day2rent'];
$address = $_POST['address'];

if (isset($quantity) && isset($day2rent)){
    $sqlupdatequantity = "UPDATE CART SET CQUANTITY = '$quantity', DAY2RENT = '$day2rent' WHERE EMAIL = '$email' AND PRODID = '$prodid'";
    if ($conn->query($sqlupdatequantity)){
        echo "update quantity success";
    }
    else{
        echo "update quantity failed";
    }
}

if (isset($address)){
    $sqlupdateUserAddress = "UPDATE USER SET USERADDRESS = '$address' WHERE EMAIL = '$email'";
    if ($conn->query($sqlupdateUserAddress)){
        echo "update address success";
    }
    else {
        echo "update address failed";
    }
}

$conn->close();
?>