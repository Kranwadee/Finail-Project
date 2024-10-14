import 'package:flutter/material.dart';
import 'activity_details_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'search_screen.dart';
import 'profile_screen.dart';
import 'notification_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userID;

  const HomeScreen({super.key, required this.userID});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> _activities = [];
  String? _studentId;
  String? _isAdmin;
  String? _phoneNumber;
  String? _email;
  String? _userId;

  @override
  void initState() {
    super.initState();
    getAccount();
    fetchActivities();
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

  Future<void> _addActivity() async {
    final result = await Navigator.pushNamed(context, '/addActivity')
        as Map<String, dynamic>?;

    if (result != null) {
      try {
        var url = Uri.http("192.168.1.47", '/flutter/addActivity.php');

        var response = await http.post(url, headers: {
          "Content-Type": "application/x-www-form-urlencoded"
        }, body: {
          "id": result['id']?.toString() ?? '',
          "title": result['title'] ?? 'Null',
          "imagePath": result['imagePath'] ??
              'https://www.shutterstock.com/image-vector/slogan-oops-sorry-funny-vector-260nw-1514682761.jpg',
          "description": result['description'] ?? 'Null',
          "scoreType": result['category'] ?? 'Null',
          "score": result['score']?.toString() ?? '0',
          "location": result['location']?.toString() ?? '0',
          "datetime": result['datetime']?.toString() ?? '0',
          "isJoinable": result['isJoinable']?.toString() ?? '0'
        });

        if (response.statusCode == 200) {
          var data = json.decode(response.body);
          if (data['status'] == 'success') {
            fetchActivities();
            Fluttertoast.showToast(
              backgroundColor: Colors.green,
              textColor: Colors.white,
              msg: 'Activity updated successfully',
              toastLength: Toast.LENGTH_SHORT,
            );
          } else {
            Fluttertoast.showToast(
              backgroundColor: Colors.red,
              textColor: Colors.white,
              msg: data['message'],
              toastLength: Toast.LENGTH_SHORT,
            );
          }
        } else {
          throw Exception('Failed to add activity');
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

  Future<void> _detailActivity(int index) async {
    final reload = false;
    final updatedActivity = await Navigator.pushNamed(
      context,
      '/activityDetail',
      arguments: ActivityDetailsArguments(
        userId: widget.userID,
        activityId: _activities[index]['id']!,
        title: _activities[index]['title']!,
        imagePath: _activities[index]['imagePath']!,
        description: _activities[index]['description']!,
        isJoinable: _activities[index]['isJoinable'] as bool,
        category: _activities[index]['category']!,
        score: _activities[index]['score']!,
        datetime: _activities[index]['datetime']!,
        location: _activities[index]['location']!,
      ),
    ) as Map<String, dynamic>?;

    setState(() {
      fetchActivities();
    });
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
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _studentId ?? 'Loading...',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton(
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child:
                  Text('กิจกรรมแนะนำ ▼', style: TextStyle(color: Colors.white)),
            ),
            itemBuilder: (context) => [
              const PopupMenuItem(child: Text('กิจกรรมทางมหาลัย')),
              const PopupMenuItem(child: Text('กิจกรรมทางชมรม')),
            ],
          ),
        ],
      ),
      body: _activities.isEmpty
          ? Center(
              child:
                  CircularProgressIndicator()) // Show a loading indicator if activities are not loaded yet
          : ListView.builder(
              itemCount: _activities.length,
              itemBuilder: (context, index) {
                final activity = _activities[index];
                return GestureDetector(
                  onTap: () => _detailActivity(index),
                  child: EventCard(
                    activityId: activity['id']!,
                    title: activity['title']!,
                    imagePath: activity['imagePath']!,
                    description: activity['description']!,
                    isJoinable: activity['isJoinable'] as bool,
                    category: activity['category']!,
                    score: activity['score']!,
                    datetime: activity['datetime']!,
                    location: activity['location']!,
                  ),
                );
              },
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
      floatingActionButton: _isAdmin == '1'
          ? FloatingActionButton(
              onPressed: _addActivity,
              child: const Icon(Icons.add),
              backgroundColor: Colors.blue,
            )
          : null,
    );
  }
}

class EventCard extends StatelessWidget {
  final String activityId;
  final String title;
  final String imagePath;
  final String description;
  final bool isJoinable;
  final String category;
  final String score;
  final String datetime;
  final String location;

  const EventCard({
    super.key,
    required this.activityId,
    required this.title,
    required this.imagePath,
    required this.description,
    required this.isJoinable,
    required this.category,
    required this.score,
    required this.datetime,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Conditionally render the image block if imagePath is not null or empty
          if (imagePath.isNotEmpty &&
              Uri.tryParse(imagePath)?.isAbsolute == true)
            Image.network(
              imagePath,
              fit: BoxFit.cover,
              height: 200,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                // If image fails to load, do not display the image block
                return SizedBox.shrink();
              },
            )
          else
            SizedBox
                .shrink(), // Do not display anything if imagePath is invalid
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(description),
                if (category != "ไม่มี")
                  Text(
                    "เมื่อเข้าร่วม จะได้รับ ${category} ${score} คะแนน",
                    style: const TextStyle(fontSize: 16),
                  ),
                const SizedBox(height: 8),
                Text("วันเวลากิจกรรม $datetime"),
                const SizedBox(height: 8),
                Text("สถานที่กิจกรรม $location"),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
