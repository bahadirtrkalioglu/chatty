import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:learn_firestore/screens/chat_screen.dart';
import 'package:learn_firestore/screens/home_screen.dart';
import 'package:learn_firestore/screens/login_screen.dart';
import 'package:learn_firestore/screens/register_screen.dart';
import 'package:learn_firestore/utils/the_navigate.dart';
import 'package:learn_firestore/utils/utils.dart';
import 'package:learn_firestore/widgets/custom_snack.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthServices {
  final _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future register(
      String name, String email, String password, BuildContext context) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;
      if (user != null) {
        // Create a new document for the user in Firestore
        await _db.collection('users').doc(user.uid).set({
          'email': email,
          'userName': name,
          'uid': user.uid,
          'groups': [],
          'contacts': [],
        });
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', email);
        await prefs.setString('userName', name);
        await prefs.setString('uid', user.uid);
        TheNavigate().pushReplaceIt(context, HomeScreen());
      }
    } on FirebaseException catch (e) {
      return CustomSnack.showCustomSnackBar(context, e.message!);
    }
  }

  Future login(String email, String password, BuildContext context) async {
    try {
      UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password)
          .catchError((e) => debugPrint("ERROR: $e"));
      User? user = userCredential.user;
      if (user != null) {
        final lastUser = await _db.collection('users').doc(user.uid).get();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', lastUser.get('email'));
        await prefs.setString('userName', lastUser.get('userName'));
        await prefs.setString('uid', lastUser.get('uid'));
        TheNavigate().pushReplaceIt(context, HomeScreen());
      }
    } on FirebaseException catch (e) {
      return CustomSnack.showCustomSnackBar(context, e.message!);
    }
  }

  Future signOut(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      await _auth.signOut();
      await prefs.remove("email");
      await prefs.remove("userName");
      await prefs.remove("uid");
      TheNavigate().pushReplaceIt(context, LoginScreen());
    } catch (e) {
      //! ADD SNACKBAR
      print("Can't sign out: $e");
    }
  }

  Future createGroup(BuildContext context, String groupName) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? _uid = await prefs.getString("uid");
      DocumentReference userRef =
          FirebaseFirestore.instance.collection('users').doc(_uid);
      DocumentSnapshot userSnapshot = await userRef.get();
      CollectionReference groupCollection =
          FirebaseFirestore.instance.collection('groups');
      DocumentReference newGroupRef = await groupCollection.add({
        'groupName': groupName,
        'members': [_uid],
        'admin': _uid,
      });
      if (userSnapshot.exists) {
        List<String> existingGroups = List<String>.from(
            (userSnapshot.data() as Map<String, dynamic>)["groups"] ?? []);

        // Add the new group to the existing groups list
        existingGroups.add(newGroupRef.id);

        // Update the 'groups' field of the user document
        await userRef.update({'groups': existingGroups});
      }
    } on FirebaseException catch (e) {
      CustomSnack.showCustomSnackBar(context, e.message!);
    }
  }

  Future<void> addContacts(BuildContext context, String contactEmail) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? uid = prefs.getString("uid");
      final DocumentReference docRef = _db.collection("users").doc(uid);

      final DocumentSnapshot snapshot = await docRef.get();
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>?;
        if (data != null && !data.containsKey('contacts')) {
          await docRef.update({'contacts': []});
        }
      } else {
        throw Exception("Document not found");
      }

      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: contactEmail)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final DocumentSnapshot documentSnapshot = querySnapshot.docs[0];
        final String theuid = documentSnapshot.id;

        DocumentReference theUser = _db.collection("users").doc(uid);
        final DocumentSnapshot userSnapshot = await theUser.get();

        if (userSnapshot.exists) {
          final data = userSnapshot.data() as Map<String, dynamic>?;
          if (data != null && data.containsKey('contacts')) {
            List<dynamic> contacts = data['contacts'];
            if (!contacts.contains(theuid)) {
              contacts.add(theuid);
              await theUser.update({'contacts': contacts});
              await CustomSnack.showCustomSnackBar(
                context,
                "User added to your contacts list successfully!",
              );
            } else {
              CustomSnack.showCustomSnackBar(
                context,
                'This user is already in your contacts list!',
              );
            }
          }
        } else {
          throw FirebaseException(
              plugin: 'Firestore', message: 'User not found!');
        }
      } else {
        throw FirebaseException(
          plugin: 'Firestore',
          message: 'No email with the given email found!',
        );
      }
    } on FirebaseException catch (error) {
      await CustomSnack.showCustomSnackBar(context, error.message!);
    }
  }

  Future addGroupMembers(
      BuildContext context, List memberIds, String groupId) async {
    try {
      DocumentReference docRef = _db.collection("groups").doc(groupId);
      DocumentSnapshot snapshot = await docRef.get();
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>?;
        List members = data!["members"];
        for (var id in memberIds) {
          DocumentReference userIdRef = _db.collection("users").doc(id);
          DocumentSnapshot userSnapshot = await userIdRef.get();
          if (userSnapshot.exists) {
            final userData = userSnapshot.data() as Map<String, dynamic>?;
            List groups = userData!["groups"];
            groups.add(groupId);
            await userIdRef.update({'groups': groups});
          } else {
            throw FirebaseException(
                plugin: 'Firestore',
                message: "Couldn't add members! Try again later");
          }
          members.add(id);
        }
        await docRef.update({'members': members});
        await CustomSnack.showCustomSnackBar(
            context, "Users added to the group!");
      } else {
        throw FirebaseException(
            plugin: 'Firestore',
            message: "Couldn't add members! Try again later");
      }
    } on FirebaseException catch (error) {
      CustomSnack.showCustomSnackBar(context, error.message!);
    }
  }
}
