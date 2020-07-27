import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
import 'package:styloderento/loginscreen.dart';

void main() => runApp(RegisterScreen());

class RegisterScreen extends StatefulWidget{
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _checked = false;
  String registrationUrl = "https://lilbearandlilpanda.com/styloderento/php/register_user.php";
  TextEditingController _nameController = new TextEditingController();
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _phoneController = new TextEditingController();
  TextEditingController _passController = new TextEditingController();
  final nameNode = new FocusNode();
  final emailNode = new FocusNode();
  final phoneNode = new FocusNode();

  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(       
        resizeToAvoidBottomPadding: false,
        body: Stack(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                image:DecorationImage(
                  image:AssetImage("assets/images/register.png"), 
                  fit: BoxFit.cover
                )
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                child:Column(
                  children: <Widget>[
                    SizedBox(height: 200),
                    Card(
                      elevation:10,
                      child:Container(
                        padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                        child: Column(
                          children: <Widget>[
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                "Member Registration", 
                                style: TextStyle(
                                  color: Colors.black, 
                                  fontSize: 26, 
                                  fontWeight: FontWeight.bold
                                ),
                              )
                            ),
                            SizedBox(height: 20),
                            TextFormField(
                              controller: _nameController,
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted:(_) => FocusScope.of(context).requestFocus(nameNode),
                              decoration: InputDecoration(
                                labelText: 'Full Name', 
                                icon: Icon(Icons.person)
                              )
                            ),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              focusNode: nameNode,
                              onFieldSubmitted:(_) => FocusScope.of(context).requestFocus(emailNode),
                              decoration: InputDecoration(
                                labelText: 'Email Address (eg: bob@example.com)', 
                                icon: Icon(Icons.email)
                              ),
                            ),
                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.next,
                              focusNode: emailNode,
                              onFieldSubmitted:(_) => FocusScope.of(context).requestFocus(phoneNode),
                              decoration: InputDecoration(
                                labelText: 'Phone number (eg: 0123456789)', 
                                icon: Icon(Icons.phone),
                              )
                            ),
                            TextFormField(
                              controller: _passController,
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.done,
                              obscureText: true,
                              focusNode: phoneNode,
                              decoration: InputDecoration(
                                labelText: 'Password', 
                                icon: Icon(Icons.lock), 
                              ),
                            ),
                            SizedBox(height: 10),
                            Padding(
                              padding: EdgeInsets.only(left:40),
                              child: Text(
                                "Your password needs to:\n"
                                "   - be at least 6 characters long.\n" 
                                "   - include both lower and upper case characters.\n" 
                                "   - include at least one number.", 
                                style: TextStyle(color: Colors.black)
                              ),
                            ),
                            Row(
                              children:<Widget>[
                                Checkbox(
                                  value: _checked,
                                  onChanged: (bool value) {
                                  setState(() {
                                    _checked = value;
                                  });
                                  },
                                ),
                                GestureDetector(
                                  onTap: _showEULA,
                                  child: Text(
                                    'I agree to the Terms and Conditions.',
                                    style: TextStyle(
                                      fontSize: 16, 
                                      fontWeight: FontWeight.bold
                                    )
                                  ),
                                ),
                              ]
                            ),
                            MaterialButton(
                              minWidth: 105,
                              height: 45,
                              color: Colors.lightBlueAccent[700],
                              textColor: Colors.white,
                              elevation: 10,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                              child: Text(
                                'REGISTER', 
                                style: TextStyle(
                                  fontSize:16, 
                                  fontWeight: FontWeight.bold
                                )
                              ),
                              onPressed: (){
                                if (!_checked)
                                  Toast.show("Please Accept Term", context,
                                    duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
                                else
                                  _validation();  
                              },
                            ),
                          ]
                        )
                      )
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text("Already register? ", style: TextStyle(fontSize: 16.0)),
                        GestureDetector(
                          child: Text("Login here", style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                          onTap: () => Navigator.push(context,
                                          MaterialPageRoute(builder: (BuildContext context) => LoginScreen(noDirectLogin: true)))
                        )
                      ]
                    )
                  ]
                )
              )
            )
          ]
        )
      )
    );
  }
  
    void _validation(){
        String name = _nameController.text;
        String email = _emailController.text;
        String phone = _phoneController.text;
        String password = _passController.text;

        if((_validateName(name) == false) & (_validateEmail(email) == false) & 
           (_validatePhone(phone) == false) & (_validatePwd(password) == false))
          _onRegister();    
    }

    bool _validateName(String name){ //Check name format
        bool wrongInput = false;
        if(name.isEmpty){
          wrongInput = true;
          Toast.show("Name must not be empty.", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        } else if (name.length < 3){
          Toast.show("Name must be longer than 2 characters.", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        }
      return wrongInput;
    }

    bool _validateEmail(String email){ // Validate email format
        bool wrongInput = false;
        if(!email.contains('@') || !email.contains('.')){
          wrongInput = true;
          Toast.show("Invalid Email!", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        }
      return wrongInput;
    }

    bool _validatePhone(String phone){ // Validate phone number format
        List<String> alphabet = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"];
        List<String> symbol = ["`","~","!","#","\$","%","^","&","*","(",")","-","_","=","+","[","]","{","}","\\","|",";",":","'","\"",",",".","/","<",">","?","@"];
        bool wrongInput = false;
        if(phone.isEmpty){
          wrongInput = true;
          Toast.show("Phone number must not be empty.", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        } 
        else {
          for(int count = 0; count < 26; count++){
            if (phone.contains(alphabet[count]) || phone.contains(alphabet[count].toUpperCase()))
              wrongInput = true;
          }
          for(int count = 0; count < 32; count++){
            if (phone.contains(symbol[count]))
              wrongInput = true;
          }
        }
        if (wrongInput == true)
          Toast.show("Phone number must not contain any words or symbols!", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      return wrongInput;
    }

    bool _validatePwd(String password){ // Validate password format
        List<String> number = ["0","1","2","3","4","5","6","7","8","9"];
        List<String> alphabet = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"];
        int upperCount = 0; int numCount = 0;
        bool wrongInput = false;

        if(password.isEmpty){ // Check if password is empty
          wrongInput = true;
          Toast.show("Password must not be empty!", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        }
        else if (password.length < 6){ // Check if password length less than 6
          wrongInput = true;
          Toast.show("Password length must not less than 6.", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        }
        else{
          for(int count = 0; count < 10; count++){ // Check if password contain number
            if(password.contains(number[count])){
              numCount++;
            }
          }
          for(int count = 0; count < 26; count++){ // Check if password contain uppercase character
            if(password.contains(alphabet[count])){
              upperCount++;
            }
          }
          if(numCount == 0 || upperCount == 0){
            wrongInput = true;
            Toast.show("Password must consists of atleast 1 uppercase character, lowercase characters and numbers.", context,
                duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
          } 
        }
      return wrongInput;
    }

    void _showEULA(){ // Show End-User License Agreement
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: new Text("End-user License Agreement"),
              content: new Container(
                height: 500,
                child: Column(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: new SingleChildScrollView(
                        child: RichText(
                          softWrap: true,
                          textAlign: TextAlign.justify,
                          text: TextSpan(
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12.0,
                              ),
                            text: "This End-User License Agreement is a legal agreement " + 
                                  "between you and Lilbearandlilpanda. This EULA agreement " +
                                  "governs your acquisition and use of our Stylo de Rento " + 
                                  "software (Software) directly from Lilbearandlilpanda or "+ 
                                  "indirectly through a Lilbearandlilpanda authorized reseller "+
                                  "or distributor (a Reseller).Please read this EULA agreement "+
                                  "carefully before completing the installation process and using "+
                                  "the Stylo de Rento software. It provides a license to use the "+
                                  "Stylo de Rento software and contains warranty information and "+
                                  "liability disclaimers. If you register for a free trial of the "+
                                  "Stylo de Rento software, this EULA agreement will also govern "+
                                  "that trial. By clicking accept or installing and/or using the "+
                                  "Stylo de Rento software, you are confirming your acceptance of "+
                                  "the Software and agreeing to become bound by the terms of this "+
                                  "EULA agreement. If you are entering into this EULA agreement "+
                                  "on behalf of a company or other legal entity, you represent that "+
                                  "you have the authority to bind such entity and its affiliates to "+
                                  "these terms and conditions. If you do not have such authority or "+
                                  "if you do not agree with the terms and conditions of this "+
                                  "EULA agreement, do not install or use the Software, and you must "+
                                  "not accept this EULA agreement.This EULA agreement shall apply "+
                                  "only to the Software supplied by Lilbearandlilpanda herewith "+
                                  "regardless of whether other software is referred to or described "+
                                  "herein. The terms also apply to any Lilbearandlilpanda updates, "+
                                  "supplements, Internet-based services, and support services for "+
                                  "the Software, unless other terms accompany those items on delivery. "+
                                  "If so, those terms apply. This EULA was created by EULA Template "+
                                  "for Stylo de Rento. Lilbearandlilpanda shall at all times retain "+
                                  "ownership of the Software as originally downloaded by you and all "+
                                  "subsequent downloads of the Software by you. The Software (and "+
                                  "the copyright, and other intellectual property rights of "+
                                  "whatever nature in the Software, including any modifications "+
                                  "made thereto) are and shall remain the property of Lilbearandlilpanda. "+
                                  "Lilbearandlilpanda reserves the right to grant licences to use the "+
                                  "software to third parties"
                          )
                        ),
                      ),
                    )
                  ],
                ),
              ),
              actions: <Widget>[
                new FlatButton(
                  child: new Text("Close"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          },
        );
    }

    void _onRegister(){ // Account registration confirmation dialog
        String name = _nameController.text;
        String email = _emailController.text;
        String phone = _phoneController.text;
        String password = _passController.text;

        showDialog(
          context: context,
          builder: (BuildContext context){
            return AlertDialog(
              title:new Text("Please Confirm"),
                content:new Container(
                height: 50,
                  child: Column(
                    children: <Widget>[
                      Text(
                        "Are you sure you want to create an account?",
                      ),
                    ],
                  ),
                ),
                actions: <Widget>[
                  FlatButton(
                    child:new Text ("Yes"),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _createAcc(name, email, phone, password); 
                    }
                  ),
                  FlatButton(
                    child:new Text("No"),
                    onPressed: (){
                      Navigator.of(context).pop();
                    }
                  )
                ]
            );
          }
        );
    }

    void _createAcc(String name, String email, String phone, String password){ // Create Account
        http.post(registrationUrl, body: {
          "name": name,
          "email": email,
          "phone": phone,
          "password": password,
        }).then((res) {
          if (res.body==("success")) {
              Toast.show("Registration Done", context,
                  duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
              Navigator.of(context).pop(
                MaterialPageRoute(
                  builder: (BuildContext context) => LoginScreen()));
          } else {
              Toast.show("Registration Failed", context,
                  duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
          }
        }).catchError((err) {
          print(err);
        });
    }
}