import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:toast/toast.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:flutter/services.dart';
import 'package:styloderento/loginscreen.dart';
import 'package:styloderento/cartscreen.dart';
import 'package:styloderento/object_user.dart';
import 'package:styloderento/object_product.dart';
import 'package:styloderento/profilescreen.dart';
import 'package:styloderento/credithistoryscreen.dart';
import 'package:styloderento/productscreen.dart';
import 'package:styloderento/paymenthistoryscreen.dart';
import 'package:styloderento/topupscreen.dart';
import 'package:styloderento/admin_manageproduct_screen.dart';
void main() => runApp(MainScreen());

class MainScreen extends StatefulWidget {
  final User user;
  const MainScreen({Key key, this.user}) : super(key: key);

  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  double screenHeight, screenWidth;
  List outfitData;
  String searchByName; // To store search item
  String sortType = "Recent"; 
  String drawerPicUrl; 
  bool _searchVisible = false; // Toggle search bar
  bool _sortVisible = false; // Toggle sort bar
  bool _verifyVisible = false; // Verify Account
  bool _walletVisible = false; // To show or hide Wallet options in drawer
  List<bool> _sortPressed = [true, false, false, false, false, false]; // Toggle sort type

  void initState() {
    super.initState();
    _loadProduct();
    _loadCartQuantity();
    if (widget.user.verify == "0") // If not verified, show notice at bottom.
      _verifyVisible = true;
  }

