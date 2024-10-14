import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AdminAccountProvider extends ChangeNotifier {
  Map<String, String> accountData = {};
  bool isEditing = false;

  // Function to load account data from API
  Future<void> loadAccountData(String userId) async {
    final url = Uri.http(
        "192.168.1.47", '/flutter/get_account.php', {'userId': userId});
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        accountData = json.decode(response.body);
        notifyListeners();
      } else {
        throw Exception('Failed to load account data');
      }
    } catch (error) {
      throw Exception('Error loading account data: $error');
    }
  }

  // Start editing
  void startEdit() {
    isEditing = true;
    notifyListeners();
  }

  // Cancel editing
  void cancelEdit() {
    isEditing = false;
    notifyListeners();
  }

  // Clear account data
  void clearAccountData() {
    accountData.clear();
    notifyListeners();
  }

  // Function to save account data to API
  Future<void> saveAccountData(String userId) async {
    final url = Uri.http("192.168.1.47", '/flutter/update_account.php');
    try {
      final response = await http.post(url, body: {
        'userId': userId,
        ...accountData, // Assuming accountData contains the fields to be updated
      });
      if (response.statusCode == 200) {
        isEditing = false; // Stop editing after saving
        notifyListeners();
      } else {
        throw Exception('Failed to save account data');
      }
    } catch (error) {
      throw Exception('Error saving account data: $error');
    }
  }
}
