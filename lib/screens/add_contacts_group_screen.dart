import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:learn_firestore/services/auth_services.dart';
import 'package:learn_firestore/utils/my_colors.dart';
import 'package:learn_firestore/utils/the_navigate.dart';
import 'package:learn_firestore/widgets/custom_snack.dart';
import 'package:shared_preferences/shared_preferences.dart';

//TODO: Goropta ekli olan kişileri bir daha eklemek için göstermesin!

class AddContactsGroupScreen extends StatefulWidget {
  final String groupId;
  const AddContactsGroupScreen({super.key, required this.groupId});

  @override
  State<AddContactsGroupScreen> createState() => _AddContactsGroupScreenState();
}

class _AddContactsGroupScreenState extends State<AddContactsGroupScreen> {
  final _db = FirebaseFirestore.instance;
  List namesAndEmail = [];
  Future<void> getContacts(BuildContext context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? uid = prefs.getString("uid");
      DocumentReference docRef = _db.collection("users").doc(uid);
      DocumentSnapshot snapshot = await docRef.get();
      List contacts = (snapshot.data() as Map)["contacts"];

      for (var contact in contacts) {
        final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('uid', isEqualTo: contact)
            .get();
        if (querySnapshot.docs.isNotEmpty) {
          DocumentSnapshot userSnapshot = querySnapshot.docs[0];
          String userName = (userSnapshot.data() as Map)['userName'];
          String email = (userSnapshot.data() as Map)['email'];
          String userID = (userSnapshot.data() as Map)['uid'];
          setState(() {
            namesAndEmail.add([userName, email, userID]);
          });
        }
      }
    } on FirebaseException catch (error) {
      await CustomSnack.showCustomSnackBar(context, error.message!);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getContacts(context);
  }

  List<bool> checkboxState = [];

  @override
  Widget build(BuildContext context) {
    checkboxState = List<bool>.filled(namesAndEmail.length, false);
    List willAddMemberIds = [];

    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            int counter = 0;
            for (bool val in checkboxState) {
              if (val) {
                setState(() {
                  willAddMemberIds.add(namesAndEmail[counter][2]);
                });
              }
              counter++;
            }
            await AuthServices()
                .addGroupMembers(context, willAddMemberIds, widget.groupId);
            Navigator.pop(context);
          },
          child: FaIcon(
            FontAwesomeIcons.check,
            size: 22,
          ),
        ),
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            "Contacts",
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: MyColors.primary,
          centerTitle: true,
          elevation: 0,
        ),
        body: namesAndEmail.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: namesAndEmail.length,
                  itemBuilder: (context, index) {
                    return StatefulBuilder(
                      builder: (context, setState) {
                        return CheckboxListTile(
                          title: Text(namesAndEmail[index][0]),
                          subtitle: Text(namesAndEmail[index][1]),
                          value: checkboxState[index],
                          onChanged: (value) {
                            setState(() {
                              checkboxState[index] = value!;
                            });
                          },
                        );
                      },
                    );
                  },
                ),
              )
            : Center(
                child: CircularProgressIndicator(),
              ));
  }
}
