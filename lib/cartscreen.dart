import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:random_string/random_string.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:styloderento/object_user.dart';
import 'package:styloderento/mainscreen.dart';
import 'package:styloderento/paymentscreen.dart';

class CartScreen extends StatefulWidget{
  final User user;
  const CartScreen({Key key, this.user}) : super(key: key);
  
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  double screenHeight, screenWidth;
  List cartData;
  int quantity, unit, day;             // To help count total price for each item
  double totalPrice = 0.0;             // Price * Day * Quantity of an item
  double totalDeliveryFee = 0.0;       // Total delivery fee of all items 
  double totalPriceWithDelivery = 0.0; // Total price of an item + it's delivery fee
  double grandTotalPrice = 0.0;        // Total price of all items + Total delivery fee of all items
  bool loading = true, empty = false;  // Display either"Loading Cart" or "Cart is Empty" message
  bool _storecredit = false;           // Toggle store credit check box
  double usedCredit = 0;               // To store the amount of credit used when the check box is toggled.
  String address;                      // To store the delivery address of user

  void initState(){
    super.initState();
    _loadCart();
    loadPreference();
  }

  Widget build(BuildContext context){
    screenHeight = MediaQuery.of(context).size.height; // 737.46
    screenWidth = MediaQuery.of(context).size.width;   // 392.73

    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Image(image: AssetImage('assets/images/menu.jpg'), fit: BoxFit.cover),
          leading: GestureDetector(
            child: Icon(Icons.arrow_back, color: Colors.white,),
            onTap:() => _onBackPressed()
          ),
          title: Text("Shopping Cart", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          actions: <Widget>[
            IconButton(
              onPressed: _deleteAllCart,
              icon: Icon(Icons.delete_forever, color: Colors.white, size: 25),
            ),
            SizedBox(width: screenWidth / 24)
          ],
        ),
        body: Container( 
          child: Column(
            children: <Widget>[
              SizedBox(height: 10),
              Text("Content of Your Cart", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 5),
              cartData == null
                ? Flexible(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Visibility(
                          visible: loading,
                          child: Column(
                            children: <Widget>[
                              CircularProgressIndicator(),
                              SizedBox(height: 10),
                              Text("Loading Cart Content\nPlease wait...", textAlign: TextAlign.center, style: TextStyle(fontSize: 20))
                            ],
                          )
                        ),
                        Visibility(
                          visible: empty,
                          child: Text("The shopping cart is empty.\nBrowse some items now!", textAlign: TextAlign.center, style: TextStyle(fontSize: 20)),
                        )
                      ],  
                    )
                  )
                )
                : Expanded(
                  child: ListView.builder(
                    itemCount: cartData == null ? 1: cartData.length + 2,
                    itemBuilder: (context, index){
                      if (index == cartData.length) {
                        return Container(
                          height: screenHeight / 4.5,
                          width: screenWidth / 2.5,
                          child: Card(
                            elevation: 5,
                            child: Padding(
                              padding: EdgeInsets.only(left:10 ,right:10, top:3) ,
                              child: Column(
                                children: <Widget>[
                                  SizedBox(height: 5),
                                  Text("Confirm Your Delivery Address", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)),
                                  SizedBox(height: 9),
                                  Row(
                                    children: <Widget>[
                                      SizedBox(width: 10),
                                      widget.user.address == ""
                                      ? Container(
                                          alignment: Alignment.center,
                                          height: screenHeight / 7.37,
                                          width: screenWidth / 1.31,
                                          child: Text("    Your delivery address is empty.\n   Please set it now!", 
                                            textAlign: TextAlign.center, style: TextStyle(color: Colors.black, fontSize: 18)
                                          ) 
                                        )
                                      : GestureDetector(
                                          onTap: _editAddress,
                                          child: Container(
                                            decoration: BoxDecoration(border: Border.all(width: 3, color: Colors.blueAccent)),
                                            height: screenHeight / 7.37,
                                            width: screenWidth / 1.31,
                                            child: Text(widget.user.address, 
                                              textAlign: TextAlign.center, maxLines: 5, style: TextStyle(color: Colors.black, fontSize: 18)
                                            ) 
                                          ),
                                        ),
                                      SizedBox(width: 20),
                                      GestureDetector(
                                        child: Icon(Icons.edit, color: Colors.blueAccent),
                                        onTap: _editAddress,
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            )
                          ),
                        );
                      }
////////////////////////////////////////////////////////////////////////////////////////
                      if (index == cartData.length + 1) {
                        return Container(
                          //height: screenHeight / 3,
                          child: Card(
                            elevation: 5,
                            child: Column(
                              children: <Widget>[
                                SizedBox(height: 10),
                                Text("Payment", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.black)),
                                SizedBox(height: 10),
                                Container(
                                  padding: EdgeInsets.fromLTRB(40, 0, 40, 0),
                                  child: Table(
                                    defaultColumnWidth: FlexColumnWidth(1.0),
                                    columnWidths: {
                                      0: FlexColumnWidth(7),
                                      1: FlexColumnWidth(3),
                                    },
                                    children: [
                                      TableRow(children: [
                                        TableCell(
                                          child: Container(
                                            alignment:Alignment.centerLeft,
                                            height: 25,
                                            child: Text("Total Item Price ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black))
                                          )
                                        ),
                                        TableCell(
                                          child: Container(
                                            alignment: Alignment.centerLeft,
                                            height: 25,
                                            child: Text("RM" + totalPrice.toStringAsFixed(2) ?? "0.0", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black)),
                                          ),
                                        ),
                                      ]),
                                      TableRow(children: [
                                        TableCell(
                                          child: Container(
                                            alignment: Alignment.centerLeft,
                                            height: 25,
                                            child: Text("Total Delivery Charge ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black))
                                          )
                                        ),
                                        TableCell(
                                          child: Container(
                                            alignment: Alignment.centerLeft,
                                            height: 25,
                                            child: Text("RM" + totalDeliveryFee.toStringAsFixed(2) ?? "0.0", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black)),
                                          ),
                                        ),
                                      ]),
                                      TableRow(children: [
                                        TableCell(
                                          child: Container(
                                            alignment: Alignment.centerLeft,
                                            height: 25,
                                            child: Text("Store Credit (RM " + widget.user.credit + ")", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black))
                                          ),
                                        ),
                                        TableCell(
                                          child: Container(
                                            alignment: Alignment.centerLeft,
                                            height: 25,
                                            child: Checkbox(
                                              value: _storecredit,
                                              onChanged: (bool value) {
                                                _onStoreCredit(value);
                                              },
                                            ),
                                          ),
                                        ),
                                      ]),
                                      TableRow(children: [
                                        TableCell(
                                          child: Container(
                                            alignment: Alignment.centerLeft,
                                            height: 25,
                                            child: Text("Total Amount ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black))
                                          ),
                                        ),
                                        TableCell(
                                          child: Container(
                                            alignment: Alignment.centerLeft,
                                            height: 25,
                                            child: Text("RM" + grandTotalPrice.toStringAsFixed(2) ?? "0.0", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black)),
                                          ),
                                        ),
                                      ]),
                                    ]
                                  )
                                ),
                                SizedBox(height: 8),
                                RaisedButton(
                                  color: Colors.blueAccent,
                                  child: Text("Proceed to Payment", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white)),
                                  onPressed: makePayment,
                                ),
                                SizedBox(height: 5)
                              ],
                            ),
                          )
                        );
                      }
                      index -= 0;
///////////////////////////////////////////////////////////////////////////////////////////////////////
                      return Card(
                        elevation: 10,
                          child: Padding(
                            padding: EdgeInsets.all(3),
                              child: Row(
                                children: <Widget>[
                                  Column(
                                    children: <Widget>[
                                      Container(
                                        height: screenHeight / 6.1,
                                        width: screenWidth / 4.1,
                                        child: CachedNetworkImage(
                                          fit: BoxFit.scaleDown,
                                          imageUrl: "https://lilbearandlilpanda.com/styloderento/images/product_images/${cartData[index]['id']}.jpg",
                                          placeholder: (context, url) => Center(
                                            child: Container(
                                              height: 50, width: 50,
                                              child: CircularProgressIndicator(),
                                            ),
                                          ),
                                          errorWidget: (context, url, error) => new Icon(Icons.error),
                                        ),
                                      ),
                                      Text("RM " + double.parse(cartData[index]['price']).toStringAsFixed(2), 
                                        style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500)
                                      ),
                                      Text(cartData[index]['quantity'] + " unit(s) left",
                                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 14),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 3, right: 5),
                                    child: SizedBox(
                                      width: 2,
                                      child: Container(
                                        height: screenHeight / 4.9,
                                        color: Colors.blue,
                                      )
                                    )
                                  ),
                                  Container(
                                    color: Colors.white,
                                    width: screenWidth / 1.44,
                                    child: Column(
                                      children: <Widget>[
                                        Text(
                                          cartData[index]['name'], 
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500, 
                                            fontSize: 18, 
                                            color: Colors.black
                                          ),
                                        ),
                                        SizedBox(height:3),
                                        Text("Size: " + cartData[index]['size'],
                                            style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500)
                                        ),
                                        SizedBox(height:10),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                            GestureDetector( // unit--
                                              child: Container(
                                                decoration: BoxDecoration(border: Border.all(color: Colors.blueAccent)),
                                                child: Icon(Icons.remove, color: Colors.blueAccent, size: 20),
                                              ),
                                              onTap:() {
                                                unit = int.parse(cartData[index]['cquantity']);
                                                if (unit == 1){
                                                  _deleteCart(index);
                                                } else {
                                                  setState(() {
                                                    unit--;
                                                    cartData[index]['cquantity'] = unit.toString();
                                                    _updateCart(index);
                                                  });
                                                }
                                              },  
                                            ),
                                            SizedBox(width:8),
                                            Text(cartData[index]['cquantity'], style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500)),
                                            SizedBox(width:8),
                                            GestureDetector( // unit++
                                              child: Container(
                                                decoration: BoxDecoration(border: Border.all(color: Colors.blueAccent)),
                                                child: Icon(Icons.add, color: Colors.blueAccent, size: 20),
                                              ),
                                              onTap:() {
                                                unit = int.parse(cartData[index]['cquantity']);
                                                quantity = int.parse(cartData[index]['quantity']);
                                                if (unit == quantity){
                                                  Toast.show("Quantity not available.", context,
                                                    duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                                                } else {
                                                  setState(() {
                                                    unit++;
                                                    cartData[index]['cquantity'] = unit.toString();
                                                    _updateCart(index);
                                                  });
                                                }
                                              },  
                                            ),
                                            Text(" unit(s)", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 16)),
                                            SizedBox(width: 18),
                                            GestureDetector( // day--
                                              child: Container(
                                                decoration: BoxDecoration(border: Border.all(color: Colors.blueAccent)),
                                                child: Icon(Icons.remove, color: Colors.blueAccent, size: 20),
                                              ),
                                              onTap:() {
                                                day = int.parse(cartData[index]['day2rent']);
                                                if (day == 1){
                                                  Toast.show("Cannot rent less than 1 day.", context,
                                                    duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                                                } else {
                                                  setState(() {
                                                    day--;
                                                    cartData[index]['day2rent'] = day.toString();
                                                    _updateCart(index);
                                                  });
                                                }
                                              },  
                                            ),
                                            SizedBox(width:8),
                                            Text(cartData[index]['day2rent'], style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500)),
                                            SizedBox(width:8),
                                            GestureDetector( // day++
                                              child: Container(
                                                decoration: BoxDecoration(border: Border.all(color: Colors.blueAccent)),
                                                child: Icon(Icons.add, color: Colors.blueAccent, size: 20),
                                              ),
                                              onTap:() {
                                                day = int.parse(cartData[index]['day2rent']);
                                                setState(() {
                                                  day++;
                                                  cartData[index]['day2rent'] = day.toString();
                                                  _updateCart(index);
                                                });
                                              },  
                                            ),
                                            Text(" day(s)", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 16)),
                                          ]
                                        ),
                                        SizedBox(height: 15),
                                        Align(
                                          alignment: Alignment.topLeft,
                                          child: Row(
                                            children: <Widget>[
                                              Container(
                                                width: screenWidth / 2,
                                                child: Column(
                                                  children: <Widget>[
                                                    Row(
                                                      children: <Widget>[
                                                        Text("   RM " + double.parse(cartData[index]['yourprice']).toStringAsFixed(2) +"", style: TextStyle(color: Colors.black)),    
                                                      ],
                                                    ),
                                                    Row(
                                                      children: <Widget>[
                                                        Text("+ RM "+cartData[index]['deliprice']+" (Shipping Fee)"),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: <Widget>[
                                                        Text("= Sub Total: RM " + cartData[index]['yourpricewithdeli'], style: TextStyle(color: Colors.black)),
                                                      ],
                                                    ) 
                                                  ]
                                                )
                                              ),
                                              SizedBox(width: screenWidth / 13),
                                              GestureDetector(
                                                child: Icon(Icons.delete_outline, size:27, color: Colors.lightBlue),
                                                onTap:() => _deleteCart(index)
                                              )
                                            ]
                                          )
                                        ), 
                                      ],
                                    ),
                                  ),
                            ]
                          )
                        )
                      );
                    }
                  ),
                ),
            ],  
          )
        )
      )
    );
  }

  void _loadCart(){
      totalPrice = 0;
      totalDeliveryFee = 0;
      grandTotalPrice = 0;
      loading = true; 
      empty = false;
      String loadCartUrl = "https://lilbearandlilpanda.com/styloderento/php/load_cart.php";
      http.post(loadCartUrl, body: {
        "email": widget.user.email,
      }).then((res) {
        print(res.body);
        if (res.body == "Cart Empty"){
          setState(() {
            loading = false;
            empty = true;
          });
          Toast.show("The cart is empty.", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        } else {
          setState(() {
            var extractdata = json.decode(res.body);
            cartData = extractdata["cart"];
            for (int i = 0; i < cartData.length; i++) {
              totalPrice = double.parse(cartData[i]['yourprice']) + totalPrice; // Count cumulative total price of all items (Without delivery)
              totalDeliveryFee = double.parse(cartData[i]['deliprice']) + totalDeliveryFee; // Count cumulative delivery fee of all items
              cartData[i]['yourpricewithdeli'] = double.parse(cartData[i]['yourpricewithdeli']).toStringAsFixed(2); // change to 2 decimal places
              print(cartData[i]['yourpricewithdeli']);
            }
            print(totalPrice);
            print(totalDeliveryFee);
            grandTotalPrice = totalPrice + totalDeliveryFee; // Count total price + total delivery for all items
            print(grandTotalPrice);
          });
        }
      }).catchError((err) {
        print(err);
      });
  }

  void _updateCart(int index) { // To modify quantity and day to rent of items
    int quantity = int.parse(cartData[index]['cquantity']);
    int day2rent = int.parse(cartData[index]['day2rent']);
    String urlLoadJobs = "https://lilbearandlilpanda.com/styloderento/php/update_cart.php";
    ProgressDialog pr = new ProgressDialog(context,
      type: ProgressDialogType.Normal, isDismissible: true);
    pr.style(message: "Updating cart...");
    pr.show();
    http.post(urlLoadJobs, body: {
      "email": widget.user.email,
      "prodid": cartData[index]['id'],
      "quantity": quantity.toString(),
      "day2rent": day2rent.toString()
    }).then((res) {
      print(res.body);
      if (res.body.contains("success")) {
        Toast.show("Cart Updated.", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        _loadCart();
      } else {
        Toast.show("Update Cart Failed.", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        _loadCart();
      }
      pr.hide();
    }).catchError((err) {
      print(err);
      pr.hide();
    });
  }

  void _deleteCart(int index){ // To delete an item from cart
      showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(10)),
            title: Text("Remove Item", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            content: Container(
              child: Text("Remove this item from your cart?", style: TextStyle(fontSize: 16)),
            ),
            actions: <Widget>[
              RaisedButton(
                elevation: 5,
                child: Text("Confirm & Remove", style: TextStyle(fontSize: 16)),
                color: Colors.redAccent,
                shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(10)),
                onPressed:() {
                  String deleteAllUrl = "https://lilbearandlilpanda.com/styloderento/php/delete_cart.php";
                  http.post(deleteAllUrl, body:{
                    "email": widget.user.email,
                    "prodid": cartData[index]['id']
                  }).then((res) {  
                    print(res.body);
                    if (res.body.contains("empty")){                  
                      Toast.show("A cart item has been removed.", context,
                        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                      Navigator.of(context).pop();
                      Navigator.push(context, 
                        MaterialPageRoute(builder: (BuildContext context) => CartScreen(user: widget.user)));               
                    }
                    if (res.body.contains("success")){
                      _loadCart();                
                      Toast.show("Item deleted.", context,
                        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                      Navigator.of(context).pop();
                    }
                    if (res.body.contains("failed")){
                      Toast.show("Failed to delete all from cart.", context,
                        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                      Navigator.of(context).pop();
                    }
                  }).catchError((error){
                    print(error);
                  });
                }
              ),
              RaisedButton(
                elevation: 5,
                child: Text("Cancel", style: TextStyle(color: Colors.white, fontSize: 16)),
                color: Colors.lightBlueAccent,
                shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(10)),
                onPressed:() => Navigator.of(context).pop() 
              )
            ],
          );
        }
      );
  }

  void _deleteAllCart(){ // To delete all items from cart
      showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(10)),
            title: Text("Remove All", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            content: Container(
              child: Text("Remove all items from you cart?", style: TextStyle(fontSize: 16)),
            ),
            actions: <Widget>[
              RaisedButton(
                elevation: 5,
                child: Text("Confirm & Remove", style: TextStyle(fontSize: 16)),
                color: Colors.redAccent,
                shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(10)),
                onPressed:() {
                  String deleteAllUrl = "https://lilbearandlilpanda.com/styloderento/php/delete_cart.php";
                  http.post(deleteAllUrl, body:{
                    "email": widget.user.email
                  }).then((res) {
                    print(res.body);
                    if (res.body.contains("empty")){                  
                      Toast.show("Succesfully removed all cart item.", context,
                        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                      Navigator.of(context).pop();
                      Navigator.push(context, 
                        MaterialPageRoute(builder: (BuildContext context) => CartScreen(user: widget.user)));               
                    }
                    else {
                      Toast.show("Failed to delete all from cart.", context,
                        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                      Navigator.of(context).pop();
                    }
                  }).catchError((error){
                    print(error);
                  });
                }
              ),
              RaisedButton(
                elevation: 5,
                child: Text("Cancel", style: TextStyle(color: Colors.white, fontSize: 16)),
                color: Colors.lightBlueAccent,
                shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(10)),
                onPressed:() => Navigator.of(context).pop() 
              )
            ],
          );
        }
      );
  }

  void _editAddress(){ // To edit & confirm user's delivery address
      TextEditingController _addressController = new TextEditingController();
      _addressController.text = widget.user.address;
      showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(10)),
            title: Text("Edit Your Delivery Address", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            content: TextFormField(
              autofocus: true,
              autocorrect: false,
              controller: _addressController,
              maxLines: 5,
            ),
            actions: <Widget>[
              RaisedButton(
                elevation: 5,
                child: Text("Confirm", style: TextStyle(fontSize: 16)),
                color: Colors.blueAccent,
                shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(10)),
                onPressed:() {
                  String updateAddressUrl = "https://lilbearandlilpanda.com/styloderento/php/update_cart.php";
                  http.post(updateAddressUrl, body:{
                    "email": widget.user.email,
                    "address": _addressController.text
                  }).then((res) {
                    print(res.body);
                    if (res.body.contains("success")){         
                      setState(() {
                        widget.user.address = _addressController.text;
                      });
                      Toast.show("Succesfully updated delivery address", context,
                        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                      Navigator.of(context).pop();        
                    }
                    else {
                      Toast.show("Failed to update delivery address", context,
                        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                      Navigator.of(context).pop();
                    }
                  }).catchError((error){
                    print(error);
                  });
                } 
              ),
              RaisedButton(
                elevation: 5,
                child: Text("Cancel", style: TextStyle(color: Colors.white, fontSize: 16)),
                color: Colors.blueAccent,
                shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(10)),
                onPressed:() => Navigator.of(context).pop() 
              )
            ],
          );
        }
      );
  }

  void savePreference(String address) async { // Save user address as preference
      SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString("address", "");
          await prefs.setString('address', address);
      setState(() {
        widget.user.address = address;
      });
      Toast.show("Delivery Address saved.", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
  }

  void loadPreference() async { // Load user address
      SharedPreferences prefs = await SharedPreferences.getInstance();
      address = (prefs.getString("address"))??"";
      if(address.length > 1) {
        setState((){
          widget.user.address = address;
        });
      }
  }

  void _onStoreCredit(bool newValue) => setState(() { // Toggle store credit check box
      _storecredit = newValue;
      if (_storecredit) {
        if (double.parse(widget.user.credit) >= grandTotalPrice){
          usedCredit = grandTotalPrice;
          grandTotalPrice = 0;
        } 
        else {
          grandTotalPrice = grandTotalPrice - double.parse(widget.user.credit);
          usedCredit = double.parse(widget.user.credit);
        }
      } 
      else {
        grandTotalPrice = totalPrice + totalDeliveryFee;
        usedCredit = 0;
      }
  });

  Future<void> makePayment() async { // go to Payment Screen
    User _user = widget.user;
    var now = new DateTime.now();
    var formatter = new DateFormat('ddMMyyyy-');
    String orderid = widget.user.email.substring(1,4) + "-" + formatter.format(now) + randomAlphaNumeric(6);
    print(orderid);


    //if (double.parse(widget.user.credit) >= (totalPrice+totalDeliveryFee))
    await Navigator.push(context,
      MaterialPageRoute(builder: (BuildContext context) => PaymentScreen(user: _user, val: grandTotalPrice.toStringAsFixed(2), orderid: orderid, usedCredit: this.usedCredit.toString()))
    );
    setState(() {
      widget.user.quantity = _user.quantity;
      widget.user.credit = _user.credit;
    });
    _loadCart();
  }

  Future<bool> _onBackPressed() async { // to return cart quantity to main screen
      Navigator.push(context, 
        MaterialPageRoute(builder: (BuildContext context) => MainScreen(user: widget.user)));
      return null;
  }
}