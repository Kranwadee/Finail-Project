import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';

class ActivityProvider with ChangeNotifier {
  String _baseUrl = "www.local.com";

  // ตัวแปรที่ใช้ในการเก็บข้อมูลบัญชี
  Map<String, String> accountData = {};

  Future<void> updateActivity(Map<String, dynamic> result) async {
    try {
      var url = Uri.http(_baseUrl, '/flutter/addActivity.php');

      var response = await http.post(
        url,
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {
          "id": result['activityId']?.toString() ?? '',
          "title": result['title'] ?? 'Null',
          "imagePath": result['imagePath'] ?? 'Null',
          "description": result['description'] ?? 'Null',
          "scoreType": result['category'] ?? 'Null',
          "score": result['score']?.toString() ?? '0',
          "location": result['location']?.toString() ?? '0',
          "datetime": result['datetime']?.toString() ?? '0',
          "isJoinable": result['isJoinable']?.toString() ?? '0',
        },
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['status'] == 'success') {
          Fluttertoast.showToast(
            backgroundColor: Colors.green,
            textColor: Colors.white,
            msg: 'Activity updated successfully',
            toastLength: Toast.LENGTH_SHORT,
          );
          notifyListeners();
        } else {
          _showErrorToast(data['message']);
        }
      } else {
        _showErrorToast('Failed to update activity');
      }
    } catch (e) {
      print('Error: $e');
      _showErrorToast('An error occurred. Please try again.');
    }
  }

  Future<void> deleteActivity(String activityId) async {
    try {
      var url = Uri.http(_baseUrl, '/flutter/delActivity.php');

      var response = await http.post(
        url,
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {"id": activityId},
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['status'] == 'success') {
          Fluttertoast.showToast(
            backgroundColor: Colors.green,
            textColor: Colors.white,
            msg: 'Activity deleted successfully',
            toastLength: Toast.LENGTH_SHORT,
          );
          notifyListeners(); // Update UI listeners
        } else {
          _showErrorToast(data['message']);
        }
      } else {
        _showErrorToast('Failed to delete activity');
      }
    } catch (e) {
      print('Error: $e');
      _showErrorToast('An error occurred. Please try again.');
    }
  }

  Future<void> addUserActivity(
      BuildContext context, String userId, String activityId) async {
    var url = Uri.http(_baseUrl, '/flutter/userJoinActivity.php');
    var response = await http.post(url, body: {
      'userId': userId,
      'activityId': activityId,
    });

    var responseData = json.decode(response.body);
    if (responseData['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Joined activity successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Error joining activity: ${responseData['message']}')),
      );
    }
  }

  Future<void> loadAccount(String id) async {
    var url = Uri.http(_baseUrl, '/flutter/getAccountManager.php');
    var response = await http.post(url, body: {
      "id": id,
    });

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      accountData = {
        "ID": data['userID'],
        "EMAIL": data['email'],
        "ROLE": data['isAdmin'] == "1" ? "ADMIN" : "STUDENT",
        "StudentID": data['studentId'],
        "PhoneNumber": data['phoneNumber'],
        "password": '', // Ensure the password field is included
      };
      notifyListeners();
    } else {
      throw Exception("Failed to load account data");
    }
  }

  Future<void> saveAccount() async {
    var url = Uri.parse("http://192.168.1.47/flutter/editAccountManager.php");

    var response = await http.post(url, body: {
      "userID": accountData['ID'],
      "phone": accountData['PhoneNumber'],
      "email": accountData['EMAIL'],
      "password": accountData['password'] ?? '',
      "studentId": accountData['StudentID'],
      "isAdmin": accountData['ROLE'] == 'ADMIN' ? '1' : '0',
    });

    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);

      if (responseData['status'] == 'success') {
        notifyListeners();
      } else {
        throw Exception('Failed to update account: ${responseData['message']}');
      }
    } else {
      throw Exception('Failed to connect to server');
    }
  }

  void _showErrorToast(String message) {
    Fluttertoast.showToast(
      backgroundColor: Colors.red,
      textColor: Colors.white,
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
    );
  }

  Future<void> getAccount(String userID) async {
    try {
      var url = Uri.http(_baseUrl, '/flutter/getAccount.php');
      var response = await http.post(url, body: {
        "userID": userID,
      });

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['status'] == 'success') {
          accountData = {
            "StudentID": data['studentId'],
            "isAdmin": data['isAdmin'],
            "PhoneNumber": data['phoneNumber'],
            "Email": data['email'],
            "UserId": data['userId'],
          };
          notifyListeners();
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
}
