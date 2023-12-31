import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:first_web/chat_app/widgets/user_image_picker.dart';
import 'package:flutter/material.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  var _email = '';
  var _username = '';
  var _password = '';
  File? /**/ _selectedImage;

  var _isLogin = true;
  var _isSaving = false;

  String? _emailValidator(String? value) {
    if (value == null ||
        value.trim().length < 3 ||
        value.contains('@') == false) {
      return 'Please enter valid email address.';
    }
    return null;
  }

  String? _usernameValidator(String? value) {
    if (_isLogin == true) {
      return null;
    }

    if (value == null || value.trim().length < 4) {
      return 'Please enter valid username. Minimum 4 chars.';
    }
    return null;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.trim().length < 8) {
      return 'Password is too short. Please enter more than 8 chars.';
    }
    return null;
  }

  bool _selectedImageValidate() => _selectedImage != null;

  void _submit() async {
    setState(() {
      _isSaving = true;
    });

    if (_isLogin == false && _selectedImageValidate() == false) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image should selected!'),
        ),
      );
      setState(() {
        _isSaving = false;
      });
      return;
    }

    final valid = _formKey.currentState?.validate() ?? false;

    if (valid == false) {
      setState(() {
        _isSaving = false;
      });
      return;
    }
    _formKey.currentState?.save();

    try {
      if (_isLogin == true) {
        await _firebase.signInWithEmailAndPassword(
            email: _email, password: _password);
      } else {
        final userCredential = await _firebase.createUserWithEmailAndPassword(
            email: _email, password: _password);

        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${userCredential.user!.uid}.jpg');

        await storageRef.putFile(_selectedImage!);
        final imageUrl = await storageRef.getDownloadURL();

        FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(
          {
            'username': _username,
            'email': userCredential.user!.email,
            'image_url': imageUrl,
          },
        );
      }
    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message ?? 'Authentication failed.')),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  top: 30,
                  left: 20,
                  right: 20,
                  bottom: 20,
                ),
                width: 200,
                child: Image.asset('assets/images/chat.png'),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isLogin == false)
                          UserImagePicker(
                            onPickImage: (File? file) {
                              _selectedImage = file;
                            },
                          ),
                        TextFormField(
                          decoration: const InputDecoration(labelText: 'Email'),
                          autocorrect: false,
                          maxLength: 50,
                          keyboardType: TextInputType.emailAddress,
                          textCapitalization: TextCapitalization.none,
                          enableSuggestions: false,
                          validator: _emailValidator,
                          onSaved: (value) {
                            _email = value!;
                          },
                        ),
                        if(_isLogin == false)
                          TextFormField(
                          decoration:
                              const InputDecoration(labelText: 'Username'),
                          autocorrect: false,
                          maxLength: 50,
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.none,
                          enableSuggestions: false,
                          validator: _usernameValidator,
                          onSaved: (value) {
                            _username = value!;
                          },
                        ),
                        TextFormField(
                          decoration:
                              const InputDecoration(labelText: 'Password'),
                          obscureText: true,
                          validator: _passwordValidator,
                          onSaved: (value) {
                            _password = value!;
                          },
                        ),
                        const SizedBox(height: 16.0),
                        if (_isSaving == true)
                          SizedBox(
                            height: 20,
                            width: 20,
                            child: Center(
                              child: CircularProgressIndicator(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                              ),
                            ),
                          ),
                        if (_isSaving == false)
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                ),
                                onPressed: _submit,
                                child: Text(
                                  _isLogin ? 'Login' : 'Sign Up',
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isLogin = !_isLogin;
                                    _formKey.currentState?.reset();
                                  });
                                },
                                child: Text(_isLogin
                                    ? 'Create an account.'
                                    : 'I already have an account.'),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
