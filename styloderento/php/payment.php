<?php
error_reporting(0);

$email = $_GET['email'];
$mobile = $_GET['mobile']; 
$name = $_GET['name']; 
$amount = $_GET['amount']; 
$orderid = $_GET['orderid'];
$credit = $_GET['credit'];



$api_key = 'c5bc0781-ff4c-4182-9adc-b61c3b333f83';
$collection_id = 'wvwk0ckl';
$host = 'https://billplz-staging.herokuapp.com/api/v3/bills';


$data = array(
    'collection_id' => $collection_id,
    'email' => $email,
    'mobile' => $mobile,
    'name' => $name,
    'amount' => $amount * 100, // RM20
	'description' => 'Payment for order id '.$orderid,
	'credit' => $credit,
    'callback_url' => "https://lilbearandlilpanda.com/styloderento/return_url",
    'redirect_url' => "https://lilbearandlilpanda.com/styloderento/php/payment_update.php?userid=$email&mobile=$mobile&amount=$amount&orderid=$orderid&credit=$credit" 
);

$process = curl_init($host );
curl_setopt($process, CURLOPT_HEADER, 0);
curl_setopt($process, CURLOPT_USERPWD, $api_key . ":");
curl_setopt($process, CURLOPT_TIMEOUT, 30);
curl_setopt($process, CURLOPT_RETURNTRANSFER, 1);
curl_setopt($process, CURLOPT_SSL_VERIFYHOST, 0);
curl_setopt($process, CURLOPT_SSL_VERIFYPEER, 0);
curl_setopt($process, CURLOPT_POSTFIELDS, http_build_query($data) ); 

$return = curl_exec($process);
curl_close($process);

$bill = json_decode($return, true);

header("Location: {$bill['url']}");
?>