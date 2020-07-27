<?php
error_reporting(0);
include_once("dbconnect.php");
$userid = $_GET['userid'];
$mobile = $_GET['mobile'];
$amount = $_GET['amount'];
$orderid = $_GET['orderid'];
$creditUsed = $_GET['credit'];
$creditOwned;

if (isset($creditUsed)){
    $sqlgetcredit = "SELECT CREDIT FROM USER WHERE EMAIL = '$userid'";
    $creditOwned = $conn->query($sqlgetcredit);
}

$data = array(
    'id' =>  $_GET['billplz']['id'],
    'paid_at' => $_GET['billplz']['paid_at'] ,
    'paid' => $_GET['billplz']['paid'],
    'x_signature' => $_GET['billplz']['x_signature']
);

$paidstatus = $_GET['billplz']['paid'];
if ($paidstatus=="true"){
    $paidstatus = "Success";
}else{
    $paidstatus = "Failed";
}
$receiptid = $_GET['billplz']['id'];
$signing = '';
foreach ($data as $key => $value) {
    $signing.= 'billplz'.$key . $value;
    if ($key === 'paid') {
        break;
    } else {
        $signing .= '|';
    }
}
 
 
$signed= hash_hmac('sha256', $signing, 'S-KaO-JrvEEJ1kM8nz4U3vlg');
if ($signed === $data['x_signature']) {

    if ($paidstatus == "Success"){
        $remainingCredit = $creditOwned - $creditUsed;
        $updatecredit = "UPDATE USER SET CREDIT = '$remainingCredit' WHERE EMAIL = '$userid'";
        $sqlcart = "SELECT PRODID, CQUANTITY, DAY2RENT FROM CART WHERE EMAIL = '$userid'";
        
        $conn->query($updatecredit);
        $cartresult = $conn->query($sqlcart);
        if ($cartresult->num_rows > 0)
        {
            while ($row = $cartresult->fetch_assoc())
            {
            $prodid = $row["PRODID"];
            $cq = $row["CQUANTITY"];
            $day2rent = $row["DAY2RENT"];
            $sqlinsertcarthistory = "INSERT INTO CARTHISTORY(EMAIL, ORDERID, BILLID, PRODID, CQUANTITY, DAY2RENT, STATUS) VALUES ('$userid','$orderid','$receiptid','$prodid','$cq','$day2rent','Pending Return')";
            $conn->query($sqlinsertcarthistory);
            
            $selectproduct = "SELECT * FROM PRODUCT WHERE ID = '$prodid'";
            $productresult = $conn->query($selectproduct);
             if ($productresult->num_rows > 0){
                  while ($rowp = $productresult->fetch_assoc()){
                    $prquantity = $rowp["QUANTITY"];
                    $newquantity = $prquantity - $cq;
                    $sqlupdatequantity = "UPDATE PRODUCT SET QUANTITY = '$newquantity' WHERE ID = '$prodid'";
                    $conn->query($sqlupdatequantity);
                  }
             }
        }
        
       $sqldeletecart = "DELETE FROM CART WHERE EMAIL = '$userid'";
       $sqlinsert = "INSERT INTO PAYMENT(ORDERID,BILLID,USERID,TOTAL) VALUES ('$orderid','$receiptid','$userid','$amount')";
       
       $conn->query($sqldeletecart);
       $conn->query($sqlinsert);
    }
        echo '<br><br><body><div><h2><br><br><center>Receipt</center></h1><table border=1 width=80% align=center><tr><td>Order id</td><td>'.$orderid.'</td></tr><tr><td>Receipt ID</td><td>'.$receiptid.'</td></tr><tr><td>Email to </td><td>'.$userid. ' </td></tr><td>Amount </td><td>RM '.$amount.'</td></tr><tr><td>Payment Status </td><td>'.$paidstatus.'</td></tr><tr><td>Date </td><td>'.date("d/m/Y").'</td></tr><tr><td>Time </td><td>'.date("h:i a").'</td></tr></table><br><p><center>Press back button to return to Stylo de Rento</center></p></div></body>';
    } 
        else 
    {
    echo 'Not Match!';
    }
}

?>