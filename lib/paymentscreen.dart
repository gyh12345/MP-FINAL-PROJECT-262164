import 'package:flutter/material.dart';
import 'dart:async';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:styloderento/object_user.dart';
import 'package:styloderento/cartscreen.dart';

class PaymentScreen extends StatefulWidget{
  final User user;
  final String orderid, val, usedCredit;
  PaymentScreen({this.user, this.orderid, this.val, this.usedCredit});

  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  Completer<WebViewController> _controller = Completer<WebViewController>();
  Widget build(BuildContext context){
    return WillPopScope( 
      onWillPop: _onBackPressed,
      child:
      Scaffold(
      appBar: AppBar(title: Text("PAYMENT")),
      body: Column(
        children: <Widget>[
          Expanded(
            child: WebView(
              initialUrl: 'https://lilbearandlilpanda.com/styloderento/php/payment.php?email=' + widget.user.email +
                          '&mobile=' + widget.user.phone + '&name=' + widget.user.name + 
                          '&amount=' + widget.val + '&orderid=' + widget.orderid + '&credit=' + widget.usedCredit,
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController webViewController) {
                _controller.complete(webViewController);
              },
            ),
          )
        ],
      )
    ));
  }

  Future<bool> _onBackPressed() async { // to return cart quantity to main screen
      return Navigator.push(context, 
        MaterialPageRoute(builder: (BuildContext context) => CartScreen(user: widget.user)));  
  }
}