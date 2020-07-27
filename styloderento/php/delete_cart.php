<?php
error_reporting(0);
include_once("dbconnect.php");
$email = $_POST['email'];
$prodid = $_POST['prodid'];

if (isset($_POST['prodid']))
    $sqldelete = "DELETE FROM CART WHERE EMAIL = '$email' AND PRODID='$prodid'";
else
    $sqldelete = "DELETE FROM CART WHERE EMAIL = '$email'";

if ($conn->query($sqldelete) === TRUE){
    $sqlcartquantity = "SELECT * FROM CART WHERE EMAIL = '$email'";
    $resultq = $conn->query($sqlcartquantity);
    if ($resultq->num_rows > 0){
        $cartquantity = 0;
        while ($row = $resultq ->fetch_assoc()){
            $cartquantity =$row["CQUANTITY"] + $cartquantity;
        }
        $cartquantity = $cartquantity;
        echo"success,".$cartquantity;
    } 
    else {
        echo "empty";
    }
}
else 
    echo "failed";
?>