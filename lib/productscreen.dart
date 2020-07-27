import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:toast/toast.dart';
import 'package:recase/recase.dart';
import 'package:progress_dialog/progress_dialog.dart';
import "package:http/http.dart" as http;
import 'package:styloderento/object_product.dart';
import 'package:styloderento/object_user.dart';
void main() => runApp(ProductScreen());

class ProductScreen extends StatefulWidget{
  final Product product;
  final User user;
  
  const ProductScreen({Key key, this.user,this.product, }) : super(key: key);
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  double screenWidth, screenHeight;
  String cartquantity = "0";

  Widget build(BuildContext context){
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    List type = widget.product.type.split("/"); // To remove slash and replace with comma
    String clothType = type.toString().replaceFirst("[", "").replaceFirst("]", ""); // To remove [ ]
    ReCase uppercaseClothType = ReCase(clothType); // Recasing the types
    
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
          child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Container(
                    child: CachedNetworkImage( // Display large product image
                      imageUrl: "https://lilbearandlilpanda.com/styloderento/images/product_images/${widget.product.id}.jpg",
                      placeholder:(context, url) => CircularProgressIndicator()
                    ),
                  ),
                  SizedBox(height:15),
                  Padding( // Product name
                    padding: EdgeInsets.only(left:10, right:10),
                    child: Text(widget.product.name, textAlign: TextAlign.center, style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500))
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: EdgeInsets.only(left:35, right:35),
                    child: Table(
                      border: TableBorder.lerp(
                        TableBorder(top: BorderSide(width: 3, color: Colors.lightBlueAccent)),
                        TableBorder(bottom: BorderSide(width: 3, color: Colors.lightBlueAccent)),
                        0.5
                      ),
                      defaultColumnWidth: FlexColumnWidth(1.0),
                      columnWidths: {
                        0: FlexColumnWidth(5.5),
                        1: FlexColumnWidth(4.5),
                      },
                      children: [
                        TableRow( // Product rental price / day
                          children: [
                            TableCell(
                              child: Text("\nPrice /day (RM):\n", style: TextStyle(fontSize: 20)),
                            ),
                            TableCell(
                              child: Text("\n"+ widget.product.price, style: TextStyle(fontSize: 20)),
                            )
                          ]
                        ),
                        TableRow( // Product size
                          children: [
                            TableCell(
                              child: Text("Size: \n", style: TextStyle(fontSize: 20)),
                            ),
                            TableCell(
                              child: Text(widget.product.size, style: TextStyle(fontSize: 20)),
                            )
                          ]
                        ),
                        TableRow( // Product available quantity
                          children: [
                            TableCell(
                              child: Text("Quantity left: \n", style: TextStyle(fontSize: 20)),
                            ),
                            TableCell(
                              child: Text(widget.product.quantity + " piece(s)", style: TextStyle(fontSize: 20)),
                            )
                          ]
                        ),
                        TableRow( // Product type
                          children: [
                            TableCell(
                              child: Text("Type: \n", style: TextStyle(fontSize: 20)),
                            ),
                            TableCell(
                              child: Text(uppercaseClothType.titleCase.toString()+"\n", style: TextStyle(fontSize: 20)),
                            )
                          ]
                        ),
                      ],
                    )
                  ),
                  SizedBox(height: 10),
                  Center( 
                    child: widget.user.email == "admin@styloderento.com"
                    ? SizedBox(height: 0)
                    : RaisedButton( // Add to cart button
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                        side: BorderSide(color: Colors.lightBlueAccent)
                      ),
                      color: Colors.lightBlueAccent,
                      child: Text("Add to Cart", style: TextStyle(fontSize: 20)),
                      onPressed:() => _addtoCart()
                    )
                  ),
                  SizedBox(height: 10)
                ],
              ),
            ],
          )
        )
      )
    );
  }

  void _addtoCart(){ // Add item to cart
      if (widget.user.email == "unregistered@styloderento.com"){
        Toast.show("Please register first", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        return;
      }
      if (widget.user.email == "admin@styloderento.com") {
        Toast.show("Admin mode", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        return;
      }
      int quantityChoosen = 1; // Preset 'quantity' to 1
      int dayChoosen = 1; // Preset 'day to rent' to 1
      showDialog(
        context: context,
        builder: (context){
          return StatefulBuilder(builder: (context, newSetState){
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
              title: new Text("Add this item to cart?", textAlign: TextAlign.center, style: TextStyle(color: Colors.black, fontSize: 20)),
              content: Column( // Choose quantity to rent
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(width: 20),
                  Text("Select Quantity:", style: TextStyle(color: Colors.black, fontSize: 20)),
                  SizedBox(width: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          FlatButton(
                            child: Icon(Icons.remove, color: Colors.black, size: 20),
                            onPressed:() {
                              newSetState(() {
                                if (quantityChoosen > 1)
                                  quantityChoosen--;
                              });
                            },
                          ),
                          Text(quantityChoosen.toString(), style: TextStyle(color: Colors.black, fontSize: 20)),
                          FlatButton(
                            child: Icon(Icons.add, size: 20),
                            onPressed:() {
                              newSetState(() {
                                if (quantityChoosen < (int.parse(widget.product.quantity)))
                                  quantityChoosen++;
                                else {
                                  Toast.show("Quantity not available", context,
                                    duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                                }
                              });
                            }
                          ),
                        ],
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(left:17, right:17),
                    child: Divider(color: Colors.black),
                  ),
                  Text("Rent How Many Days?", style: TextStyle(color: Colors.black, fontSize: 20)),
                  Row( // Choose how many days user want to rent
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      FlatButton(
                        child: Icon(Icons.remove, color: Colors.black, size: 20),
                        onPressed:() {
                          newSetState(() {
                            if (dayChoosen > 1)
                              dayChoosen--;
                          });
                        },
                      ),
                      Text(dayChoosen.toString(), style: TextStyle(color: Colors.black, fontSize: 20)),
                      FlatButton(
                        child: Icon(Icons.add, size: 20),
                        onPressed:() {
                          newSetState(() {
                            dayChoosen++;
                          });
                        }
                      ),
                    ]
                  )
                ],
              ),
              actions: <Widget>[ // Press confirm and will add to cart database
                MaterialButton(
                  child: Text("Confirm", style: TextStyle(color: Colors.black, fontSize: 20)),
                  onPressed:() {
                    String insertCartUrl = "https://lilbearandlilpanda.com/styloderento/php/insert_cart.php";
                    ProgressDialog pr = new ProgressDialog(context,
                      type: ProgressDialogType.Normal, isDismissible: true);
                    pr.style(message: "Adding to cart...");
                    pr.show();
                    http.post(insertCartUrl, body: {
                      "email": widget.user.email,
                      "proid": widget.product.id,
                      "quantity": quantityChoosen.toString(),
                      "day2rent": dayChoosen.toString()
                    }).then((res) {
                      print(res.body);
                      if (res.body.contains("success")) {
                        Navigator.of(context).pop();
                        List respond = res.body.split(",");
                          setState(() {
                            cartquantity = respond[1];
                            widget.user.quantity = cartquantity;
                          });
                          Toast.show("Success add to cart", context,
                            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                      } else {
                        Toast.show("Failed add to cart", context,
                          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                      }
                      pr.hide();
                    }).catchError((err) {
                      print(err);
                      pr.hide();
                    });
                  },
                ),
                MaterialButton(
                  onPressed:() => Navigator.of(context).pop(false),
                  child: Text("Cancel", style: TextStyle(color: Colors.black, fontSize: 20))
                )
              ]
            );
          });
        }
      );
  }
  
  Future<bool> _onBackPressed() async { // Return the new cart quantity to mainscreen
      Navigator.pop(context, widget.user.quantity);
      return null;
  }
}