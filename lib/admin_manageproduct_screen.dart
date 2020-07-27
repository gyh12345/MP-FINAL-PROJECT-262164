import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:toast/toast.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:flutter/services.dart';
import 'package:recase/recase.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:styloderento/object_user.dart';
import 'package:styloderento/object_product.dart';
import 'package:styloderento/productscreen.dart';
import 'package:styloderento/admin_addproduct_screen.dart';
import 'package:styloderento/admin_editproduct_screen.dart';

class AdminProductScreen extends StatefulWidget {
  final User user;
  const AdminProductScreen({Key key, this.user}) : super(key: key);
  _AdminProductScreenState createState() => _AdminProductScreenState();
}

class _AdminProductScreenState extends State<AdminProductScreen> {
  double screenHeight, screenWidth;
  List outfitData;
  String searchByName; // To store search item
  String sortType = "Recent"; 
  bool _searchVisible = false; // Toggle search bar
  bool _sortVisible = false; // Toggle sort bar
  List<bool> _sortPressed = [true, false, false, false, false, false]; // Toggle sort type

  void initState() {
    super.initState();
    _loadProduct();
  }

  Widget build(BuildContext context) {
    TextEditingController _searchController = new TextEditingController();
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        flexibleSpace: Image(image: AssetImage('assets/images/menu.jpg'), fit: BoxFit.cover),
        title: GestureDetector( // Search bar
          child: Container(
            width: 185, height: 35,
            child: Row(
              children: <Widget>[
                SizedBox(width: 6),
                Icon(Icons.search, size: 25, color: Colors.blue),
                Text("  Admin MODE", style: TextStyle(fontSize: 18, color: Colors.blue))                
              ],
            ),
            decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(30)),
            ),
          ),
          onTap:() {
            setState(() {
              if (_searchVisible == true)         // hide search
                _searchVisible = false;
              else if (_searchVisible == false) { // hide sort, show search
                _sortVisible = false;            
                _searchVisible = true;                }
              });
          }
        ),
        actions: <Widget>[
          Padding( // Sort bar
            padding: EdgeInsets.only(right: 15.0),
            child: GestureDetector( 
              child: Container(
                child: Row(
                  children: <Widget>[
                    Text("Sort", style: TextStyle(fontSize: 18, color: Colors.white)),
                    SizedBox(width: 3),
                    Icon(Icons.sort, size: 26, color: Colors.white),
                  ],
                ),
              ),
              onTap: () {
                setState(() {
                  if (_sortVisible == true)         // hide sort
                    _sortVisible = false;
                  else if (_sortVisible == false) { // hide search, show sort
                    _searchVisible = false;
                    _sortVisible = true;
                  }
                });
              } 
            )
          ),
          Padding( // Add Product
            padding: EdgeInsets.only(right: 12.0),
            child: GestureDetector(
              child: Icon(Icons.add_box, size: 26, color: Colors.white),
              onTap: _onTapAddProduct
            )
          ),
        ],
      ),
      body: outfitData == null
      ? Container(
        decoration: BoxDecoration(image: DecorationImage(image: AssetImage("assets/images/main.jpg"), fit: BoxFit.cover)),
        child: Center(
          child: Column(
            children: <Widget>[
              SizedBox(height: screenHeight / 2.50),
              CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Colors.white)),
              SizedBox(height: 10),
              Text(
                "Loading Products\nPlease Wait...",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25, color: Colors.white),
              )
            ],
          )
        ),
      )
      : Container(
        width: screenWidth, height: screenHeight,
        child: Column(
          children: <Widget>[
            Visibility( // Search here
              visible: _searchVisible,
              child: Card(
                elevation: 10,
                child: Container(
                  height: 42, width: screenWidth,
                  child: TextField(
                    onSubmitted: (search) => _sortClothingByName(search),
                    autofocus: true,
                    controller: _searchController,
                    style: TextStyle(fontSize: 18),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: "Search dresses, suits and more...",
                      hintStyle: TextStyle(fontSize: 18),
                      border: InputBorder.none,
                      prefixIcon: IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed:() {
                          setState(() {
                            _searchVisible = false;
                          });
                        },
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.close),
                        onPressed: _searchController.clear,
                      )
                    ),
                  ),
                ),
              )
            ),
            Visibility( // Sort buttons here
              visible: _sortVisible,
              child: Card(
                elevation: 10,
                child: Padding(
                  padding: EdgeInsets.only(left: 5, right: 5),
                  child: Scrollbar(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              RaisedButton( // "RECENT" button
                                elevation: 5,
                                color: _sortPressed[0] // Clicked = RED, not clicked = BLUE
                                  ? Colors.redAccent
                                  : Colors.lightBlueAccent,
                                splashColor: Colors.redAccent,
                                shape: ContinuousRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)
                                ),
                                child: Text("Recent", style: TextStyle(fontSize: 18, color: Colors.white)),
                                onPressed:() {
                                  setState(() {
                                    if (_sortPressed[0] == true) // If already RED, return
                                      return;
                                    else {
                                      sortType = "Recent";
                                      for (int i=1; i<6; i++) // Set all other buttons to BLUE
                                        _sortPressed[i] = false;
                                      _sortPressed[0] = !_sortPressed[0];
                                      _sortClothingByType(sortType);
                                    }
                                  });
                                }
                              ),
                            ],
                          ),
                          SizedBox(width: 5),
                          Column(
                            children: <Widget>[
                              RaisedButton( // "SUIT" button
                                elevation: 5,
                                color: _sortPressed[1] // Clicked = RED, not clicked = BLUE
                                  ? Colors.redAccent
                                  : Colors.lightBlueAccent,
                                splashColor: Colors.redAccent,
                                shape: ContinuousRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)
                                ),
                                child: Text("Suit", style: TextStyle(fontSize: 18, color: Colors.white)),
                                onPressed:() {
                                  setState(() {
                                    if (_sortPressed[1] == true) // If already RED, return
                                      return;
                                    else {
                                      sortType = "Suit";
                                      _sortPressed[0] = false; // Set all other buttons to BLUE
                                      _sortPressed[1] = !_sortPressed[1];
                                      for (int i=2; i<6; i++)
                                        _sortPressed[i] = false;
                                      _sortClothingByType(sortType);
                                    }
                                  });
                                }
                              ),
                            ],
                          ),
                          SizedBox(width: 5),
                          Column(
                            children: <Widget>[
                              RaisedButton( // "DRESS" button
                                elevation: 5,
                                color: _sortPressed[2] // Clicked = RED, not clicked = BLUE
                                  ? Colors.redAccent
                                  : Colors.lightBlueAccent,
                                splashColor: Colors.redAccent,
                                shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                child: Text("Dress", style: TextStyle(fontSize: 18, color: Colors.white)),
                                onPressed:() {
                                  setState(() {
                                    if (_sortPressed[2] == true) // If already RED, return
                                      return;
                                    else {
                                      sortType = "Dress";
                                      for (int i=0; i<2; i++) // Set all other buttons to BLUE
                                        _sortPressed[i] = false;
                                      _sortPressed[2] = !_sortPressed[2];
                                      for (int i=3; i<6; i++)
                                        _sortPressed[i] = false;
                                      _sortClothingByType(sortType);
                                    }
                                  });
                                }
                              ),
                            ],
                          ),
                          SizedBox(width: 5),
                          Column(
                            children: <Widget>[
                              RaisedButton( // "BLAZER" button
                                elevation: 5,
                                color: _sortPressed[3] // Clicked = RED, not clicked = BLUE
                                  ? Colors.redAccent
                                  : Colors.lightBlueAccent,
                                splashColor: Colors.redAccent,
                                shape: ContinuousRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)
                                ),
                                child: Text("Blazer", style: TextStyle(fontSize: 18, color: Colors.white)),
                                onPressed:() {
                                  setState(() {
                                    if (_sortPressed[3] == true) // If already RED, return
                                      return;
                                    else {
                                      sortType = "Blazer";
                                      for (int i=0; i<3; i++) // Set all other buttons to BLUE
                                        _sortPressed[i] = false;
                                      _sortPressed[3] = !_sortPressed[3];
                                      for (int i=4; i<6; i++)
                                        _sortPressed[i] = false;
                                      _sortClothingByType(sortType);
                                    }
                                  });
                                }
                              ),
                            ],
                          ),
                          SizedBox(width: 5),
                          Column(
                            children: <Widget>[
                              RaisedButton( // "TUXEDO" button
                                elevation: 5,
                                color: _sortPressed[4] // Clicked = RED, not clicked = BLUE
                                  ? Colors.redAccent
                                  : Colors.lightBlueAccent,
                                splashColor: Colors.redAccent,
                                shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                child: Text("Tuxedo", style: TextStyle(fontSize: 18, color: Colors.white)),
                                onPressed:() {
                                  setState(() {
                                    if (_sortPressed[4] == true) // If already RED, return
                                      return; 
                                    else {
                                      sortType = "Tuxedo";
                                      for (int i=0; i<4; i++) // Set all other buttons to BLUE
                                        _sortPressed[i] = false;
                                      _sortPressed[4] = !_sortPressed[4];
                                      _sortPressed[5] = false;
                                      _sortClothingByType(sortType);
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                          SizedBox(width: 5),
                          Column(
                            children: <Widget>[
                              RaisedButton( // "WEDDING" button
                                elevation: 5,
                                color: _sortPressed[5] // Clicked = RED, not clicked = BLUE
                                  ? Colors.redAccent
                                  : Colors.lightBlueAccent,
                                splashColor: Colors.redAccent,
                                shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                child: Text("Wedding", style: TextStyle(fontSize: 18, color: Colors.white)),
                                onPressed:() {
                                  setState(() {
                                    if (_sortPressed[5] == true) // If already RED, return
                                      return;
                                    else {
                                      sortType = "Wedding";
                                      for (int i=0; i<5; i++) // Set all other buttons to BLUE
                                        _sortPressed[i] = false;
                                      _sortPressed[5] = !_sortPressed[5];
                                      _sortClothingByType(sortType);
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      )
                    ),
                  ),
                )
              )
            ),
            SizedBox(height: 10),
            Text(
              sortType + " (" + outfitData.length.toString() + ")",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black)
            ),
            SizedBox(height: 5),
            Flexible(
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: (screenWidth / screenHeight) / 0.78,
                children: List.generate(
                  outfitData.length, (index) {
                    return GestureDetector(
                      onTap:() {
                        Product _product = new Product(
                          id: outfitData[index]["id"],
                          name: outfitData[index]["name"],
                          size: outfitData[index]["size"],
                          quantity: outfitData[index]["quantity"],
                          price: outfitData[index]["price"],
                          date: outfitData[index]["date"],
                          type: outfitData[index]["type"],
                          address: outfitData[index]["address"]
                        );
                        _onTapProduct(_product, widget.user);
                      },
                      child: Card( // Display product details
                        elevation: 10,
                        child: Padding(
                          padding: EdgeInsets.only(left:8, right:8, top:8),
                          child: Column(
                            children: <Widget>[
                              Container( // Product image
                                height: screenWidth / 2.25, width: screenWidth,
                                decoration: BoxDecoration(color: Colors.grey),
                                child: CachedNetworkImage(
                                  fit: BoxFit.cover,
                                  imageUrl:"https://lilbearandlilpanda.com/styloderento/images/product_images/${outfitData[index]['id']}.jpg",
                                  placeholder: (context, url) => Center(
                                    child: SizedBox(
                                      width: 50, height: 50,
                                      child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation <Color>(Colors.lightBlueAccent))
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Icon(Icons.error),
                                ),
                              ),
                              SizedBox(height: 3),
                              Text( // Product name
                                outfitData[index]['name'],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: Colors.black),
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[ 
                                  Text(
                                    "RM" + outfitData[index]['price'] + " /day",
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: Colors.black),
                                  ),
                                  Row(
                                    children: <Widget>[
                                      GestureDetector(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border.all(color: Colors.blueAccent, width: 2)
                                          ),
                                          child: Icon(Icons.edit, size: 26, color: Colors.blueAccent)
                                        ),
                                        onTap: () => _onTapEditProduct(index), 
                                      ),
                                      SizedBox(width: 5),
                                      GestureDetector(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border.all(color: Colors.blueAccent, width: 2)
                                          ),
                                          child: Icon(Icons.delete_forever, size: 26, color: Colors.blueAccent),
                                        ),
                                        onTap: () => _onTapDeleteProduct(index), 
                                      )
                                    ],
                                  )
                                ]
                              ),
                              SizedBox(height: 10),
                            ],
                          ),
                        )
                      ),
                    );
                  }
                )
              ),
            ),
          ]
        ),
      ),
    );
  }

  void _loadProduct() async {
    String loadOutfitUrl = "https://lilbearandlilpanda.com/styloderento/php/load_product.php";
    await http.post(loadOutfitUrl, body: {
    }).then((res) {
      setState(() {
        var extractData = json.decode(res.body);
        outfitData = extractData["products"];
        print(outfitData);
      });
    }).catchError((onError) {
      print(onError);
    });
  }

  void _onTapProduct(Product _product, User _user) async { // If user added product to cart, this function will
    await Navigator.push(                                  // parse new cart quantity to main screen when back pressed
      context, MaterialPageRoute(builder: (BuildContext context) => ProductScreen(product: _product, user: _user))
    );
    setState(() {
      widget.user.quantity = _user.quantity;
    });
  }

  void _onTapAddProduct() async {
    int largestProductID = 0;                // To auto generate new product ID
    for (int i=0; i<outfitData.length; i++){
      if (int.parse(outfitData[i]['id']) > largestProductID){
        largestProductID = int.parse(outfitData[i]['id']);
      }   
    }
    String nextProductID = (largestProductID+1).toString();
    switch (nextProductID.length) {
      case 1:
        nextProductID = "000" + nextProductID;
        break;
      case 2:
        nextProductID = "00" + nextProductID;
        break;
      case 3:
        nextProductID = "0" + nextProductID;
        break;
      default:
        nextProductID = "" + nextProductID;
    }                                        // To auto generate new product ID

    await Navigator.push(                                  
      context, MaterialPageRoute(builder: (BuildContext context) => NewProductScreen(id: nextProductID, user: widget.user))
    );
  }

  void _onTapEditProduct(int index) async { 
    Product _product = new Product( // Parse the product to EditProductScreen to edit,
      id: outfitData[index]["id"],
      name: outfitData[index]["name"],
      size: outfitData[index]["size"],
      quantity: outfitData[index]["quantity"],
      price: outfitData[index]["price"],
      type: outfitData[index]["type"],
      address: outfitData[index]["selleraddress"],
      deliprice: outfitData[index]['deliprice'],
    );
    await Navigator.push(                                  
      context, MaterialPageRoute(builder: (BuildContext context) => EditProductScreen(product: _product, user: widget.user))
    );
    setState(() {                   // then when parsed back, refresh with edited data.
      outfitData[index]["id"] = _product.id;
      outfitData[index]["name"] = _product.name;
      outfitData[index]["size"] = _product.size;
      outfitData[index]["quantity"] = _product.quantity;
      outfitData[index]["price"] = _product.price;
      outfitData[index]["type"] = _product.type;
      outfitData[index]["address"] = _product.address;
      outfitData[index]['deliprice'] = _product.deliprice;
    });
  }

  void _onTapDeleteProduct(int index){
    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(10)),
            title: Text("Confirm Remove Item", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            content: Container(
              child: Text("Remove this item from the list?", style: TextStyle(fontSize: 16)),
            ),
            actions: <Widget>[
              RaisedButton(
                elevation: 5,
                child: Text("Confirm & Remove", style: TextStyle(fontSize: 16)),
                color: Colors.redAccent,
                shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(10)),
                onPressed:() {
                  String deleteAllUrl = "https://lilbearandlilpanda.com/styloderento/php/admin_manage_product.php";
                  http.post(deleteAllUrl, body:{
                    "operation": "delete",
                    "prodid": outfitData[index]['id']
                  }).then((res) {  
                    print(res.body);
                    if (res.body.contains("success")){
                      _loadProduct();                
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

  void _sortClothingByType(String type) { // Sort clothing by sort buttons
    try {
      ProgressDialog pr = new ProgressDialog(context,
          type: ProgressDialogType.Normal, isDismissible: true);
      pr.style(message: "Searching...");
      pr.show();
      String loadClothUrl =
          "https://lilbearandlilpanda.com/styloderento/php/load_product.php";
      http.post(loadClothUrl, body: {
        "type": type,
      }).then((res) {
        setState(() {
          var extractdata = json.decode(res.body);
          outfitData = extractdata["products"];
          FocusScope.of(context).requestFocus(new FocusNode());
          pr.hide();
        });
      }).catchError((onError) {
        print(onError);
        pr.hide();
      });
    } catch (error) {
      Toast.show("Error: $error", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  void _sortClothingByName(String search) { // Sort clothing by search
    try {
      ProgressDialog pr = new ProgressDialog(context,
          type: ProgressDialogType.Normal, isDismissible: true);
      pr.style(message: "Searching...");
      pr.show();
      String loadClothUrl =
          "https://lilbearandlilpanda.com/styloderento/php/load_product.php";
      http.post(loadClothUrl, body: {
            "name": search.toString(),
      }).timeout(const Duration(seconds: 5)).then((res) {
            if (res.body == "no data") {
              Toast.show("Product not found", context,
                  duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
              pr.hide();
              FocusScope.of(context).requestFocus(new FocusNode());
              return;
            }
            setState(() {
              sortType = search;
              var extractdata = json.decode(res.body);
              outfitData = extractdata["products"];
              FocusScope.of(context).requestFocus(new FocusNode());
              pr.hide();
            });
          })
          .catchError((onError) {
            print(onError);
            pr.hide();
          });
      pr.hide();
    } on TimeoutException catch (error) {
      Toast.show("Timeout Error: $error", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    } on SocketException catch (error) {
      Toast.show("Timeout Error: $error", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    } catch (error) {
      Toast.show("Error: $error", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }
}
