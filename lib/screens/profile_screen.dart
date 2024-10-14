import 'package:flutter/material.dart';
import 'admin_account_manage_screen.dart';
import 'search_screen.dart';
import 'notification_screen.dart';
import 'homepage_screen.dart';
import 'edit_profile_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  final String userID;

  const ProfileScreen({super.key, required this.userID});

  @override
  _StudentInfoCardState createState() => _StudentInfoCardState();
}

class _StudentInfoCardState extends State<ProfileScreen> {
  int _selectedIndex = 3;

  String? _studentId;
  String? _isAdmin;
  String? _phoneNumber;
  String? _userId;
  String? _email;

  @override
  void initState() {
    super.initState();
    print('User ID: ${widget.userID}');
    getAccount();
  }

  Future<void> getAccount() async {
    try {
      var url = Uri.http("192.168.1.47", '/flutter/getAccount.php');
      var response = await http.post(url, body: {
        "userID": widget.userID,
      });

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _studentId = data['studentId'];
            _isAdmin = data['isAdmin'];
            _phoneNumber = data['phoneNumber'];
            _email = data['email'];
            _userId = data['userID'];
          });
        } else {
          Fluttertoast.showToast(
            backgroundColor: Colors.red,
            textColor: Colors.white,
            msg: data['message'],
            toastLength: Toast.LENGTH_SHORT,
          );
        }
      } else {
        throw Exception('Failed to load account');
      }
    } catch (e) {
      print('Error: $e');
      Fluttertoast.showToast(
        backgroundColor: Colors.red,
        textColor: Colors.white,
        msg: 'An error occurred. Please try again.',
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(userID: widget.userID),
          ),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SearchScreen(userID: widget.userID),
          ),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => NotiScreen(userID: widget.userID),
          ),
        );
        break;
      case 3:
        // No need to push the same screen; you might want to handle a refresh if needed
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.red,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _isAdmin == "1" ? 'Admin Profile' : 'Student Profile',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            // Profile Picture
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, size: 80, color: Colors.white),
            ),
            const SizedBox(height: 20),
            // Main content
            Expanded(
              child: Container(
                color: Colors.white,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      InfoField(
                          label: 'Email', value: _email ?? 'Not Available'),
                      InfoField(
                          label: 'Student ID',
                          value: _studentId ?? 'Not Available'),
                      InfoField(
                          label: 'Phone Number',
                          value: _phoneNumber ?? 'Not Available'),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          bool? result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProfileScreen(
                                userID: widget.userID,
                                phone: _phoneNumber ?? '',
                                email: _email ?? '',
                              ),
                            ),
                          );
                          if (result == true) {
                            getAccount();
                          }
                        },
                        child: const Text('Edit Profile'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          bool? result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AdminAccountManageScreen(),
                            ),
                          );
                          if (result == true) {
                            getAccount();
                          }
                        },
                        child: const Text('Admin Account Manage'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        onTap: _onItemTapped,
        currentIndex: _selectedIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: 'Notifications'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class InfoField extends StatelessWidget {
  final String label;
  final String value;

  const InfoField({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: const BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.horizontal(left: Radius.circular(5)),
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
