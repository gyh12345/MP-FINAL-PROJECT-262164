<?php
error_reporting(0);
include_once ("dbconnect.php");
$email = $_POST['email'];

if (isset($email)){
   $sql = "SELECT * FROM CREDITHISTORY WHERE USERID = '$email'";
}

$result = $conn->query($sql);

if ($result->num_rows > 0)
{
    $response["credithistory"] = array();
    while ($row = $result->fetch_assoc())
    {
        $credithistorylist = array();
        $credithistorylist["status"] = $row["STATUS"];
        $credithistorylist["amount"] = $row["AMOUNT"];
        $credithistorylist["date"] = $row["DATE"];
        array_push($response["credithistory"], $credithistorylist);
    }
    echo json_encode($response);
}
else
{
    echo "nodata";
}
?>