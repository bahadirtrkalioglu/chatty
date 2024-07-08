import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:learn_firestore/screens/add_contacts_group_screen.dart';
import 'package:learn_firestore/screens/group_info_screen.dart';
import 'package:learn_firestore/screens/login_screen.dart';
import 'package:learn_firestore/screens/register_screen.dart';
import 'package:learn_firestore/services/auth_services.dart';
import 'package:learn_firestore/utils/my_colors.dart';
import 'package:learn_firestore/utils/the_navigate.dart';
import 'package:learn_firestore/utils/utils.dart';

class ChatScreen extends StatefulWidget {
  final String groupName;
  final String groupId;
  final String senderID;
  final String userName;
  final Color groupColor;
  const ChatScreen({
    super.key,
    required this.groupName,
    required this.groupId,
    required this.senderID,
    required this.userName,
    required this.groupColor,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  // Create a new user with the specified arguments.
  Future<void> addMessage(String senderId, String userName, String text) async {
    await db
        .collection('groups')
        .doc(widget.groupId)
        .collection("messages")
        .add({
      'senderId': senderId,
      'userName': userName,
      'text': text,
      'timestamp': DateTime.now(),
    });
  }

  // Add a new document with generated ID.

  @override
  Widget build(BuildContext context) {
    TextEditingController _messageController = new TextEditingController();
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.groupName,
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: MyColors.primary,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: FaIcon(
              FontAwesomeIcons.userPlus,
              size: 20,
            ),
            onPressed: () => TheNavigate().pushIt(
                context,
                AddContactsGroupScreen(
                  groupId: widget.groupId,
                )),
          ),
          IconButton(
              onPressed: () {
                TheNavigate().pushIt(
                    context,
                    GroupInfoScreen(
                      groupName: widget.groupName,
                      groupColor: widget.groupColor,
                      groupId: widget.groupId,
                    ));
              },
              icon: Icon(Icons.info_outline)),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: db
                  .collection('groups')
                  .doc(widget.groupId)
                  .collection('messages')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  final messages = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (BuildContext context, int index) {
                      final message = messages[index];
                      final uid = message.get("senderId");
                      final bool isCurrentUser = (uid == widget.senderID);
                      return Align(
                        alignment: isCurrentUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          decoration: BoxDecoration(
                            color: !isCurrentUser
                                ? Colors.redAccent.shade100
                                : Colors.blueAccent.shade100,
                            borderRadius: BorderRadius.only(
                              bottomRight: isCurrentUser
                                  ? Radius.zero
                                  : Radius.circular(18),
                              bottomLeft: isCurrentUser
                                  ? Radius.circular(18)
                                  : Radius.zero,
                              topLeft: Radius.circular(18),
                              topRight: Radius.circular(18),
                            ),
                          ),
                          margin: EdgeInsets.only(
                            right: !isCurrentUser ? screenWidth * 1 / 4 : 10,
                            left: isCurrentUser ? screenWidth * 30 / 100 : 10,
                            top: 12,
                          ),
                          padding: EdgeInsets.all(7),
                          child: ListTile(
                            title: Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(message['text']),
                            ),
                            subtitle: Text(message['userName']),
                          ),
                        ),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Text('Error retrieving messages');
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(16.0),
            child: Expanded(
              child: TextField(
                maxLines: null,
                controller: _messageController,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[200],
                  hintText: 'Type a message',
                  hintStyle: TextStyle(color: Colors.grey),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  prefixIcon: IconButton(
                    icon: Icon(Icons.emoji_emotions),
                    color: Colors.grey,
                    onPressed: () {},
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.send, color: Colors.blue),
                    onPressed: () async {
                      addMessage(
                        widget.senderID,
                        widget.userName,
                        _messageController.text,
                      );
                      setState(() {
                        _messageController.clear();
                      });
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
