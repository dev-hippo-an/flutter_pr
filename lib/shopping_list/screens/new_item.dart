import 'dart:convert';

import 'package:first_web/shopping_list/data/categories.dart';
import 'package:first_web/shopping_list/models/category.dart';
import 'package:first_web/shopping_list/models/grocery_item.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  final _formKey = GlobalKey<FormState>();
  var _enteredName = '';
  var _enteredQuantity = 1;
  var _selectedCategory = categories[Categories.vegetables]!;
  var _isSending = false;

  void _saveItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isSending = true;
      });
      try {
        final url = Uri.https('', 'items.json');

        final response = await http.post(url,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'name': _enteredName,
              'quantity': _enteredQuantity,
              'category': _selectedCategory.title,
            }));

        if (mounted && response.statusCode == 200) {
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          Navigator.of(context).pop(
            GroceryItem(
                id: responseData['name'],
                name: _enteredName,
                quantity: _enteredQuantity,
                category: _selectedCategory),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            duration: Duration(seconds: 1),
            content: Text('Error occurred...Try again later.'),
          ),
        );
      } finally {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a new item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                maxLength: 50,
                decoration: const InputDecoration(
                  label: Text('Name'),
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1 ||
                      value.trim().length > 50) {
                    return 'Name is must be between 1 and 50 characters!';
                  }
                  return null;
                },
                onSaved: (value) {
                  _enteredName = value!;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      initialValue: _enteredQuantity.toString(),
                      decoration: const InputDecoration(
                        label: Text('Quantity'),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0) {
                          return 'Quantity must be valid positive number!';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _enteredQuantity = int.parse(value!);
                      },
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: DropdownButtonFormField(
                      value: _selectedCategory,
                      items: [
                        for (final category in categories.entries)
                          DropdownMenuItem(
                            value: category.value,
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  color: category.value.color,
                                ),
                                const SizedBox(
                                  width: 6,
                                ),
                                Text(category.value.title),
                              ],
                            ),
                          )
                      ],
                      onChanged: (category) {
                        _selectedCategory = category!;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSending
                        ? null
                        : () {
                            _formKey.currentState!.reset();
                          },
                    child: const Text('Reset'),
                  ),
                  ElevatedButton(
                    onPressed: _isSending ? null : _saveItem,
                    child: _isSending
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(),
                          )
                        : const Text(
                            'Add Item',
                          ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
