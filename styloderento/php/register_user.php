<?php
error_reporting(0);
include_once ("dbconnect.php");
$name = $_POST['name'];
$email = $_POST['email'];
$phone = $_POST['phone'];
$password = sha1($_POST['password']);

$sqlinsert = "INSERT INTO USER(EMAIL, PASSWORD, NAME, PHONE, VERIFY, CREDIT, QUANTITY, USERADDRESS) VALUES ('$email','$password','$name','$phone','0','0','0','')";

if ($conn->query($sqlinsert) === true){
    createDefaultProfilePic($email);
    sendEmail($email);
    echo "success";
}
else{
    echo "failed";
}

function createDefaultProfilePic($email) {
    $image = imagecreate(500,500);
    imagepng($image, "/images/profile_images/'$email'.jpg");
}

function sendEmail($email) {
    $to      = $email; 
    $subject = 'Verification for Stylo de Rento'; 
    $message = 'http://lilbearandlilpanda.com/styloderento/php/verify.php?email='.$email; 
    $headers = 'From:noreply@styloderento.com' . "\r\n" . 
    'Reply-To: '.$email . "\r\n" . 
    'X-Mailer: PHP/' . phpversion(); 
    mail($to, $subject, $message, $headers); 
}
?>
