<?php
error_reporting(0);
include_once ("dbconnect.php");
$orderid = $_POST['orderid'];

$sql = "SELECT PRODUCT.ID, PRODUCT.NAME, PRODUCT.PRICE, PRODUCT.SIZE, 
        PRODUCT.SELLERADDRESS, PRODUCT.DELIPRICE, CARTHISTORY.CQUANTITY, CARTHISTORY.DAY2RENT, CARTHISTORY.STATUS FROM PRODUCT INNER JOIN CARTHISTORY ON CARTHISTORY.PRODID = PRODUCT.ID WHERE CARTHISTORY.ORDERID = '$orderid'";

$result = $conn->query($sql);

if ($result->num_rows > 0)
{
    $response["carthistory"] = array();
    while ($row = $result->fetch_assoc())
    {
        $cartlist = array();
        $cartlist["id"] = $row["ID"];
        $cartlist["name"] = $row["NAME"];
        $cartlist["price"] = $row["PRICE"];
        $cartlist["size"] = $row["SIZE"];
        $cartlist["cquantity"] = $row["CQUANTITY"];
        $cartlist["day2rent"] = $row["DAY2RENT"];
        $cartlist["address"] = $row["SELLERADDRESS"];
        $cartlist["delivery"] = $row["DELIPRICE"];
        $cartlist["status"] = $row["STATUS"];
        array_push($response["carthistory"], $cartlist);
    }
    echo json_encode($response);
}
else
{
    echo "Cart Empty";
}
?>