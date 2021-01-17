import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts/screens/create_contact.dart';
import 'package:contacts/screens/show_contacts.dart';
import 'package:contacts/screens/signin.dart';
import 'package:contacts/widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final CollectionReference _contactsRef =
      FirebaseFirestore.instance.collection('Contacts');

  AuthService authService = new AuthService();

  logout() async {
    await authService.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignIn()),
    );
  }

  Widget contactList() {
    return Container(
      margin: EdgeInsets.only(left: 16.0, right: 16.0),
      child: FutureBuilder<QuerySnapshot>(
        future: _contactsRef.get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Text('Error: ${snapshot.error}'),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.done) {
            // display data in listview
            return ListView(
              children: snapshot.data.docs.map((document) {
                return ContactTile(
                  contactId: document.id,
                  userId: document.data()['userId'],
                  imgUrl: document.data()['contactImage'],
                  fname: document.data()['firstName'],
                  mname: document.data()['middleName'],
                  lname: document.data()['lastName'],
                  email: document.data()['email'],
                  mnumber: document.data()['mobileNumber'],
                  lnumber: document.data()['landlineNumber'],
                  notes: document.data()['notes'],
                );
              }).toList(),
            );
          }

          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: buildLogoWidget(context)),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        actions: [
          GestureDetector(
            onTap: () {
              logout();
            },
            child: Container(
              margin: EdgeInsets.only(right: 10.0),
              child: Icon(
                Icons.logout,
                color: Colors.black45,
              ),
            ),
          ),
        ],
      ),
      body: contactList(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateContact()),
          );
        },
      ),
    );
  }
}

class ContactTile extends StatelessWidget {
  final String imgUrl,
      contactId,
      fname,
      lname,
      mname,
      mnumber,
      lnumber,
      email,
      notes,
      userId;
  ContactTile({
    @required this.fname,
    @required this.imgUrl,
    @required this.lname,
    @required this.mname,
    @required this.mnumber,
    @required this.lnumber,
    @required this.email,
    @required this.notes,
    @required this.userId,
    @required this.contactId,
  });

  @override
  Widget build(BuildContext context) {
    final User _user = FirebaseAuth.instance.currentUser;
    if (userId == _user.uid) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ShowContact(
                contactId: contactId,
              ),
            ),
          );
        },
        child: Card(
          child: Container(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.network(
                    imgUrl,
                    width: 45,
                    height: 45,
                    fit: BoxFit.cover,
                  ),
                ),
                // Text('${userId}'),
                Container(
                  margin: EdgeInsets.only(left: 16),
                  child: Row(
                    children: [
                      Text(
                        fname,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 2),
                      Text(
                        mname,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 2),
                      Text(
                        lname,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
  }
}
