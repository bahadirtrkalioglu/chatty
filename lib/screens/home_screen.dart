import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:learn_firestore/screens/chat_screen.dart';
import 'package:learn_firestore/services/auth_services.dart';
import 'package:learn_firestore/utils/my_colors.dart';
import 'package:learn_firestore/utils/the_navigate.dart';
import 'package:learn_firestore/widgets/add_group.dart';
import 'package:learn_firestore/widgets/app_drawer.dart';
import 'package:learn_firestore/widgets/auth_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? email;
  String? userName;
  List? groupNames;
  List? groupIDs;
  bool hasValue = false;
  String? uid;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCrediantils();
    getGroupsForUser();
  }

  Future<String?> getCrediantils() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('email');
      userName = prefs.getString('userName');
    });
    return null;
  }

  Future getGroupsForUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("uid");
    uid = userId;
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('groups')
        .where('members', arrayContains: userId)
        .get();

    groupNames = [];
    groupIDs = [];

    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      String groupName = doc.get('groupName');
      groupNames!.add(groupName);
      String groupId = doc.id;
      groupIDs!.add(groupId);
    }
    setState(() {
      hasValue = true;
    });
    return groupNames;
  }

  void _showCustomModalBottomSheet(BuildContext context) {
    TextEditingController groupName = TextEditingController();
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(15.0),
        ),
      ),
      isDismissible: false,
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              top: 16,
              right: 16,
              left: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthTextField(
                  //! Add validation!
                  text: "Group Name",
                  controller: groupName,
                  isObscured: false),
              const SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: Colors.red),
                      )),
                  const SizedBox(
                    width: 10,
                  ),
                  TextButton(
                      //! Add validation!
                      onPressed: () async {
                        await AuthServices()
                            .createGroup(context, groupName.text);
                        Navigator.pop(context);
                        groupName.clear();
                        getGroupsForUser();
                      },
                      child: const Text(
                        "Create",
                        style: TextStyle(color: Colors.green),
                      )),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  void _showAddContactsSheet(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(15.0),
        ),
      ),
      isDismissible: false,
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              top: 16,
              right: 16,
              left: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthTextField(
                  //! Add validation!
                  text: "User's Email Address",
                  controller: emailController,
                  isObscured: false),
              const SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: Colors.red),
                      )),
                  const SizedBox(
                    width: 10,
                  ),
                  TextButton(
                      //! Add validation!
                      onPressed: () async {
                        await AuthServices()
                            .addContacts(context, emailController.text);
                        emailController.clear();
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Create",
                        style: TextStyle(color: Colors.green),
                      )),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(
        email: email ?? "Loading...",
        userName: userName ?? "Loading...",
      ),
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: [
          IconButton(
              icon: const FaIcon(
                FontAwesomeIcons.userPlus,
                size: 21,
              ),
              onPressed: () => _showAddContactsSheet(context))
        ],
        title: const Text(
          'Chatty',
          style: TextStyle(
              fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: MyColors.primary,
        centerTitle: true,
        elevation: 0,
      ),
      floatingActionButton: AddGroup(
        onPressed: () {
          _showCustomModalBottomSheet(context);
        },
      ),
      body: hasValue == true && groupNames!.isEmpty
          ? SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset("assets/images/empty.png"),
                    const SizedBox(
                      height: 15,
                    ),
                    Text(
                      "Let's create a new group to chat!",
                      style: TextStyle(
                          color: Colors.grey.shade800,
                          fontWeight: FontWeight.w500,
                          fontSize: 20),
                    )
                  ],
                ),
              ),
            )
          : hasValue == true && groupNames != null
              ? SafeArea(
                  child: ListView.builder(
                    itemCount: groupNames!.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => TheNavigate().pushIt(
                          context,
                          ChatScreen(
                            groupName: groupNames![index],
                            groupId: groupIDs![index],
                            senderID: uid!,
                            userName: userName!,
                            groupColor: MyColors.colorList[index],
                          ),
                        ),
                        child: Container(
                          decoration: const BoxDecoration(
                              color: MyColors.background,
                              border: Border(
                                  bottom: BorderSide(
                                      color: MyColors.divider, width: 2))),
                          padding: const EdgeInsets.only(
                            top: 13,
                            bottom: 13,
                            right: 10,
                            left: 10,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 26,
                              backgroundColor: MyColors.colorList[index],
                              child: Text(
                                (groupNames![index] as String)
                                    .substring(0, 1)
                                    .toUpperCase(),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 25,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            title: Text(
                              groupNames![index] as String,
                              style: const TextStyle(
                                  color: MyColors.textPrimary,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )
              : const Center(
                  child: CircularProgressIndicator(color: Colors.deepPurple),
                ),
    );
  }
}
