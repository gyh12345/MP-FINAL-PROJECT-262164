import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'object_user.dart';
import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:styloderento/object_order.dart';
import 'package:styloderento/orderdetailscreen.dart';

class PaymentHistoryScreen extends StatefulWidget{
  final User user;
  const PaymentHistoryScreen({Key key, this.user}) : super(key: key);
  _PaymentHistoryScreenState createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  List _paymentdata;
  String titlecenter = "Loading payment history...";
  final f = new DateFormat('dd-MM-yyyy hh:mm a');
  var parsedDate;
  double screenHeight, screenWidth;
  bool _loadingPaymentHistory = true;
  bool _paymentHistoryEmpty = false;

  void initState() {
    super.initState();
    _loadPaymentHistory();
  }

  Widget build(BuildContext context){
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text("Payment History"),
        flexibleSpace: Image(image: AssetImage('assets/images/menu.jpg'), fit: BoxFit.cover),      
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _paymentdata == null
              ? Flexible(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Visibility(
                        visible: _loadingPaymentHistory,
                        child: Column(
                          children: <Widget>[
                            CircularProgressIndicator(),
                            SizedBox(height: 10),
                            Text("Loading Payment History\nPlease wait...", textAlign: TextAlign.center, style: TextStyle(fontSize: 20))
                          ],
                        )
                      ),
                      Visibility(
                        visible: _paymentHistoryEmpty,
                        child: Text("The Payment History\nis Empty.", textAlign: TextAlign.center, style: TextStyle(fontSize: 20)),
                      )
                    ]
                  ),
                )
              )
              : Expanded(
                child: ListView.builder(
                  itemCount: _paymentdata.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.fromLTRB(5, 1, 5, 1),
                      child: InkWell(
                        onTap: () => loadOrderDetails(index),
                        child: Card(
                          elevation: 5,
                          child: Padding(
                            padding: EdgeInsets.all(5),
                            child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(width:5),
                              Expanded(
                                flex: 0,
                                child: Column( // Order id and Date rented
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text("Order: " + _paymentdata[index]['orderid'], style: TextStyle(color: Colors.black, fontSize: 16)),
                                    SizedBox(height: 5),
                                    Text("Date: " + f.format(DateTime.parse(_paymentdata[index]['date'])), style: TextStyle(color: Colors.black, fontSize: 16)), 
                                  ],
                                )
                              ),
                              Expanded(
                                flex: 1,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Column( // Bill id and Total paid
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: <Widget>[
                                      Text("Bill: " + _paymentdata[index]['billid'], style: TextStyle(color: Colors.black, fontSize: 16)),
                                      SizedBox(height: 5),
                                      Text("RM " + _paymentdata[index]['total'], style: TextStyle(color: Colors.black, fontSize: 16)),
                                    ],
                                  )
                                )
                              ),
                              SizedBox(width: 3),
                              Icon(Icons.keyboard_arrow_right, color: Colors.blue)
                            ],
                          ),
                        )
                      )
                      )
                    );
                  }
                )
              )
          ]
        ),
      )
    );
  }

  Future<void> _loadPaymentHistory() async {
    String urlLoadJobs = "https://lilbearandlilpanda.com/styloderento/php/load_paymenthistory.php";
    await http.post(urlLoadJobs, body: {
      "email": widget.user.email
    }).then((res) {
      print(res.body);
      if (res.body == "nodata") {
        setState(() {
          _paymentdata = null;
        });
      } else {
        setState(() {
          var extractdata = json.decode(res.body);
          _paymentdata = extractdata["payment"];
        });
      }
    }).catchError((err) {
      print(err);
    });
  }

  void loadOrderDetails(int index) {
    Order order = new Order(
      billid: _paymentdata[index]['billid'],
      orderid: _paymentdata[index]['orderid'],
      total: _paymentdata[index]['total'],
      dateorder: _paymentdata[index]['date']
    );
    Navigator.push(
      context, MaterialPageRoute(
        builder: (BuildContext context) => OrderDetailScreen(order: order)));
  }
}