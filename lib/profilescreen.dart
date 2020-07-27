import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:toast/toast.dart';
import 'package:intl/intl.dart';
import 'package:recase/recase.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'dart:io';
import 'dart:convert';
import 'package:styloderento/object_user.dart';
import 'package:styloderento/loginscreen.dart';
import 'package:styloderento/paymenthistoryscreen.dart';
import 'package:styloderento/credithistoryscreen.dart';
import 'package:styloderento/mainscreen.dart';

class ProfileScreen extends StatefulWidget{
  final User user;
  const ProfileScreen({Key key, this.user}) : super(key: key);

  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  double screenHeight, screenWidth;
  final date = new DateFormat('dd-MM-yyyy hh:mm a');
  var parsedDate;
  String profilePicUrl;

  void initState(){
    super.initState();
  }

  Widget build(BuildContext context){
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;    
    profilePicUrl = "https://lilbearandlilpanda.com/styloderento/images/profile_images/${widget.user.email}.jpg";
    parsedDate = DateTime.parse(widget.user.datereg);

    return WillPopScope(
      onWillPop:() => Navigator.push(
        context, MaterialPageRoute(
          builder: (BuildContext context) => MainScreen(user: widget.user))),
      child: Scaffold(
      appBar: AppBar(
        title: Text("Your Profile"),
        flexibleSpace: Image( // Background picture for appbar
          image: AssetImage('assets/images/menu.jpg'),
          fit: BoxFit.cover
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/images/main.jpg'
            ),
            fit: BoxFit.cover,
          )
        ),
        child: Column(
          children: <Widget>[
            Card(
              elevation: 5,
              child: Padding(
                padding: EdgeInsets.all(5),
                child: Column(
                  children: <Widget>[
                    GestureDetector( // Profile picture, click to capture or choose a new picture
                      onTap: _takePicture,
                      child: Container(
                        height: screenHeight / 4,
                        width: screenWidth / 2.3,
                        child: CachedNetworkImage(
                          fit: BoxFit.cover,
                          imageUrl: profilePicUrl,
                          placeholder:(context, url) => Center(
                            child: Container(
                              height: 50, width: 50,
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget:(context, url, error) => Icon(
                            Icons.camera_alt, size: 18,
                          )
                        )
                      ),
                    ),
                  ],
                )
              )
            ),
            SizedBox(height: 0),
            Padding(
              padding: EdgeInsets.only(left: 5, right: 5),
               child: Card(
               elevation: 5,
               child: Padding(
                  padding: EdgeInsets.fromLTRB(10, 5, 10 ,5),
                  child: Container(
                    child: Table(
                      defaultColumnWidth: FlexColumnWidth(1.0),
                      columnWidths: {
                        0: FlexColumnWidth(3.4),
                        1: FlexColumnWidth(0.4),
                        2: FlexColumnWidth(6.2),
                      },
                      children: [
                        TableRow( // User name
                          children: [
                            Padding( 
                              padding: EdgeInsets.only(top: 0, bottom: 3),
                              child: Text("Name", style: TextStyle(fontSize: 18)),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 0, bottom: 3),
                              child: Text(":", style: TextStyle(fontSize: 18))
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 0, bottom: 3),
                              child: Text(widget.user.name , style: TextStyle(fontSize: 18), maxLines: 3),
                            )
                          ]
                        ),
                        TableRow( // User email
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 1, bottom: 3),
                              child: Text("Email", style: TextStyle(fontSize: 18)),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 1, bottom: 3),
                              child: Text(":", style: TextStyle(fontSize: 18))
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 1, bottom: 3),
                              child: Text(widget.user.email, style: TextStyle(fontSize: 18), maxLines: 3),
                            )
                          ]
                        ),
                        TableRow( // Phone number
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 1, bottom: 3),
                              child: Text("Phone No.", style: TextStyle(fontSize: 18)),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 1, bottom: 3),
                              child: Text(":", style: TextStyle(fontSize: 18))
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 1, bottom: 3),
                              child: Text(widget.user.phone, style: TextStyle(fontSize: 18), maxLines: 3),
                            )
                          ]
                        ),
                        TableRow( // Member since
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 1, bottom: 2),
                              child: Text("Member Since", style: TextStyle(fontSize: 18)),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 1, bottom: 2),
                              child: Text(":", style: TextStyle(fontSize: 18))
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 1, bottom: 2),
                              child: Text(date.format(parsedDate) , style: TextStyle(fontSize: 18), maxLines: 3),
                            )
                          ]
                        ),
                      ],
                    )
                  )
                ),
              ),
            ),
            Flexible(
              child: Padding(
                padding: EdgeInsets.only(left: 5, right: 5),
                child: Card(
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(10, 7, 10, 7),
                    children: <Widget>[
                      MaterialButton( // go to Wallet History Screen
                        onPressed:() => Navigator.push(
                          context, MaterialPageRoute(
                            builder: (BuildContext context) => CreditHistoryScreen(user: widget.user))),
                        child: Text("Wallet history", style: TextStyle(fontSize: 18)),
                      ),
                      Divider(color: Colors.blue),
                      MaterialButton( // go to Payment History Screen
                        onPressed:() => Navigator.push(
                          context, MaterialPageRoute(
                            builder: (BuildContext context) => PaymentHistoryScreen(user: widget.user))),
                        child: Text("Payment history", style: TextStyle(fontSize: 18)),
                      ),
                      Divider(color: Colors.blue),
                      MaterialButton( // change name dialog
                        onPressed: _changeName,
                        child: Text("Edit name", style: TextStyle(fontSize: 18)),
                      ),
                      Divider(color: Colors.blue),
                      MaterialButton( // change password dialog
                        onPressed: _changePassword,
                        child: Text("Change password", style: TextStyle(fontSize: 18)),
                      ),
                      Divider(color: Colors.blue),
                      MaterialButton( // change phone number dialog
                        onPressed: _changePhoneNumber,
                        child: Text("Change phone number", style: TextStyle(fontSize: 18)),
                      ),
                      Divider(color: Colors.blue),
                      MaterialButton( // go to log in screen
                        onPressed: _logout,
                        child: Text("Log out", style: TextStyle(fontSize: 18)),
                      ),
                    ],
                  )
                )
              )
            ),
            SizedBox(height: 4)
          ],
        )
      )
    )
    );
    
  }

  void _takePicture() async { // take or select a new profile picture
      if (widget.user.email == "unregistered") {
        Toast.show("Please register to use this function", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        return;
      }
      File _image = await ImagePicker.pickImage(
        source: ImageSource.camera, maxHeight: 400, maxWidth: 300);
      if (_image == null) {
        Toast.show("Please take an image to upload.", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        return;
      } 
      else {
        String uploadImageUrl = "https://lilbearandlilpanda.com/styloderento/php/upload_image.php";
        String base64Image = base64Encode(_image.readAsBytesSync());
        print(base64Image);
        http.post(uploadImageUrl, body: {
          "encoded_string": base64Image,
          "email": widget.user.email,
        }).then((res) {
          print(res.body);
          if (res.body == "success") {
            setState(() {
              DefaultCacheManager manager = new DefaultCacheManager();
              manager.emptyCache();
            });
            Toast.show("Upload Success", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
            Navigator.of(context).pop();
            Navigator.push(context, 
              MaterialPageRoute(
                builder: (BuildContext context) => ProfileScreen(user: widget.user)));
          } else {
            Toast.show("Upload Failed", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
          }
        }).catchError((err) {
          print(err);
        });
      }
  }

  void _changeName(){ // change name dialog
      if (widget.user.email == "unregistered") {
        Toast.show("Please register to use this function", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        return;
      }
      TextEditingController _nameController = TextEditingController();
      String changePhoneUrl = "https://lilbearandlilpanda.com/styloderento/php/update_profile.php";
      showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(10)),
            title: Text("Change your name", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            content: TextField(
              controller: _nameController,
              style: TextStyle(fontSize: 18),
              decoration: InputDecoration(
                labelText: "New Name Here",
                icon: Icon(Icons.people)
              ),
            ),
            actions: <Widget>[
              RaisedButton(
                elevation: 5,
                child: Text("Confirm & Change", style: TextStyle(fontSize: 18)),
                shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(10)),
                onPressed:() {
                  String newName = _nameController.text;
                  if (newName == "" || newName == null || newName.length < 3){ // valide name format
                    Toast.show("Please enter your new name correctly", context,
                      duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                    return;
                  }
                  ReCase rc = new ReCase(newName); // Recase the first character of each letter
                  http.post(changePhoneUrl, body:{
                    "email" : widget.user.email,
                    "name" : rc.titleCase.toString(),
                  }).then((res){
                    if (res.body == "success"){
                      setState(() {
                        widget.user.name = rc.titleCase;
                      });
                      Navigator.of(context).pop();
                      Toast.show("Name changed successfully.", context,
                        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                    }
                  }).catchError((error){
                    print(error);
                  });
                }
              ),
              RaisedButton(
                elevation: 5,
                child: Text("Cancel", style: TextStyle(color: Colors.white, fontSize: 18)),
                color: Colors.lightBlueAccent,
                shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(10)),
                onPressed:() => Navigator.of(context).pop() 
              )
            ],
          );
        }
      );
  }

  void _changePassword(){ // change password dialog
      if (widget.user.email == "unregistered") {
        Toast.show("Please register to use this function", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        return;
      }
      TextEditingController _oldPasswordController = TextEditingController();
      TextEditingController _newPasswordController = TextEditingController();
      String changePasswordUrl = "https://lilbearandlilpanda.com/styloderento/php/update_profile.php";
      showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(10)),
            title: Text("Change your current password", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: _oldPasswordController,
                  style: TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                    labelText: "Old Password",
                    icon: Icon(Icons.lock)
                  ),
                ),
                TextField(
                  controller: _newPasswordController,
                  style: TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                    labelText: "New Password",
                    icon: Icon(Icons.lock)
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              RaisedButton(
                elevation: 5,
                child: Text("Confirm & Change", style: TextStyle(fontSize: 18)),
                shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(10)),
                onPressed:() {
                  String oldPassword = _oldPasswordController.text;
                  String newPassword = _newPasswordController.text;
                  if (oldPassword == ""  || newPassword == ""){ // validate password format
                    Toast.show("Please enter your password", context,
                      duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                    return;
                  } else if (oldPassword != widget.user.password) {
                    Toast.show("Please enter your old password correctly", context,
                      duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                    return;
                  }
                  http.post(changePasswordUrl, body:{
                    "email" : widget.user.email,
                    "oldpassword" : oldPassword,
                    "newpassword" : newPassword
                  }).then((res){
                    if (res.body == "success"){
                      setState(() {
                        widget.user.password = newPassword;
                      });
                      Navigator.of(context).pop();
                      Toast.show("Password changed successfully.", context,
                        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                    }
                  }).catchError((error){
                    print(error);
                  });
                }
              ),
              RaisedButton(
                elevation: 5,
                child: Text("Cancel", style: TextStyle(color: Colors.white, fontSize: 18)),
                color: Colors.lightBlueAccent,
                shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(10)),
                onPressed:() => Navigator.of(context).pop() 
              )
            ],
          );
        }
      );
  }

  void _changePhoneNumber(){ // change phone dialog
      if (widget.user.email == "unregistered") {
        Toast.show("Please register to use this function", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        return;
      }
      TextEditingController _phoneController = TextEditingController();
      String changePhoneUrl = "https://lilbearandlilpanda.com/styloderento/php/update_profile.php";
      showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(10)),
            title: Text("Change phone number", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            content: TextField(
              controller: _phoneController,
              style: TextStyle(fontSize: 18),
              decoration: InputDecoration(
                labelText: "New Phone Number",
                icon: Icon(Icons.phone)
              ),
            ),
            actions: <Widget>[
              RaisedButton(
                elevation: 5,
                child: Text("Confirm & Change", style: TextStyle(fontSize: 18)),
                shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(10)),
                onPressed:() {
                  String phone = _phoneController.text;
                  if (phone == "" || phone == null || phone.length < 9){ // change phone format
                    Toast.show("Please enter the new phone number correctly", context,
                      duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                    return;
                  }
                  http.post(changePhoneUrl, body:{
                    "email" : widget.user.email,
                    "phone" : phone
                  }).then((res){
                    if (res.body == "success"){
                      setState(() {
                        widget.user.phone = phone;
                      });
                      Navigator.of(context).pop();
                      Toast.show("Phone number changed successfully.", context,
                        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                    }
                  }).catchError((error){
                    print(error);
                  });
                }
              ),
              RaisedButton(
                elevation: 5,
                child: Text("Cancel", style: TextStyle(color: Colors.white, fontSize: 18)),
                color: Colors.lightBlueAccent,
                shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(10)),
                onPressed:() => Navigator.of(context).pop() 
              )
            ],
          );
        }
      );
  }

  void _logout(){ // go to login screen
      showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(10)),
            title: Text("Log Out Confirmation", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            content: Container(
              child: Text("Are you sure you want to log out?", 
                style: TextStyle(fontSize: 16)
              ),
            ),
            actions: <Widget>[
              RaisedButton(
                elevation: 5,
                child: Text("Confirm", style: TextStyle(fontSize: 16)),
                color: Colors.redAccent,
                shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(10)),
                onPressed:() {
                  Navigator.of(context).pop();
                  Navigator.push(context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => LoginScreen(
                        noDirectLogin: true,
                      )
                    )
                  );
                  Toast.show("Logged out successfully.", context,
                    duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
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

}