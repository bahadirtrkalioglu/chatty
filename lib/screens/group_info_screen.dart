import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:learn_firestore/utils/my_colors.dart';
import 'package:learn_firestore/widgets/custom_snack.dart';

class GroupInfoScreen extends StatefulWidget {
  final String groupName;
  final Color groupColor;
  final String groupId;
  const GroupInfoScreen(
      {super.key,
      required this.groupName,
      required this.groupColor,
      required this.groupId});

  @override
  State<GroupInfoScreen> createState() => _GroupInfoScreenState();
}

class _GroupInfoScreenState extends State<GroupInfoScreen> {
  final _db = FirebaseFirestore.instance;
  List? namesAndEmail;
  Future<void> getGroupMembers(String groupID) async {
    try {
      DocumentReference groupDocRef = _db.collection("groups").doc(groupID);
      final DocumentSnapshot groupSnapshot = await groupDocRef.get();
      if (groupSnapshot.exists) {
        final Map<String, dynamic>? groupData =
            groupSnapshot.data() as Map<String, dynamic>?;
        if (groupData != null && groupData.containsKey("members")) {
          final List<String> members = List<String>.from(groupData["members"]);
          List<List<dynamic>> userNameAndEmail = [];

          for (var memberID in members) {
            DocumentReference memberDocRef =
                _db.collection("users").doc(memberID);
            DocumentSnapshot memberSnapshot = await memberDocRef.get();
            if (memberSnapshot.exists) {
              final Map<String, dynamic>? memberData =
                  memberSnapshot.data() as Map<String, dynamic>?;
              if (memberData != null) {
                userNameAndEmail
                    .add([memberData["userName"], memberData["email"]]);
              }
            }
          }

          setState(() {
            namesAndEmail = userNameAndEmail;
          });
        } else {
          throw FirebaseException(
            plugin: 'Firestore',
            message: 'Couldn\'t find the group. Please try again!',
          );
        }
      } else {
        throw FirebaseException(
          plugin: 'Firestore',
          message: 'Couldn\'t find the group. Please try again!',
        );
      }
    } on FirebaseException catch (error) {
      CustomSnack.showCustomSnackBar(context, error.message!);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getGroupMembers(widget.groupId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            widget.groupName,
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: MyColors.primary,
          centerTitle: true,
          elevation: 0,
        ),
        body: namesAndEmail != null
            ? SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: widget.groupColor,
                          child: Text(
                            widget.groupName.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Divider(color: Colors.black54, thickness: 2),
                      const SizedBox(
                        height: 3,
                      ),
                      const Text(
                        "Admin",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      const Divider(color: Colors.black54, thickness: 2),
                      const SizedBox(
                        height: 5,
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 10),
                        decoration: BoxDecoration(
                            color: MyColors.accent.withOpacity(0.65),
                            borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.all(7),
                        child: ListTile(
                          title: Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(namesAndEmail![0][0] ?? "Loading..."),
                          ),
                          subtitle: Text(namesAndEmail![0][1] ?? "Loading..."),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Divider(color: Colors.black54, thickness: 2),
                      const SizedBox(
                        height: 3,
                      ),
                      const Text(
                        "Group Members",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      const Divider(color: Colors.black54, thickness: 2),
                      const SizedBox(
                        height: 5,
                      ),
                      Column(
                          children: namesAndEmail != null
                              ? List.generate(namesAndEmail!.length, (index) {
                                  return Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 10),
                                    decoration: BoxDecoration(
                                        color: Colors.blueAccent.shade100,
                                        borderRadius:
                                            BorderRadius.circular(14)),
                                    padding: const EdgeInsets.all(7),
                                    child: ListTile(
                                      title: Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8.0),
                                        child: Text(namesAndEmail![index][0]),
                                      ),
                                      subtitle: Text(namesAndEmail![index][1]),
                                    ),
                                  );
                                }, growable: true)
                              : [
                                  const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                ]),
                    ],
                  ),
                ),
              )
            : const Center(
                child: CircularProgressIndicator(),
              ));
  }
}
