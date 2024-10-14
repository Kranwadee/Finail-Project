import 'package:flutter/material.dart';
import 'add_activity_screen.dart'; // Import your AddActivityScreen
import 'dart:convert';
import 'package:http/http.dart'
    as http; // Import http package for making requests

class ActivityDetailsArguments {
  final String userId;
  final String activityId;
  final String title;
  final String imagePath;
  final String description;
  final bool isJoinable;
  final String category;
  final String score;
  final String datetime;
  final String location;

  ActivityDetailsArguments({
    required this.userId,
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
}

class ActivityDetailsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ActivityDetailsArguments args =
        ModalRoute.of(context)!.settings.arguments as ActivityDetailsArguments;

    return Scaffold(
      appBar: AppBar(
        title: Text(args.title),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddActivityScreen(
                    activityId: args.activityId,
                    title: args.title,
                    description: args.description,
                    imagePath: args.imagePath,
                    isJoinable: args.isJoinable,
                    category: args.category,
                    score: args.score,
                    datetime: args.datetime,
                    location: args.location,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          Image.network(
            args.imagePath,
            fit: BoxFit.cover,
            width: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[300],
                child: const Center(child: Text('Image not found')),
              );
            },
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  args.title,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  args.description,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  "วันเวลา เริ่มกิจกรรม : ${args.datetime}",
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  "สถานที่จัดกิจกรรม : ${args.location}",
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                if (args.category != "ไม่มี")
                  Text(
                    "เมื่อเข้าร่วม จะได้รับ ${args.category} ${args.score} คะแนน",
                    style: const TextStyle(fontSize: 16),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (args.isJoinable)
            Center(
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Join/Register'),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {}, // _deleteActivity,
        child: const Icon(Icons.delete),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
