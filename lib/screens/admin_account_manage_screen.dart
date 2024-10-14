import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AdminAccountManageScreen extends StatefulWidget {
  @override
  _AdminAccountManageScreenState createState() =>
      _AdminAccountManageScreenState();
}

class _AdminAccountManageScreenState extends State<AdminAccountManageScreen> {
  final TextEditingController _idController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Map<String, String> accountData = {};
  bool isEditing = false;
  final String _baseUrl = "192.168.1.47";

  Future<void> loadAccount() async {
    var url = Uri.http(_baseUrl, '/flutter/getAccountManager.php');

    var response = await http.post(url, body: {
      "id": _idController.text,
    });

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      setState(() {
        accountData = {
          "ID": data['userID'],
          "EMAIL": data['email'],
          "ROLE": data['isAdmin'] == "1" ? "ADMIN" : "STUDENT",
          "StudentID": data['studentId'],
          "PhoneNumber": data['phoneNumber'],
          "password": '', // Ensure the password field is included
        };
      });
    } else {
      print("Failed to load account data");
    }
  }

  void editAccount() {
    setState(() {
      isEditing = true;
    });
  }

  void saveAccount() async {
    if (_formKey.currentState?.validate() ?? false) {
      final url = Uri.http(_baseUrl, '/flutter/editAccountManager.php');

      final response = await http.post(url, body: {
        "userID": accountData['ID'],
        "phone": accountData['PhoneNumber'],
        "email": accountData['EMAIL'],
        "password": accountData['password'] ??
            '', // Send empty string if password is null
        "studentId": accountData['StudentID'],
        "isAdmin": accountData['ROLE'] == 'ADMIN' ? '1' : '0',
      });

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);

        if (responseData['status'] == 'success') {
          setState(() {
            isEditing = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Account updated successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Failed to update account: ${responseData['message']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to connect to server')),
        );
      }
    }
  }

  void cancelEdit() {
    setState(() {
      isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Account'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey, // Use the form key for validation
              child: Column(
                children: [
                  TextFormField(
                    controller: _idController,
                    decoration:
                        InputDecoration(labelText: 'ID/PhoneNumber/StudentId'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'ID is required';
                      }
                      return null;
                    },
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        loadAccount();
                      }
                    },
                    child: Text('LOAD ACCOUNT BY ID/PhoneNumber/StudentId'),
                  ),
                ],
              ),
            ),
            if (accountData.isNotEmpty)
              Column(
                children: [
                  if (isEditing)
                    Column(
                      children: [
                        TextFormField(
                          initialValue: accountData['EMAIL'],
                          decoration: InputDecoration(labelText: 'Email'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email is required';
                            }
                            return null;
                          },
                          onChanged: (value) => accountData['EMAIL'] = value,
                        ),
                        DropdownButtonFormField<String>(
                          value: accountData['ROLE'],
                          items: ['ADMIN', 'STUDENT'].map((String role) {
                            return DropdownMenuItem<String>(
                              value: role,
                              child: Text(role),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              accountData['ROLE'] = value ?? 'STUDENT';
                            });
                          },
                          decoration: InputDecoration(labelText: 'Role'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Role is required';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          initialValue: accountData['password'],
                          decoration: InputDecoration(
                              labelText:
                                  'Password (Leave blank for no change)'),
                          onChanged: (value) => accountData['password'] = value,
                        ),
                        TextFormField(
                          initialValue: accountData['StudentID'],
                          decoration: InputDecoration(
                              labelText: 'StudentID / ManagerID / AdminID'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'StudentID is required';
                            }
                            return null;
                          },
                          onChanged: (value) =>
                              accountData['StudentID'] = value,
                        ),
                        TextFormField(
                          initialValue: accountData['PhoneNumber'],
                          decoration:
                              InputDecoration(labelText: 'Phone Number'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Phone Number is required';
                            }
                            return null;
                          },
                          onChanged: (value) =>
                              accountData['PhoneNumber'] = value,
                        ),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: saveAccount,
                              child: Text('SAVE'),
                            ),
                            SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: cancelEdit,
                              child: Text('CANCEL'),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red),
                            ),
                          ],
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        Text('ID: ${accountData['ID']}'),
                        Text('Email: ${accountData['EMAIL']}'),
                        Text('Role: ${accountData['ROLE']}'),
                        Text(
                            'StudentID / ManagerID / AdminID: ${accountData['StudentID']}'),
                        Text('Phone Number: ${accountData['PhoneNumber']}'),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: editAccount,
                              child: Text('EDIT'),
                            ),
                            SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  accountData.clear();
                                });
                              },
                              child: Text('CANCEL'),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red),
                            ),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
