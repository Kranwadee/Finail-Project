import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'activity_details_screen.dart';
import 'homepage_screen.dart';
import 'profile_screen.dart';
import 'notification_screen.dart';

class SearchScreen extends StatefulWidget {
  final String userID;

  const SearchScreen({
    super.key,
    required this.userID,
  });

  @override
  _SearchScreen createState() => _SearchScreen();
}

class _SearchScreen extends State<SearchScreen> {
  int _selectedIndex = 1;

  String? _studentId;
  String? _isAdmin;
  String? _phoneNumber;
  String? _userId;
  String? _email;
  List<Map<String, dynamic>> _activities = [];
  List<Map<String, dynamic>> _filteredActivities = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getAccount();
    fetchActivities();
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
            _userId = data['userId'];
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

  Future<void> fetchActivities() async {
    try {
      var url = Uri.http("192.168.1.47", '/flutter/getActivities.php');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _activities = List<Map<String, dynamic>>.from(data['activities']);
            _filteredActivities =
                _activities; // Initialize filtered list with all activities
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
        throw Exception('Failed to load activities');
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

  void _onSearchChanged(String query) {
    setState(() {
      _filteredActivities = _activities.where((activity) {
        return activity['title'].toLowerCase().contains(query.toLowerCase()) ||
            activity['description'].toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    String userID = widget.userID;

    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(userID: userID),
          ),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SearchScreen(userID: userID),
          ),
        );
        break;
      case 2:
        Navigator.push(
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

  void _onActivityTap(Map<String, dynamic> activity) {
    Navigator.pushNamed(
      context,
      '/activityDetail',
      arguments: ActivityDetailsArguments(
        userId: widget.userID,
        activityId:
            activity['id'] ?? '', // Provide default value if key is missing
        title: activity['title'] ?? '',
        imagePath: activity['imagePath'] ?? '',
        description: activity['description'] ?? '',
        isJoinable: activity['isJoinable'] ?? false,
        category: activity['category'] ?? '',
        score: activity['score'] ?? '0',
        datetime: activity['datetime'] ?? '',
        location: activity['location'] ?? '',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Hide back button
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
                _studentId ?? 'Loading...',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search',
                suffixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredActivities.length,
              itemBuilder: (context, index) {
                var activity = _filteredActivities[index];
                return ListTile(
                  leading: const Icon(Icons.arrow_right, color: Colors.red),
                  title: Text(activity['title'],
                      style: const TextStyle(color: Colors.red)),
                  onTap: () => _onActivityTap(activity),
                );
              },
            ),
          ),
        ],
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
