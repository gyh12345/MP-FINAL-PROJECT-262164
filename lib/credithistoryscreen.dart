import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:styloderento/object_user.dart';

class CreditHistoryScreen extends StatefulWidget{
  final User user;
  const CreditHistoryScreen({Key key, this.user}) : super(key: key);
  _CreditHistoryScreenState createState() => _CreditHistoryScreenState();
}

class _CreditHistoryScreenState extends State<CreditHistoryScreen> {
  List creditHistoryData;
  bool _loadingCreditHistory = true;
  bool _creditHistoryEmpty = false;
  final f = new DateFormat('dd-MM-yyyy hh:mm a');

  void initState() {
    super.initState();
    _loadCreditTransaction();
  }

  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("Wallet History"),
        flexibleSpace: Image(image: AssetImage('assets/images/menu.jpg'), fit: BoxFit.cover),
      ),
      body: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              creditHistoryData == null
              ? Flexible(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Visibility(
                        visible: _loadingCreditHistory,
                        child: Column(
                          children: <Widget>[
                            CircularProgressIndicator(),
                            SizedBox(height: 10),
                            Text("Loading Wallet History\nPlease wait...", textAlign: TextAlign.center, style: TextStyle(fontSize: 20))
                          ],
                        )
                      ),
                      Visibility(
                        visible: _creditHistoryEmpty,
                        child: Text("Your Wallet History\nis Empty.", textAlign: TextAlign.center, style: TextStyle(fontSize: 20)),
                      )
                    ]
                  ),
                )
              )
              : Expanded(
                child: ListView.builder(
                  itemCount: creditHistoryData.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.fromLTRB(5, 1, 5, 1),
                        child: Card(
                          elevation: 10,
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(width:5),
                              creditHistoryData[index]['status'] == "Top Up" // Check if status is "Top Up" or "Purcahse"
                                ? Icon(Icons.account_balance_wallet, size: 45, color: Colors.blue)
                                : Icon(Icons.shopping_basket, size: 45, color: Colors.blue),
                              SizedBox(width: 20),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(creditHistoryData[index]['status'], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                  SizedBox(height: 5),
                                  Text(f.format(DateTime.parse(creditHistoryData[index]['date'])))
                                ],
                              ),
                              Expanded(
                                flex: 1,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: creditHistoryData[index]['status'] == "Top Up"
                                ? Text("+ RM " + creditHistoryData[index]['amount'], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
                                : Text("- RM " + creditHistoryData[index]['amount'], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
                                )
                              )
                            ],
                          ),
                        )
                      )
                    );
                  }
                )
              )
            ],
          ),
      )
    );
  }

  void _loadCreditTransaction() async {
      String urlLoadJobs = "https://lilbearandlilpanda.com/styloderento/php/load_creditpaymenthistory.php";
      await http.post(urlLoadJobs, body: {
        "email": widget.user.email,
      }).then((res) {
        print(res.body);
        if (res.body == "nodata") {
          setState(() {
            creditHistoryData = null;
            _loadingCreditHistory = false;
            _creditHistoryEmpty = true;
          });
        } else {
          setState(() {
            var extractdata = json.decode(res.body);
            creditHistoryData = extractdata["credithistory"];
          });
        }
      }).catchError((err) {
        print(err);
      });
  }
}