import 'package:flutter/material.dart';
import 'api_service.dart';

class ActivityListScreen extends StatefulWidget {
  @override
  _ActivityListScreenState createState() => _ActivityListScreenState();
}

class _ActivityListScreenState extends State<ActivityListScreen> {
  final ApiService apiService = ApiService();
  List<dynamic> activities = [];

  @override
  void initState() {
    super.initState();
    _fetchActivities();
  }

  void _fetchActivities() async {
    try {
      final response = await apiService.fetchActivities();
      setState(() {
        activities = response;
      });
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Activities')),
      body: ListView.builder(
        itemCount: activities.length,
        itemBuilder: (context, index) {
          final activity = activities[index];
          return ListTile(
            title: Text(activity['title']),
            subtitle: Text(activity['description']),
          );
        },
      ),
    );
  }
}
