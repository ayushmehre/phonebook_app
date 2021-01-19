import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts/screens/create_contact.dart';
import 'package:contacts/screens/home.dart';
import 'package:contacts/widgets/constants.dart';
import 'package:contacts/widgets/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ShowContact extends StatefulWidget {
  final String contactId;
  bool _registerFormLoading = false;

  ShowContact({this.contactId});

  @override
  _ShowContactState createState() => _ShowContactState();
}

class _ShowContactState extends State<ShowContact> {
  bool _isLoading = false;

  final CollectionReference contactsRef =
      FirebaseFirestore.instance.collection('Contacts');

  final CollectionReference _usersRef =
      FirebaseFirestore.instance.collection('Users');

  final databaseReference = FirebaseFirestore.instance;

  deleteContact() async {
    await databaseReference
        .collection("Contacts")
        .doc(widget.contactId)
        .delete()
        .then((value) {
      setState(() {
        _isLoading = false;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Home(),
          ),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Center(child: buildLogoWidget(context)),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        brightness: Brightness.light,
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      body: Stack(
        children: [
          FutureBuilder(
            future: contactsRef.doc(widget.contactId).get(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Scaffold(
                  body: Center(
                    child: Text('Error: ${snapshot.error}'),
                  ),
                );
              }

              if (snapshot.connectionState == ConnectionState.done) {
                // Firebase Document Data Map
                Map<String, dynamic> documentData = snapshot.data.data();

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: ListView(
                    children: [
                      Stack(
                        alignment: Alignment.bottomLeft,
                        children: [
                          Container(
                            color: Color(0xffdcdcdc),
                            child: Center(
                              child: Image.network(
                                "${documentData['contactImage']}",
                                height: 320,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(bottom: 14, left: 44),
                            child: Row(
                              children: [
                                Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 2,
                                      color: Colors.white,
                                    ),
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  margin: EdgeInsets.only(right: 10),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(50),
                                    child: Image.network(
                                      "${documentData['contactImage']}",
                                      height: 40,
                                    ),
                                  ),
                                ),
                                Text(
                                  "${documentData['firstName']}" ??
                                      'First Name',
                                  style: Constants.boldHeading,
                                ),
                                SizedBox(width: 3),
                                Text(
                                  "${documentData['middleName']}" ??
                                      'Middle Name',
                                  style: Constants.boldHeading,
                                ),
                                SizedBox(width: 3),
                                Text(
                                  "${documentData['lastName']}" ?? 'Last Name',
                                  style: Constants.boldHeading,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xffeeeeee),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 24.0),
                        margin: EdgeInsets.only(
                            bottom: 6, left: 12, right: 12, top: 40),
                        child: Text(
                          "Email: ${documentData['email']}" ?? 'Email',
                          style: Constants.regularHeading,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xffeeeeee),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 24.0),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 6),
                        child: Text(
                          "Mobile number: ${documentData['mobileNumber']}" ??
                              'Mobile Number',
                          style: Constants.regularHeading,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xffeeeeee),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 24.0),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 6),
                        child: Text(
                          "Landline number: ${documentData['landlineNumber']}" ??
                              'Landline Number',
                          style: Constants.regularHeading,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 24.0),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 6),
                        child: Text("${documentData['notes']}"),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CreateContact(
                                      contactId: widget.contactId,
                                      document: documentData,
                                      userId: documentData['userId'],
                                      contactImage:
                                          documentData['contactImage'],
                                    ),
                                  ),
                                );
                              },
                              child: blueButton(
                                label: 'Edit Contact',
                                context: context,
                                buttonWidth:
                                    MediaQuery.of(context).size.width / 2 - 28,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  deleteContact();
                                  // Scaffold.of(context)
                                  //     .showSnackBar(_snackBarAddToCard);
                                },
                                child: blueButton(
                                  label: 'Delete Contact',
                                  context: context,
                                  buttonWidth:
                                      MediaQuery.of(context).size.width / 2 - 4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              }

              // Loading state
              return Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
