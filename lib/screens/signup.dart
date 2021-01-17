import 'package:contacts/screens/home.dart';
import 'package:contacts/screens/signin.dart';
import 'package:contacts/widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:contacts/others/email_validator.dart';
import 'package:contacts/others/utils.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Build an alert to show some errors
  Future<void> _alertDialogBuilder(String error) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Container(
              child: Text(error),
            ),
            actions: [
              FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Close Dialog'))
            ],
          );
        });
  }

  Future<String> _createAccount() async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: _email, password: _password);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        return ('The account already exists for that email.');
      }
      return e.message;
    } catch (e) {
      return (e.toString());
    }
  }

  void _submitForm() async {
    setState(() {
      _registerFormLoading = true;
    });
    showProgressLoader(context);
    String _createAccountFeedback = await _createAccount();
    if (_createAccountFeedback != null) {
      _alertDialogBuilder(_createAccountFeedback);
      setState(() {
        _registerFormLoading = false;
      });
    } else {
      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );
    }
  }

  bool _registerFormLoading = false;

  // Register email & password
  String _email = "";
  String _password = "";
  String _userName = "";

  // Focus Node for input fields
  FocusNode _passwordFocusNode;

  @override
  void initState() {
    _passwordFocusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomPadding: false,
//      appBar: AppBar(
//        title: Center(child: buildLogoWidget(context)),
//        backgroundColor: Colors.transparent,
//        elevation: 0.0,
//      ),
      body: _isLoading
          ? Container(
              child: Center(child: CircularProgressIndicator()),
            )
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildLogoWidget(context),
                    SizedBox(height: 30),
                    // Spacer(),
                    TextFormField(
                      validator: (val) {
                        if (val.isEmpty) {
                          return "Name field can\'t be empty";
                        } else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                        hintText: "Name",
                      ),
                      onChanged: (val) {
                        _userName = val;
                      },
                    ),
                    SizedBox(height: 6.0),
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) {
                        if (val.isEmpty) {
                          return "Email field can\'t be empty";
                        } else if (!val.isValidEmail()) {
                          return "Invalid Email";
                        } else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                        hintText: "Email",
                      ),
                      onChanged: (val) {
                        _email = val;
                      },
                    ),
                    SizedBox(height: 6.0),
                    TextFormField(
                      obscureText: true,
                      validator: (val) {
                        if (val.trim().isEmpty) {
                          return "Please enter password";
                        } else if (val.trim().length < 6) {
                          return "Password must be at least 6 characters long";
                        } else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                        hintText: "Password",
                      ),
                      onChanged: (val) {
                        _password = val;
                      },
                    ),
                    SizedBox(height: 24.0),
                    GestureDetector(
                      onTap: () {
                        if (_formKey.currentState.validate()) {
                          _submitForm();
                        }
                      },
                      child: blueButton(context: context, label: "Sign Up"),
                    ),
                    SizedBox(height: 18.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignIn(),
                              ),
                            );
                          },
                          child: Text(
                            'Sign In',
                            style: TextStyle(
                              fontSize: 16.0,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.0),
                  ],
                ),
              ),
            ),
    );
  }
}
