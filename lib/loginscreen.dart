import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:styloderento/registerscreen.dart';
import 'package:styloderento/mainscreen.dart';
import 'package:styloderento/object_user.dart';
void main() => runApp(LoginScreen());
bool rememberMe = false;

class LoginScreen extends StatefulWidget{
  final bool noDirectLogin;
  const LoginScreen({Key key, this.noDirectLogin}) : super(key: key);

  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _pwdController = new TextEditingController();
  String loginUrl = "https://lilbearandlilpanda.com/styloderento/php/login_user.php";
  final emailNode = FocusNode();
  final passNode = FocusNode();

  void initState() {
      super.initState();
      loadPreference();
  }

  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _exitApp,
        child: Scaffold(
          resizeToAvoidBottomPadding: false,
          body: Stack(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  image:DecorationImage(
                    image:AssetImage("assets/images/login.png"),
                    fit: BoxFit.cover
                  )
                ),
              ),
              Container(
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 320),
                    Card(
                      elevation: 10,        
                      child: Container(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: <Widget>[
                            Align(
                              alignment: Alignment.center,
                              child: Text("User Login",style: TextStyle(fontSize:20, fontWeight:FontWeight.w700,)),
                            ),
                            SizedBox(height: 10),
                            TextField(
                              autofocus: false,
                              controller:_emailController,
                              keyboardType:TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(hintText:"Email", icon:Icon(Icons.email)),
                              onSubmitted:(_) => FocusScope.of(context).requestFocus(emailNode)
                            ),
                            TextField(
                              controller: _pwdController,
                              textInputAction: TextInputAction.done,
                              focusNode: emailNode,
                              decoration: InputDecoration(labelText:"Password", icon:Icon(Icons.lock)),
                              obscureText: true,
                            ),
                            SizedBox(height: 20,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children:<Widget>[
                                Checkbox( // Stay Logging in
                                  value: rememberMe,
                                  onChanged:(bool value) {
                                    setState(() {
                                      rememberMe = value;
                                      if (rememberMe == true) {
                                        Toast.show("Stay Logged In ENABLED.", context,
                                          duration: Toast.LENGTH_LONG, gravity:Toast.BOTTOM);
                                      } else {
                                        Toast.show("Stay Logged In DISABLED.", context,
                                          duration: Toast.LENGTH_LONG, gravity:Toast.BOTTOM);
                                      }
                                    });
                                  },
                                ),
                                Text("Stay Logged In",style: TextStyle(fontSize:17, fontWeight:FontWeight.bold)),
                                SizedBox(width: 72),
                                MaterialButton(
                                  height: 50,
                                  minWidth: 100, 
                                  elevation: 10,
                                  color: Colors.lightBlue, 
                                  shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(5.0)),
                                  child: Text("Login", style: TextStyle(fontSize:17, fontWeight:FontWeight.bold)),
                                  onPressed: _loginUser
                                ),
                              ]
                            ),
                          ]
                        )
                      ),
                    ),
                    Container(
                      child: Column(
                        children:<Widget>[
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text("Don't have an account ?  ", style: TextStyle(fontSize: 16.0)),
                              GestureDetector(
                                child: Text("Create an account", style:TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                onTap:() { Navigator.push(context, 
                                  MaterialPageRoute(builder: (BuildContext context) => RegisterScreen()));},
                              ),
                            ]
                          ),
                          SizedBox(height:5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children:<Widget>[
                              Text("Forgot your password ?  ", style:TextStyle(fontSize: 16.0,)),
                              GestureDetector(
                                child: Text("Reset password", style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                                onTap: _forgotPwd,
                              )
                            ]
                          )
                        ]
                      )
                    )
                  ]
                ),
              ),
            ]
          )
        )
    );
  }

  void _loginUser() async {
      try{
        ProgressDialog loginDialog = new ProgressDialog(context,
          type: ProgressDialogType.Normal, isDismissible: false);
        loginDialog.style(
          message: "Logging in, please wait...",
          backgroundColor: Colors.white,
          messageTextStyle: TextStyle(
            color: Colors.blueAccent, fontSize:20, fontWeight: FontWeight.w400),
        );
        loginDialog.show();

        String _email = _emailController.text;
        String _password = _pwdController.text;
        http.post(loginUrl, body: {
          "email": _email,
          "password": _password,
        }).then((res) {
          var string = res.body;
          List userdata = string.split("%");
          if (userdata[0] == "success") {
            User _user = new User(
              email: userdata[1],
              password: _password,
              name: userdata[2],
              phone: userdata[3],
              credit: userdata[4],
              verify: userdata[5],
              quantity: userdata[6],
              address: userdata[7],
              datereg: userdata[8]
            );
            savePreference(rememberMe);
            print(userdata);
            loginDialog.hide();
            Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext context) => MainScreen(user: _user)));
            Toast.show("Login success", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
          } else {
            loginDialog.hide();
            Toast.show("Login failed", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
          }
        }).catchError((err) {
          loginDialog.hide();
          print(err);
        });
      }
      on Exception catch (_){
        Toast.show("Unexpected error occured.", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      }
  }

  void _forgotPwd() {
      TextEditingController emailController = TextEditingController();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text("Reset Password"),
            content: Container(
              height: 100,
              child:Column(
                children:<Widget>[
                  Text("Please enter your recovery email:"),
                  SizedBox(height: 20),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      icon: Icon(Icons.email),
                    )
                  ),
                ]
              )
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("Enter"),
                onPressed: () {
                  //////////////////////////////////////////// EMAIL RECOVERY METHOD NEEDED
                  Navigator.of(context).pop();
                }
              ),
              FlatButton(
                child: Text("Cancel"),
                onPressed: () => Navigator.of(context).pop()
              )
            ]
          );  
        }
      );
  }

  void savePreference(bool save) async {
      String email = _emailController.text;
      String pwd = _pwdController.text;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if(save == true){//save preference
        await prefs.setString("email", "");
        await prefs.setString('email', email);
        await prefs.setString("pass", "");
        await prefs.setString('pass', pwd);
      } else {
        await prefs.setString("email", "");
        await prefs.setString("pass", "");
      }
  }

  void loadPreference() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String email = (prefs.getString("email"))??"";
      String pwd = (prefs.getString("pass"))??"";
      if(email.length > 1) {
        setState((){
          _emailController.text = email;
          _pwdController.text = pwd;
          rememberMe = true;
          if (widget.noDirectLogin == true)
            return;
          else
            _loginUser();
        });
      }
  }

  Future<bool> _exitApp() {
      return showDialog(
        context: context, 
        builder: (context) => new AlertDialog(
          title: Text("Exit Application"),
          content: Text("Do you want to exit the application?"),
          actions: <Widget>[
            MaterialButton(
              child: Text("Exit"),
              onPressed:() => SystemChannels.platform.invokeMethod('SystemNavigator.pop')
            ),
            MaterialButton(
              child: Text("Cancel"),
              onPressed:() => Navigator.of(context).pop(false)
            ),
          ],
        ),
      ) ?? false;
  }
}