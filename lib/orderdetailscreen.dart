import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'object_order.dart';
import 'package:http/http.dart' as http;

class OrderDetailScreen extends StatefulWidget {
  final Order order;
  const OrderDetailScreen({Key key, this.order}) : super(key: key);
  _OrderDetailScreenState createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  List _orderdetails;
  String titlecenter = "Loading order details...";
  double screenHeight, screenWidth;
  bool _loadingOrderDetails = true;
  bool _orderDetailsEmpty = false;
  final f = new DateFormat('dd-MM-yyyy');

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details'),
        flexibleSpace: Image(image: AssetImage('assets/images/menu.jpg'), fit: BoxFit.cover),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, 
          children: <Widget>[
            _orderdetails == null
              ? Flexible(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Visibility(
                        visible: _loadingOrderDetails,
                        child: Column(
                          children: <Widget>[
                            CircularProgressIndicator(),
                            SizedBox(height: 10),
                            Text(
                              "Loading Order Details\nPlease wait...",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 20)
                            )
                          ],
                        )
                      ),
                      Visibility(
                        visible: _orderDetailsEmpty,
                        child: Text(
                          "Your Order Detail\nis Empty.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20)
                        ),
                      )
                    ]
                  ),
                )
              )
              : Expanded(
                  child: ListView.builder(
                    itemCount: _orderdetails.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.fromLTRB(5, 1, 5, 1),
                        child: InkWell(
                          onTap: null, //////////////
                          child: Card(
                            elevation: 5,
                            child: Padding(
                              padding: EdgeInsets.all(3),
                              child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  height: screenHeight / 5.5,
                                  width: screenWidth / 3.8,
                                  child: CachedNetworkImage( // Display product image
                                    fit: BoxFit.scaleDown,
                                    imageUrl: "https://lilbearandlilpanda.com/styloderento/images/product_images/${_orderdetails[index]['id']}.jpg",
                                    placeholder: (context, url) => Center(
                                      child: Container(
                                        height: 50, width: 50,
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) => Icon(Icons.error),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 3, right: 5),
                                  child: SizedBox(
                                    width: 2,
                                    child: Container(
                                      height: _orderdetails[index]['status'] == "Returned"
                                      ? screenHeight / 4.7        // If "Returned", shorter 
                                      : screenHeight / 3,         // If "Pending Return", longer
                                      color: _orderdetails[index]['status'] == "Returned"
                                      ? Colors.blue               // If "Returned", blue colour
                                      : Colors.redAccent          // If "Pending Return", red colour
                                    )
                                  )
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text( // Product Name
                                        _orderdetails[index]['name'],
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 18,
                                          color: Colors.black
                                        )
                                      ),
                                      SizedBox(height: 5),
                                      Text( // Product Price and Size
                                        "Price: RM " + _orderdetails[index]['price'] +
                                        "       Size: " + _orderdetails[index]['size'],
                                        style: TextStyle(color: Colors.black, fontSize: 16)
                                      ),
                                      SizedBox(height: 10),
                                      Text( // Rented n unit for n days
                                        "Rented " + _orderdetails[index]['cquantity'] + " unit(s) for " +
                                        _orderdetails[index]['day2rent'] + " day(s),",
                                        maxLines: 2,
                                        style: TextStyle(color: Colors.black, fontSize: 16)
                                      ),
                                      Text( // From when to when
                                        "from " + f.format(DateTime.parse(widget.order.dateorder)) +
                                        " to " + f.format(DateTime.parse(widget.order.dateorder).add(Duration(days: int.parse(_orderdetails[index]["day2rent"])))), 
                                        style: TextStyle(fontSize: 16, color: Colors.black)
                                      ),
                                      SizedBox(height: 10),
                                      Text( // Price, Quantity rented, Day rented and Delivery fee
                                        "Total: RM " + (
                                        double.parse(_orderdetails[index]['price']) * 
                                        double.parse(_orderdetails[index]['cquantity']) * 
                                        double.parse(_orderdetails[index]['day2rent']) + 
                                        double.parse(_orderdetails[index]['delivery'])
                                        ).toStringAsFixed(2) + 
                                        "\n(+ Shipping Fee: RM " + _orderdetails[index]['delivery'] + ")",
                                        maxLines: 2,
                                        style: TextStyle(fontSize: 16, color: Colors.black)
                                      ),
                                      SizedBox(height: 10),
                                      _orderdetails[index]['status'] == "Returned" // If "Pending Return", display return date and return address 
                                      ? Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: <Widget>[
                                          Text(
                                        "Status: " + _orderdetails[index]['status'],
                                        style: TextStyle(color: Colors.blueAccent, fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(width: 1),
                                      Icon(Icons.check_box, color: Colors.blueAccent),
                                      SizedBox(width: 5),
                                        ],
                                      )
                                      : Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text( // Return date
                                            "Status: " + _orderdetails[index]['status'] + 
                                            "\nPlease return by: " + f.format(DateTime.parse(widget.order.dateorder).add(Duration(days: (int.parse(_orderdetails[index]["day2rent"]) + 7)))),
                                            style: TextStyle(color: Colors.red, fontSize: 16),
                                          ),
                                          SizedBox(height: 10),
                                          Text( // Return address
                                            "Return Address:\n" + _orderdetails[index]['address'],
                                            style: TextStyle(color: Colors.black, fontSize: 16)
                                          )
                                        ],
                                      )
                                    ],
                                  )
                                ),
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
      ),
    );
  }

  _loadOrderDetails() async {
    String urlLoadJobs =
        "https://lilbearandlilpanda.com/styloderento/php/load_carthistory.php";
    await http.post(urlLoadJobs, body: {
      "orderid": widget.order.orderid,
    }).then((res) {
      print(res.body);
      if (res.body == "nodata") {
        setState(() {
          _orderdetails = null;
          titlecenter = "No Previous Payment";
        });
      } else {
        setState(() {
          var extractdata = json.decode(res.body);
          _orderdetails = extractdata["carthistory"];
        });
      }
    }).catchError((err) {
      print(err);
    });
  }
}
