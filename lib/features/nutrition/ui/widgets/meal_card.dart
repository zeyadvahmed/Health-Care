
import 'package:flutter/material.dart';

class MealCard extends StatelessWidget {
  String title;
  String recommended;
  String calories;
  List<Map<String, String>> foodItems;
  VoidCallback onAddFood;
  String imagePath;
  Color iconBgColor;
  MealCard({
    super.key,
    required this.title,
    required this.recommended,
    required this.calories,
    required this.foodItems,
    required this.onAddFood,
    required this.imagePath,
    required this.iconBgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Color.fromARGB(219, 218, 234, 249),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Row(
                spacing: 14,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Image.asset(
                        imagePath,
                        width: 24,
                        height: 24,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        Text(recommended, style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                  Text(
                    calories,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                spacing: 12,
                children: [
                  foodItems.isEmpty
                      ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                            'No food items added yet.',
                            style: TextStyle(color: Colors.black54),
                          ),
                      )
                      :
                  ListView.separated(
                    separatorBuilder: (context, index) => SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = foodItems[index];
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(item['name'] ?? ''),
                          Text(item['calories'] ?? ''),
                        ],
                      );
                    },
                    itemCount: foodItems.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                  ),
                  GestureDetector(
                    onTap: onAddFood,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Color(0xffDAEAF9),
                          style: BorderStyle.solid,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 15,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add, color: Color(0xff137FEC)),
                            SizedBox(width: 8),
                            Text(
                              'Add Food',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xff137FEC),
                                fontWeight: FontWeight.w600,
                              ),
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
        ],
      ),
    );
  }
}
