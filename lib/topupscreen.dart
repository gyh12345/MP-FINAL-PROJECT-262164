import 'dart:async';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/material.dart';
import 'package:styloderento/object_user.dart';

class TopUpScreen extends StatefulWidget {
  final User user;
  final String val;
  TopUpScreen({this.user, this.val});

  _TopUpScreenState createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  Completer<WebViewController> _controller = Completer<WebViewController>();

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('BUY STORE CREDIT')),
      body: Column(
        children: <Widget>[
          Expanded(
            child: WebView(
              initialUrl: 'https://lilbearandlilpanda.com/styloderento/php/top_up_credit.php?'+
                          'email=' + widget.user.email + '&mobile=' + widget.user.phone +
                          '&name=' + widget.user.name  + '&amount=' + widget.val +
                          '&csc='  + widget.user.credit,
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController webViewController) {
                _controller.complete(webViewController);
              },
            ),
          )
        ],
      )
    );
  }
}
