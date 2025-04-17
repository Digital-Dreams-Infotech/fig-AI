import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../API/API.dart';

class Dailogbox extends StatefulWidget {
  const Dailogbox({super.key});

  @override
  State<Dailogbox> createState() => _DailogboxState();
}

class _DailogboxState extends State<Dailogbox> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _indexController = TextEditingController();
  final authservice = AuthService();
  bool _isLoading = false;

  String? userName;
  String? userProfile;
  String? token;
  String? userId;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadUserToken();
  }

  void loadUserToken() async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      token = pref.getString("access_token");
      userId = pref.getString("userId");
    });
    print("TOKEN: $token");
  }

  Future<void> addCategory() async {

    setState(() {
      _isLoading = true;
    });

    try {
      final res = await authservice.createPromptCategory(
        token!,
        _nameController.text,
        _indexController.text,
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        print('Category created successfully');
        print('ddd${res.body}');
        Navigator.of(context).pop(); // Close dialog
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('✅ Category created')));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('❌ Failed to create category')));
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('🚨 Error: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.1,
        height: MediaQuery.of(context).size.height * 0.2,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Category Name'),
                ),
                TextField(
                  controller: _indexController,
                  decoration: InputDecoration(labelText: 'Index'),
                ),
                TextButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      // Get the data from the controllers
                      String name = _nameController.text.trim();
                      String index = _indexController.text.trim();

                      print('Name: $name');
                      print('index: $index');
                      addCategory();
                      // authservice.createPromptCategory(authservice.getToken().toString(), name, index);
                      Navigator.of(context).pop();
                    } else {
                      // If validation fails, show a message or handle it
                      print('Form is not valid');
                    }
                  },
                  child: Text('Create'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
