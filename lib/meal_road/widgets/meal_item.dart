import 'package:first_web/meal_road/models/meal.dart';
import 'package:first_web/meal_road/widgets/meal_item_trait.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

class MealItem extends StatelessWidget {
  final Meal meal;
  final void Function (Meal) onMealSelect;

  const MealItem({
    super.key,
    required this.meal,
    required this.onMealSelect,
  });

  String makeFirstLetterToUpperCase(String value) {
    return value[0].toUpperCase() + value.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      clipBehavior: Clip.hardEdge,
      // 경계 밖으로 나가는 컨텐츠에 대해 자른다.
      elevation: 15.0,
      // 3d 효과로 z 축으로 나오도록 한다.
      child: InkWell(
        onTap: () {
          onMealSelect(meal);
        },
        child: Stack(
          // z 축으로 위젯을 쌓도록 도와주는 위젯
          children: [
            FadeInImage(
              // image fade in 효과
              placeholder: MemoryImage(kTransparentImage),
              image: NetworkImage(meal.imageUrl),
              fit: BoxFit.cover,
              height: 200,
              width: double.infinity,
            ),
            Positioned(
              // 특정 위치에 위치 시키는 위젯
              bottom: 0,
              right: 0,
              left: 0,
              child: Container(
                color: Colors.black54,
                padding: const EdgeInsets.symmetric(
                  vertical: 6,
                  horizontal: 44,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      meal.title,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      // 긴 문장에 대해 ... 으로 치환 ...
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MealItemTrait(
                          icon: Icons.schedule,
                          label: '${meal.duration} mins',
                        ),
                        const SizedBox(width: 12),
                        MealItemTrait(
                          icon: Icons.work,
                          label:
                              makeFirstLetterToUpperCase(meal.complexity.name),
                        ),
                        const SizedBox(width: 12),
                        MealItemTrait(
                          icon: Icons.attach_money,
                          label: makeFirstLetterToUpperCase(
                              meal.affordability.name),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
