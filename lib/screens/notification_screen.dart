import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/screens/homepage_screen.dart';
import '/screens/search_screen.dart';
import '/screens/profile_screen.dart';
import 'package:intl/intl.dart';

class NotiScreen extends StatefulWidget {
  final String userID;

  const NotiScreen({
    super.key,
    required this.userID,
  });

  @override
  _NotiScreenState createState() => _NotiScreenState();
}

class _NotiScreenState extends State<NotiScreen> {
  int _selectedIndex = 2;
  List<dynamic> _activities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserActivities();
  }

  Future<void> fetchUserActivities() async {
    if (_isLoading) {
      setState(() {
        _isLoading = false;
      });

      try {
        var url = Uri.http("192.168.1.47", '/flutter/getUserActivities.php');
        var response = await http.post(url, body: {
          "userID": widget.userID,
        });

        if (response.statusCode == 200) {
          var data = json.decode(response.body);
          if (data['status'] == 'success') {
            setState(() {
              _activities =
                  (data['activities'] as List<dynamic>?)?.map((activity) {
                        DateTime eventDateTime =
                            DateTime.tryParse(activity['datetime'] ?? '') ??
                                DateTime.now();
                        return {
                          ...activity,
                          'eventDateTime': eventDateTime.toIso8601String(),
                        };
                      }).toList() ??
                      [];
            });
          } else {
            Fluttertoast.showToast(
              backgroundColor: Colors.red,
              textColor: Colors.white,
              msg: data['message'] ?? 'Unknown error occurred',
              toastLength: Toast.LENGTH_SHORT,
            );
          }
        } else {
          throw Exception('Failed to load user activities');
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
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    String userID = widget.userID;

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(userID: userID),
          ),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SearchScreen(userID: userID),
          ),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => NotiScreen(userID: userID),
          ),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileScreen(userID: userID),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.red,
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.grey),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Notifications',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        color: Colors.grey[200],
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  Text(
                    'กิจกรรมที่คุณติดตามใกล้จะมาถึงเร็วๆนี้ !!!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'เข้าร่วมและเชียร์ ! วันจันทร์ที่ 22 กรกฎาคม 2567',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'กิจกรรมที่คุณติดตามใกล้จะมาถึงเร็วๆนี้ !!!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '4.8 KM วันจันทร์ที่ 22 กรกฎาคม 2567',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        onTap: _onItemTapped,
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
