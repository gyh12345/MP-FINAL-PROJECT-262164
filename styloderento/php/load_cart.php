<?php
error_reporting(0);
include_once ("dbconnect.php");
$email = $_POST['email'];

if (isset($email)){
    $sql = "SELECT PRODUCT.ID, PRODUCT.NAME, PRODUCT.SIZE, PRODUCT.QUANTITY, 
    PRODUCT.PRICE, PRODUCT.DELIPRICE, PRODUCT.SELLERADDRESS, CART.CQUANTITY, 
    CART.DAY2RENT FROM PRODUCT INNER JOIN CART ON CART.PRODID = PRODUCT.ID 
    WHERE CART.EMAIL = '$email'";
}

$result = $conn->query($sql);

if ($result->num_rows > 0)
{
    $response["cart"] = array();
    while ($row = $result->fetch_assoc())
    {
        $cartlist = array();
        $cartlist["id"] = $row["ID"];
        $cartlist["name"] = $row["NAME"];
        $cartlist["size"] = $row["SIZE"];
        $cartlist["quantity"] = $row["QUANTITY"];
        $cartlist["price"] = $row["PRICE"];
        $cartlist["deliprice"] = $row["DELIPRICE"];
        $cartlist["cquantity"] = $row["CQUANTITY"];
        $cartlist["selleraddress"] = $row["SELLERADDRESS"];
        $cartlist["day2rent"] = $row["DAY2RENT"];
        $cartlist["yourprice"] = round(doubleval($row["PRICE"])*(doubleval($row["CQUANTITY"]))*(doubleval($row["DAY2RENT"])),2)."";
        $cartlist["yourpricewithdeli"] = round((doubleval($row["PRICE"])*(doubleval($row["CQUANTITY"]))*(doubleval($row["DAY2RENT"])))+doubleval($row["DELIPRICE"]),2)."";
        array_push($response["cart"], $cartlist);
    }
    echo json_encode($response);
}
else
{
    echo "Cart Empty";
}

?>
