import 'package:flutter/material.dart';
import 'package:learn_firestore/screens/about_page.dart';
import 'package:learn_firestore/services/auth_services.dart';

class AppDrawer extends StatelessWidget {
  final String userName;
  final String email;
  const AppDrawer({super.key, required this.email, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              userName,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
            accountEmail: Text(
              email,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.grey.shade200,
              child: ClipOval(
                child: Image.network(
                  'https://cdn-icons-png.flaticon.com/512/1946/1946429.png',
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            decoration: const BoxDecoration(
              color: Colors.amber,
              image: DecorationImage(
                image: NetworkImage(
                    'https://oflutter.com/wp-content/uploads/2021/02/profile-bg3.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text("Settings"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text("About"),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) {
                  return const AboutPage();
                },
              ));
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout_rounded),
            title: const Text("Sign Out"),
            onTap: () async {
              await AuthServices().signOut(context);
            },
          ),
        ],
      ),
    );
  }
}
