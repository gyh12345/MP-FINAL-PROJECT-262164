import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:styloderento/admin_manageproduct_screen.dart';
import 'package:toast/toast.dart';
import 'package:styloderento/object_user.dart';

class NewProductScreen extends StatefulWidget{
  final String id;
  final User user;
  const NewProductScreen({Key key, this.id, this.user}) : super(key: key);
  _NewProductScreenState createState() => _NewProductScreenState();
}

class _NewProductScreenState extends State<NewProductScreen> {
  double screenHeight, screenWidth;
  File productPic;
  String defaultPic = 'assets/images/phonecam.png';
  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController deliveryController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  String size;
  List sizeList = ["XS", "S", "M", "L", "XL", "Free Size"];
  List<bool> typeCheckbox = [false, false, false, false, false]; // Toggle checkbox
  TextEditingController addressController = TextEditingController();

  void initState() {
    super.initState();
  }

  Widget build(BuildContext context){
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    

    return WillPopScope(
      onWillPop: null,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Add New Product", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          flexibleSpace: Image(image: AssetImage('assets/images/menu.jpg'), fit: BoxFit.cover),      
        ),
        body: Container(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
              padding: EdgeInsets.only(left: 25, right: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: GestureDetector(
                      onTap:() => _choose(),//_updatePicture,
                      child: Card(
                        elevation: 5,
                        child: Padding(
                          padding: EdgeInsets.all(5),
                          child: Container(
                            height: screenHeight / 4.7, //4.7
                            width: screenWidth / 2.7, // 2.7
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              image: DecorationImage(
                                colorFilter: ColorFilter.mode(
                                  Colors.black.withOpacity(0.6),
                                  BlendMode.dstATop
                                ),
                                image: productPic == null
                                ? AssetImage(defaultPic)
                                : FileImage(productPic)
                              )
                            ),
                          )
                        ),
                      )
                    )
                  ),
                  SizedBox(height: 10),
                  Text("Product ID: " + widget.id, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text("Product Name: ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  TextFormField(
                    controller: nameController,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    maxLines: 3,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black)
                      )
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("Price / day (RM): ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Container(
                        width: 110, height: 30,
                        child: TextField(
                          controller: priceController,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black)
                            )
                          ),
                        )
                      ) 
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("Delivery Fee (RM): ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Container(
                        width: 110,
                        height: 30,
                        child: TextField(
                          controller: deliveryController,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black)
                            )
                          ),
                        )
                      ) 
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("Quantity Available: ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Container(
                        width: 110,
                        height: 30,
                        child: TextField(
                          controller: quantityController,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black)
                            )
                          ),
                        )
                      ) 
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("Size: ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Container(
                        width: 110,
                        height: 30,
                        padding: EdgeInsets.only(left:10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.all(Radius.circular(5.0))
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton(
                            value: size,
                            onChanged: (value) {
                              setState(() {
                                size = value;
                                print(value);
                              });
                            },
                            items: sizeList.map((value) {
                              return DropdownMenuItem(
                                child: Text(value),
                                value: value,
                              );
                            }).toList(),
                          )
                        )
                      ) 
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      Text("Type: ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.only(left:0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.all(Radius.circular(5.0))
                    ),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Checkbox( // Suit
                              value: typeCheckbox[0],
                              onChanged: (bool value){
                                setState(() {
                                  typeCheckbox[0] = !typeCheckbox[0];
                                });
                              },
                            ),
                            Text("Suit", style: TextStyle(fontSize: 16)),
                            SizedBox(width: 35),
                            Checkbox( // Dress
                              value: typeCheckbox[1],
                              onChanged: (bool value){
                                setState(() {
                                  typeCheckbox[1] = !typeCheckbox[1];
                                });
                              },
                            ),
                            Text("Dress", style: TextStyle(fontSize: 16)),
                            SizedBox(width: 33),
                            Checkbox( // Blazer
                              value: typeCheckbox[2],
                              onChanged: (bool value){
                                setState(() {
                                  typeCheckbox[2] = !typeCheckbox[2];
                                });
                              },
                            ),
                            Text("Blazer", style: TextStyle(fontSize: 16)),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            //SizedBox(width: 20),
                            Checkbox( // Tuxedo
                              value: typeCheckbox[3],
                              onChanged: (bool value){
                                setState(() {
                                  typeCheckbox[3] = !typeCheckbox[3];
                                });
                              },
                            ),
                            Text("Tuxedo", style: TextStyle(fontSize: 16)),
                            SizedBox(width: 10),
                            Checkbox( // Wedding
                              value: typeCheckbox[4],
                              onChanged: (bool value){
                                setState(() {
                                  typeCheckbox[4] = !typeCheckbox[4];
                                });
                              },
                            ),
                            Text("Wedding", style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ]
                    )
                  ),
                  SizedBox(height: 10),
                  Text("Seller Address: ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  TextFormField(
                    controller: addressController,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    maxLines: 3,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black)
                      )
                    ),
                  ),
                  SizedBox(height: 5),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          RaisedButton(
                            elevation: 5,
                            child: Text("Add Product", style: TextStyle(fontSize: 16)),
                            color: Colors.redAccent,
                            shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            onPressed: _confirmAddProduct
                          ),
                          RaisedButton(
                            elevation: 5,
                            child: Text("Cancel", style: TextStyle(color: Colors.white, fontSize: 16)),
                            color: Colors.lightBlueAccent,
                            shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            onPressed:() => Navigator.of(context).pop(),
                          )
                        ],
                      )
                    )
                  ),
                  SizedBox(height: 10)
                ],
              ),
            ),
          ),
        )
      )
    );
  }

  void _choose() async {
    productPic = await ImagePicker.pickImage(
        source: ImageSource.camera, maxHeight: 800, maxWidth: 800);
    //_cropImage();
    setState(() {});
  }

  Future<Null> _cropImage() async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: productPic.path,
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Cropper',
        ));
    if (croppedFile != null) {
      productPic = croppedFile;
      setState(() {});
    }
  }

  void _confirmAddProduct() {
    List lowercaseTypeList = ["suit", "dress", "blazer", "tuxedo", "wedding"];
    List selectedTypeList = List();
    for (int i = 0; i < typeCheckbox.length; i++){
      if (typeCheckbox[i] == true){
        selectedTypeList.add(lowercaseTypeList[i]);
      }
    }
    String selectedType = selectedTypeList.toString().replaceAll(", ", "/").replaceFirst("[", "").replaceFirst("]", "");

    if (productPic == null) {
      Toast.show("Please take product photo", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      return;
    }
    if (nameController.text.length < 4) {
      Toast.show("Please enter product name", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      return;
    }
    if (priceController.text.length < 1) {
      Toast.show("Please enter product quantity", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      return;
    }
    if (deliveryController.text.length < 1) {
      Toast.show("Please enter product delivery fee", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      return;
    }
    if (size.length < 1) {
      Toast.show("Please choose product size", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      return;
    }
    if (selectedType == null) {
      Toast.show("Please choose product type", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      return;
    }
    if (addressController.text.length < 1) {
      Toast.show("Please enter seller address", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      return;
    }    

    showDialog(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: new Text(
            "Insert New Product Id " + widget.id,
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
          content: new Text("Are you sure?", style: TextStyle(color: Colors.black, fontSize: 16)),
          actions: <Widget>[
            RaisedButton(
              elevation: 5,
              child: Text("Yes", style: TextStyle(color: Colors.white, fontSize: 16)),
              color: Colors.lightBlueAccent,
              shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(10)),
              onPressed:() {
                String base64Image = base64Encode(productPic.readAsBytesSync());
                String updateProductUrl = "https://lilbearandlilpanda.com/styloderento/php/admin_manage_product.php";

                http.post(updateProductUrl, body:{
                  "operation": "add",
                  "prodid": widget.id,
                  "encoded_string": base64Image,
                  "name": nameController.text,
                  "price": priceController.text,
                  "delivery": deliveryController.text,
                  "quantity": quantityController.text,
                  "size": size,
                  "type": selectedType,
                  "selleraddress": addressController.text
                }).then((res) {  
                  print(res.body);
                  if (res.body.contains("success")){                
                    Toast.show("Item Added.", context,
                      duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                      Navigator.of(context).pop();
                      Navigator.push(    
                        context, MaterialPageRoute(builder: (BuildContext context) => AdminProductScreen(user: widget.user)));
                  }
                  if (res.body.contains("failed")){
                    Toast.show("Failed to add the item.", context,
                      duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                  }
                }).catchError((error){
                  print(error);
                });            
              } 
            ),
            RaisedButton(
              elevation: 5,
              child: Text("No", style: TextStyle(color: Colors.white, fontSize: 16)),
              color: Colors.lightBlueAccent,
              shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(10)),
              onPressed:() => Navigator.of(context).pop() 
            ),
          ],
        );
      }
    );                        
  }
}