import 'package:first_web/meal_road/data/dummy_data.dart';
import 'package:first_web/meal_road/models/category.dart';
import 'package:first_web/meal_road/screens/meals_screen.dart';
import 'package:first_web/meal_road/widgets/category_grid_item.dart';
import 'package:flutter/material.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  void _selectCategory(BuildContext context, Category category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            MealsScreen(
              title: category.title,
              meals: dummyMeals
                  .where((element) => element.categories.contains(category.id))
                  .toList(),
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const category = availableCategories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick your category'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3 / 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
        ),
        itemCount: category.length,
        itemBuilder: (context, index) {
          final selectedCategory = category[index];
          return CategoryGridItem(
              category: selectedCategory,
              onSelectCategory: () {
                _selectCategory(context, selectedCategory);
              },
            );
        },
      ),
    );
  }
}