  Widget build(BuildContext context) {
    TextEditingController _searchController = new TextEditingController();
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    drawerPicUrl = "https://lilbearandlilpanda.com/styloderento/images/profile_images/${widget.user.email}.jpg?";

    return WillPopScope(
      onWillPop: _exitApp,
      child: Scaffold(
        drawer: _drawer(context), 
        appBar: AppBar(
          backgroundColor: Colors.lightBlueAccent,
          iconTheme: IconThemeData(color: Colors.white),
          flexibleSpace: Image(image: AssetImage('assets/images/menu.jpg'), fit: BoxFit.cover),
          title: GestureDetector( // Search bar
            child: Container(
              width: 185, height: 35,
              child: Row(
                children: <Widget>[
                  SizedBox(width: 6),
                  Icon(Icons.search, size: 25, color: Colors.blueAccent),
                  Text(" Stylo de Rento", style: TextStyle(fontSize: 18, color: Colors.blueAccent))
                ],
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
            ),
            onTap:() {
              setState(() {
                if (_searchVisible == true)         // hide search
                  _searchVisible = false;
                else if (_searchVisible == false) { // hide sort, show search
                  _sortVisible = false;            
                  _searchVisible = true;
                }
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
            Padding( // Cart Icon
              padding: EdgeInsets.only(right: 12.0),
              child: GestureDetector(
                child: Row(
                  children: <Widget>[
                    Icon(Icons.shopping_cart, size: 26, color: Colors.white),
                    Text(widget.user.quantity, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white))
                  ],
                ),
                onTap:() {
                  Navigator.push(
                    context, MaterialPageRoute(
                      builder: (BuildContext context) => CartScreen(user: widget.user)
                    )
                  );
                }
              )
            ),
          ],
        ),
        body: Stack(
          children: <Widget>[
            outfitData == null // null data handler
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
                                      child: Text(
                                        "Recent",
                                        style: TextStyle(fontSize: 18, color: Colors.white)
                                      ),
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
                                      child: Text(
                                        "Suit", 
                                        style: TextStyle(fontSize: 18, color: Colors.white)
                                      ),
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
                                      shape: ContinuousRectangleBorder(
                                        borderRadius: BorderRadius.circular(10)),
                                      child: Text(
                                        "Dress",
                                        style: TextStyle(fontSize: 18, color: Colors.white)
                                      ),
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
                                      child: Text(
                                        "Blazer",
                                        style: TextStyle(fontSize: 18, color: Colors.white)
                                      ),
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
                                      shape: ContinuousRectangleBorder(
                                        borderRadius: BorderRadius.circular(10)
                                      ),
                                      child: Text(
                                        "Tuxedo",
                                        style: TextStyle(fontSize: 18, color: Colors.white)
                                      ),
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
                                      shape: ContinuousRectangleBorder(
                                        borderRadius: BorderRadius.circular(10)
                                      ),
                                      child: Text(
                                        "Wedding",
                                        style: TextStyle(fontSize: 18, color: Colors.white)
                                      ),
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
                  SizedBox(height: 5),
                  Text(
                    sortType + " (" + outfitData.length.toString() + ")",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.blueAccent)
                  ),
                  SizedBox(height: 5),
                  Flexible(
                    child: GridView.count(
                      crossAxisCount: 2,
                      childAspectRatio: (screenWidth / screenHeight) / 0.8,
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
                                address: outfitData[index]["address"]);
                                _onTapProduct(_product, widget.user);
                            },
                            child: Card( // Display product details
                              elevation: 10,
                              child: Padding(
                                padding: EdgeInsets.only(left:8, right:8, top:8),
                                child: Column(
                                  children: <Widget>[
                                    Container( // Product image
                                      height: screenWidth / 2.2, width: screenWidth,
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
                                    SizedBox(height: 15),
                                    Align( // Product price
                                      alignment: Alignment.bottomLeft,
                                      child: Text(
                                        "RM" + outfitData[index]['price'] + " /day",
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: Colors.blueAccent),
                                      ),
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
                  Visibility( // Verify notice
                    visible: _verifyVisible,
                    child: Card(
                      color: Colors.white54,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text("Unverified account. Please check your email", style: TextStyle(fontSize: 18)),
                          GestureDetector(
                            child: Icon(Icons.close),
                            onTap:() {
                              setState(() {
                                _verifyVisible = false;
                              });
                            }
                          )
                        ],
                      )
                    ),
                  )
                ]
              ),
            ),
          ],
        ),
      )
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

  void _loadCartQuantity() async {
    String loadCartQuantityUrl = "https://lilbearandlilpanda.com/styloderento/php/load_cart_quantity.php";
    await http.post(loadCartQuantityUrl, body: {
      "email": widget.user.email
    }).then((res) {
      if (res.body == "nodata") {
        setState(() {
          widget.user.quantity = "0";
        });
      } else {
        setState(() {
          widget.user.quantity = res.body;
        });
      }
    }).catchError((error) {
      print(error);
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

  Widget _drawer(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Colors.lightBlueAccent,
              image: DecorationImage(image: AssetImage("assets/images/menu.jpg"), fit: BoxFit.none)
            ),
            accountName: GestureDetector( // Name
              child: Text(widget.user.name, style: TextStyle(fontSize: 18, color: Colors.white)),
              onTap:() => Navigator.push(
                context, MaterialPageRoute(builder: (BuildContext context) => ProfileScreen(user: widget.user))
              ),
            ),
            accountEmail: GestureDetector( // Email
              child: Text(widget.user.email, style: TextStyle(fontSize: 16, color: Colors.white)),
              onTap:() => Navigator.push(
                context, MaterialPageRoute(builder: (BuildContext context) => ProfileScreen(user: widget.user))
              ),
            ),
            currentAccountPicture: GestureDetector( // Profile Picture
              child: CircleAvatar(
                child: Text(widget.user.name.toString().substring(0, 1).toUpperCase(), style: TextStyle(fontSize: 25, color: Colors.white)),
                backgroundColor: Theme.of(context).platform == TargetPlatform.android
                  ? Colors.white
                  : Colors.white,
                backgroundImage: NetworkImage(drawerPicUrl),
              ),
              onTap:() => Navigator.push(
                context, MaterialPageRoute(builder: (BuildContext context) => ProfileScreen(user: widget.user))
              ),
            ),
            otherAccountsPictures: <Widget>[ // Back button
              GestureDetector(
                child: Icon(Icons.arrow_back, color: Colors.white),
                onTap: () => Navigator.of(context).pop()
              )
            ],
          ),
          SizedBox(height: 3),
          ListTile( // go to Profile Screen
            dense: true,
            leading: Icon(Icons.account_box, size: 28, color: Colors.blueAccent),
            title: Text("My Account", style: TextStyle(fontSize: 18)),
            trailing: Icon(Icons.keyboard_arrow_right, size: 28, color: Colors.blueAccent),
            onTap:() => Navigator.push(
              context, MaterialPageRoute(builder: (BuildContext context) => ProfileScreen(user: widget.user))
            ),
          ),
          SizedBox(height: 5),
          widget.user.email == "admin@styloderento.com"
          ? ListTile( // go to Admin Section (for admin account only)
            dense: true,
            leading: Icon(Icons.supervised_user_circle, size: 28, color: Colors.blueAccent),
            title: Text("Admin Menu", style: TextStyle(fontSize: 18)),
            trailing: Icon(Icons.keyboard_arrow_right, size: 28, color: Colors.blueAccent),
            onTap:() => Navigator.push(
              context, MaterialPageRoute(builder: (BuildContext context) => AdminProductScreen(user: widget.user))
            ),
          )
          : SizedBox(height: 0),
          SizedBox(height: 5),
          ListTile( // Wallet
            dense: true,
            leading: Icon(Icons.account_balance_wallet, size: 28, color: Colors.blueAccent),
            title: Text("Wallet", style: TextStyle(fontSize: 18)),
            subtitle: Text("Available Balance: RM " + widget.user.credit, style: TextStyle(color: Colors.blueAccent)),
            trailing: _walletVisible == true
              ? Icon(
                Icons.keyboard_arrow_down,
                size: 28, color: Colors.blueAccent,
              )
              : Icon(
                Icons.keyboard_arrow_right,
                size: 28,
                color: Colors.blueAccent,
              ),
            onTap: () {
              setState(() {
                if (_walletVisible == true) // Toggle Wallet options
                  _walletVisible = false;
                else if (_walletVisible == false) 
                  _walletVisible = true;
              });
            }
          ),
          Visibility( // Display Wallet options
            visible: _walletVisible,
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  RaisedButton( // go to Credit History Screen
                    elevation: 3,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.blueAccent)
                    ),
                    child: Text("Recent Transactions", style: TextStyle(fontSize: 16, color: Colors.blue)),
                    onPressed:() {
                      if (widget.user.email == "admin@styloderento.com"){
                        Toast.show("Admin Mode!!!", context,
                          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                        return;
                      } 
                      else {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (BuildContext context) => CreditHistoryScreen(user: widget.user)));
                      }
                    }
                  ),
                  RaisedButton( // Top Up button
                    elevation: 3,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.blueAccent)
                    ),
                    child: Text("Top Up", style: TextStyle(fontSize: 16, color: Colors.blue)),
                    onPressed: _topUpDialog
                  )
                ]
              )
            )
          ),
          SizedBox(height: 4),
          ListTile( // go to Cart Screen
            dense: true,
            leading: Icon(Icons.shopping_cart, size: 28, color: Colors.blueAccent),
            title: Text("Cart" + " (" + widget.user.quantity + ")", style: TextStyle(fontSize: 18)),
            trailing: Icon(Icons.keyboard_arrow_right, size: 28, color: Colors.blueAccent),
            onTap: () {
              if (widget.user.email == "admin@styloderento.com"){
                Toast.show("Admin Mode!!!", context,
                  duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                return;
              } 
              else {
                Navigator.of(context).pop();
                Navigator.push(
                  context, MaterialPageRoute(
                    builder: (BuildContext context) => CartScreen(user: widget.user)
                  )
                );
              }
            }
          ),
          SizedBox(height: 10),
          ListTile( // go to Payment History Screen
            dense: true,
            leading: Icon(Icons.history, size: 28, color: Colors.blueAccent),
            title: Text("Payment History", style: TextStyle(fontSize: 18)),
            trailing: Icon(Icons.keyboard_arrow_right, size: 28, color: Colors.blueAccent),
            onTap: () {
              if (widget.user.email == "admin@styloderento.com"){
                Toast.show("Admin Mode!!!", context,
                  duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                return;
              } 
              else {
                Navigator.of(context).pop();
                Navigator.push(
                  context, MaterialPageRoute(
                    builder: (BuildContext context) => PaymentHistoryScreen(user: widget.user)
                  )
                );
              } 
            }
          ),
          SizedBox(height: 10),
          ListTile( // go to Application Settings Screen
            enabled: false,
            dense: true,
            leading: Icon(Icons.settings, size: 28, color: Colors.blueAccent),
            title: Text("Settings", style: TextStyle(fontSize: 18)),
            trailing: Icon(Icons.keyboard_arrow_right, size: 28, color: Colors.blueAccent),
            onTap: () {
              if (widget.user.email == "admin@styloderento.com"){
                Toast.show("Admin Mode!!!", context,
                  duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                return;
              } 
              else {
                
              }
            }
          ),
          SizedBox(height: 10),
          ListTile( // go to Login Screen
            dense: true,
            leading: Icon(Icons.exit_to_app, size: 28, color: Colors.blueAccent),
            title: Text("Log out", style: TextStyle(fontSize: 18)),
            trailing: Icon(Icons.keyboard_arrow_right, size: 28, color: Colors.blueAccent),
            onTap: () => _logoutConfirmDialog()
          ),
          SizedBox(height: 62),
          Divider(color: Colors.blue),
          SizedBox(height: 2),
          ListTile( // Share the app to acknowledge others
            enabled: false,
            leading: Icon(Icons.share, size: 28, color: Colors.blueAccent),
            title: Text("Tell a Friend", style: TextStyle(fontSize: 18)),
            trailing: Icon(Icons.keyboard_arrow_right, size: 28, color: Colors.blueAccent),
            onTap:() {
              if (widget.user.email == "admin@styloderento.com"){
                Toast.show("Admin Mode!!!", context,
                  duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                return;
              }
              else {

              }
            }
          ),
          SizedBox(height: 4),
          ListTile(// Send a support ticket here
            enabled: false,
            leading: Icon(Icons.help_outline, size: 28, color: Colors.blueAccent),
            title: Text("Support", style: TextStyle(fontSize: 18)),
            trailing: Icon(Icons.keyboard_arrow_right, size: 28, color: Colors.blueAccent),
            onTap:() {
              if (widget.user.email == "admin@styloderento.com"){
                Toast.show("Admin Mode!!!", context,
                  duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                return;
              } 
              else {

              }
            }
          ),
        ],
      ),
    );
  }

  void _topUpDialog(){ // Ask for top up amount and top up confirmation
      if (widget.user.email == "admin@styloderento.com"){
        Toast.show("Admin Mode!!!", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        return;
      }

      TextEditingController topUpController = new TextEditingController();
      showDialog( // "Insert top up amount" dialog
        context: context, 
        builder: (BuildContext context) {
          return AlertDialog(
            shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.circular(10)
            ),
            title: Text(
              "Top Up Credit", 
              style: TextStyle (fontSize: 18, fontWeight: FontWeight.bold)
            ),
            content: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text("Insert Top Up Amount: ", style: TextStyle(fontSize: 16)),
                  SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("RM ", style: TextStyle(fontSize: 16)),
                      Container(
                        height: 30, width: 85,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue)
                        ),
                        child: TextField(
                          autofocus: true,
                          controller: topUpController,
                          style: TextStyle(fontSize: 18),
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done, 
                          decoration: InputDecoration(
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Text(
                    "* Minimum RM10.00 *", 
                    style: TextStyle(fontSize: 14, color: Colors.redAccent)
                  )
                ],
              ),
            ),
            actions: <Widget>[
              RaisedButton(
                elevation: 5,
                child: Text("Confirm", style: TextStyle(fontSize: 16, color: Colors.white)),
                color: Colors.lightBlueAccent,
                shape: ContinuousRectangleBorder(
                  borderRadius: BorderRadius.circular(10)
                ),
                onPressed:() {
                  double amount = double.parse(topUpController.text);
                  if (amount.toString().length < 1){ // if input length less than 1
                    Toast.show("Please Enter Correct Amount!", context,
                      duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
                    return;
                  } else if (amount < 10){ // if amount less than RM 10
                    Toast.show("Minimum Top Up Amount is 10 Ringgit!", context,
                      duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
                    return;
                  } else {
                    showDialog( // "Top Up Confirmation" Dialog
                      context: context,
                      builder: (context) => new AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20.0))
                        ),
                        title: Text("Confirm Top Up", style: TextStyle(fontSize: 18)),
                        content: Text(
                          "Buy store credit RM " + topUpController.text +" ?", 
                          style: TextStyle(fontSize: 16)
                        ),
                        actions: <Widget>[
                          RaisedButton( // go to Top Up Credit Screen
                            elevation: 5,
                            child: Text("Yes", style: TextStyle(color: Colors.white, fontSize: 16)),
                            color: Colors.lightBlueAccent,
                            shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                              _goTopUpCreditScreen(widget.user, topUpController.text); 
                            }
                          ),
                          RaisedButton( // dismiss "top up confirmation" dialog
                            elevation: 5,
                            child: Text("No", style: TextStyle(color: Colors.lightBlueAccent, fontSize: 16)),
                            color: Colors.white,
                            shape: ContinuousRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(color: Colors.lightBlueAccent)   
                            ),
                            onPressed: () => Navigator.of(context).pop()
                          )
                        ],
                      )
                    );
                  }   
                }
              ),
              RaisedButton( // dismiss "insert top up amount" dialog 
                  elevation: 5,
                  child: Text("Cancel",
                      style: TextStyle(color: Colors.lightBlueAccent, fontSize: 16)),
                  color: Colors.white,
                  shape: ContinuousRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Colors.lightBlueAccent)   
                  ),
                  onPressed: () => Navigator.of(context).pop())
            ],
          );
        });
  }

  void _goTopUpCreditScreen(User _user, String _amount) async {
      await Navigator.push(
        context, MaterialPageRoute(builder: (BuildContext context) => TopUpScreen(user: _user, val: _amount,))
      );           // When user back press after topping up credit, it will request the new credit amount
      var respond; // from database and replace the old wallet balance amount with new amount.
      List data;
      String getCreditAmountUrl = "https://lilbearandlilpanda.com/styloderento/php/load_credit.php";
      http.post(getCreditAmountUrl, body: {
        "email": widget.user.email,
      }).then((res) {
        if (res.body.contains("success")) {
          setState(() {
            respond = res.body;
            data = respond.split(",");
            widget.user.credit = data[1];
          });
        } 
        else {
          Toast.show("Failed to parse new amount", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        }
      }).catchError((onError) {
        print(onError);
      });
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

  void _logoutConfirmDialog() { // go to login screen
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            title: Text("Log Out Confirmation",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            content: Container(
              child: Text("Are you sure you want to log out?",
                  style: TextStyle(fontSize: 16)),
            ),
            actions: <Widget>[
              RaisedButton(
                  elevation: 5,
                  child: Text("Confirm", style: TextStyle(fontSize: 16)),
                  color: Colors.redAccent,
                  shape: ContinuousRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => LoginScreen(
                                  noDirectLogin: true,
                                )));
                    Toast.show("Logged out successfully.", context,
                        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                  }),
              RaisedButton(
                  elevation: 5,
                  child: Text("Cancel",
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                  color: Colors.lightBlueAccent,
                  shape: ContinuousRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  onPressed: () => Navigator.of(context).pop())
            ],
          );
        });
  }

  Future<bool> _exitApp() { // exit application
    return showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: Text("Exit Application"),
            content: Text("Do you want to exit the application?"),
            actions: <Widget>[
              MaterialButton(
                  child: Text("Exit"),
                  onPressed: () => SystemChannels.platform
                      .invokeMethod('SystemNavigator.pop')),
              MaterialButton(
                  child: Text("Cancel"),
                  onPressed: () => Navigator.of(context).pop(false)),
            ],
          ),
        ) ??
        false;
  }
}
