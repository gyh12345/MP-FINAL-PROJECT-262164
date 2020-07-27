<?php
error_reporting(0);
include_once("dbconnect.php");

$operation = $_POST['operation'];
$prodid = $_POST['prodid'];
$encoded_string = $_POST['encoded_string'];
$decoded_string = base64_decode($encoded_string);
$name = $_POST['name'];
$price = $_POST['price'];
$delivery = $_POST['delivery'];
$quantity = $_POST['quantity'];
$size = $_POST['size'];
$type = $_POST['type'];
$selleraddress = $_POST['selleraddress'];

$path = '../images/product_images/'.$prodid.'.jpg';

if ($operation == 'add'){
    $sqladd = "INSERT INTO PRODUCT(ID, NAME, SIZE, QUANTITY, PRICE, DELIPRICE, TYPE, SELLERADDRESS) VALUES ('$prodid', '$name', '$size', '$quantity', '$price', '$deliprice', '$type', '$selleraddress')";
    if ($conn->query($sqladd) === true){
        if (file_put_contents($path, $decoded_string)){
            echo 'success';
        }else{
            echo 'failed';
        }
    }
}

if ($operation == "update with image"){
    $sqlupdate = "UPDATE PRODUCT SET NAME = '$name', SIZE = '$size', QUANTITY = '$quantity', PRICE = '$price', DELIPRICE = '$deliprice', TYPE = '$type', SELLERADDRESS = '$selleraddress' WHERE ID = '$prodid'";
    if ($conn->query($sqlupdate) === true){
        //unlink($path);
        if (file_put_contents($path, $decoded_string)){
            echo 'success';
        }else{
            echo 'failed';
        }
    }
}

if ($operation == 'update'){
    $sqlupdate = "UPDATE PRODUCT SET NAME = '$name', SIZE = '$size', QUANTITY = '$quantity', PRICE = '$price', DELIPRICE = '$deliprice', TYPE = '$type', SELLERADDRESS = '$selleraddress' WHERE ID = '$prodid'";
    if ($conn->query($sqlupdate) === true){
        echo 'success';
    }
    else {
        echo 'failed';
    }
}

if ($operation == 'delete'){
    $sqldelete = "DELETE FROM PRODUCT WHERE ID = '$prodid'";
    if ($conn->query($sqldelete) === true){
        echo 'success';
    }
    else {
        echo 'failed';
    }
}

?>