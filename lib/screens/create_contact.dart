import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts/screens/home.dart';
import 'package:contacts/widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class CreateContact extends StatefulWidget {
  final String contactId;

  final Map<String, dynamic> document;

  CreateContact({this.contactId, this.document});

  @override
  _CreateContactState createState() => _CreateContactState();
}

class _CreateContactState extends State<CreateContact> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  TextEditingController firstNameController;
  TextEditingController middleNameController;
  TextEditingController lastNameController;
  TextEditingController emailController;
  TextEditingController mobileNumberController;
  TextEditingController landLineNumberController;
  TextEditingController notesController;

  File _image;
  final selected = ImagePicker();

//  String firstName,
//      middleName,
//      lastName,
//      email,
//      mobileNumber,
//      landlineNumber,
//      notes,
//      contactId;

  final databaseReference = FirebaseFirestore.instance;
  final User _user = FirebaseAuth.instance.currentUser;

  Future getImage() async {
    final selectedImage = await selected.getImage(source: ImageSource.gallery);

    setState(() {
      if (selectedImage != null) {
        _image = File(selectedImage.path);
      } else {
        print('No image selected.');
        return showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text("Alert Dialog Box"),
            content: Text("You have raised a Alert Dialog Box"),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: Text("okay"),
              ),
            ],
          ),
        );
      }
    });
  }

  // Add contact data
  createContactOnline() async {
    if (_formKey.currentState.validate()) {
      setState(() {
        _isLoading = true;
      });
      if (_image != null) {
        // Uploading Images to Firestore
        firebase_storage.Reference ref = firebase_storage
            .FirebaseStorage.instance
            .ref()
            .child('ContactImages')
            .child("${randomAlphaNumeric(9)}.jpg");

        final firebase_storage.UploadTask uploadTask = ref.putFile(_image);

        final link = await (await uploadTask).ref.getDownloadURL();
        print('This is url: ${link}');

        var contactId = randomAlphaNumeric(16);
        Map<String, String> contactMap = {
          "userId": _user.uid,
          "contactId": contactId,
          "contactImage": link != null ? link : "No Image",
          "firstName": firstNameController.value.text ?? "",
          "middleName": middleNameController.value.text ?? "",
          "lastName": lastNameController.value.text ?? "",
          "email": emailController.value.text ?? "",
          "mobileNumber": mobileNumberController.value.text ?? "",
          "landlineNumber": landLineNumberController.value.text ?? "",
          "notes": notesController.value.text ?? "",
        };
        databaseReference
            .collection("Contacts")
            .add(contactMap)
            .then((results) {
          setState(() {
            // _isLoading = false;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Home(),
              ),
            );
          });
        });
      } else {}
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    firstNameController = TextEditingController(
        text: widget.document != null ? widget.document["firstName"] : "");
    middleNameController = TextEditingController(
        text: widget.document != null ? widget.document["middleName"] : "");
    lastNameController = TextEditingController(
        text: widget.document != null ? widget.document["lastName"] : "");
    emailController = TextEditingController(
        text: widget.document != null ? widget.document["email"] : "");
    mobileNumberController = TextEditingController(
        text: widget.document != null ? widget.document["mobileNumber"] : "");
    landLineNumberController = TextEditingController(
        text: widget.document != null ? widget.document["landlineNumber"] : "");
    notesController = TextEditingController(
        text: widget.document != null ? widget.document["notes"] : "");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text(
          "Create New Contact",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        brightness: Brightness.light,
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      body: _isLoading
          ? Container(
              child: Center(child: CircularProgressIndicator()),
            )
          : Form(
              key: _formKey,
              child: Container(
                padding: EdgeInsets.only(left: 16, right: 16),
                margin: EdgeInsets.only(top: 10),
                child: ListView(
                  children: [
                    GestureDetector(
                      onTap: () {
                        getImage();
                      },
                      child: _image != null
                          ? Container(
                              width: MediaQuery.of(context).size.width,
                              height: 200.0,
                              child: Image.file(_image),
                            )
                          : Container(
                              height: 120,
                              margin: EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Color(0xfff2f2f2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.add_a_photo,
                                size: 60.0,
                              ),
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: TextFormField(
                        validator: (val) {
                          if (val.isEmpty) {
                            return "Cannot be empty";
                          } else {
                            return null;
                          }
                        },
                        controller: firstNameController,
                        decoration: InputDecoration(
                            labelText: "First name", isDense: true),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: TextFormField(
                        controller: middleNameController,
                        decoration: InputDecoration(
                            labelText: "Middle name", isDense: true),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: TextFormField(
                        controller: lastNameController,
                        decoration: InputDecoration(
                            labelText: "Last name", isDense: true),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: TextFormField(
                        controller: emailController,
                        decoration:
                            InputDecoration(labelText: "Email", isDense: true),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: TextFormField(
                        controller: mobileNumberController,
                        decoration: InputDecoration(
                            labelText: "Mobile Number", isDense: true),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: TextFormField(
                        controller: landLineNumberController,
                        decoration: InputDecoration(
                            labelText: "LandLine Number", isDense: true),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: TextFormField(
                        controller: notesController,
                        decoration: InputDecoration(
                            labelText: "Notes (optional)", isDense: true),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        createContactOnline();
                      },
                      child: Container(
                        margin: EdgeInsets.all(15),
                        child: blueButton(
                          context: context,
                          label: "Create Contact",
                        ),
                      ),
                    ),
                    SizedBox(height: 36.0),
                  ],
                ),
              ),
            ),
    );
  }
}
