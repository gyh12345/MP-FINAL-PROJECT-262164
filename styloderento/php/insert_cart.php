<?php
error_reporting(0);
include_once ("dbconnect.php");
$email = $_POST['email'];
$prodid = $_POST['proid'];
$userquantity = $_POST['quantity'];
$day2rent = $_POST['day2rent'];

$sqlsearch = "SELECT * FROM CART WHERE EMAIL = '$email' AND PRODID = '$prodid'";

$result = $conn->query($sqlsearch);
if ($result->num_rows > 0){
    while ($row = $result ->fetch_assoc()){
        $prquantity = $row["CQUANTITY"];
        $totalday2rent = $row["DAY2RENT"];
    }
    $prquantity = $prquantity + $userquantity;
    $totalday2rent = $totalday2rent + $day2rent;
    $sqlinsert = "UPDATE CART SET CQUANTITY = '$prquantity', DAY2RENT = '$totalday2rent' WHERE PRODID = '$prodid' AND EMAIL = '$email'";
}else{
    $sqlinsert = "INSERT INTO CART(EMAIL,PRODID,CQUANTITY,DAY2RENT,STATUS) VALUES ('$email','$prodid',$userquantity,$day2rent,'notpaid')";
}
if ($conn->query($sqlinsert) === true){
    $sqlquantity = "SELECT * FROM CART WHERE EMAIL = '$email'";
    $resultq = $conn->query($sqlquantity);
    
    if ($resultq->num_rows > 0) {
        $quantity = 0;
        while ($row = $resultq ->fetch_assoc()){
            $quantity = $row["CQUANTITY"] + $quantity;
        }
    }
    
    $quantity = $quantity;
    echo "success,".$quantity;
}
else{
    echo "failed";
}
?>