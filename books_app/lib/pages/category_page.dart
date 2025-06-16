import 'package:flutter/material.dart';
import '../widgets/category_card.dart';
import 'book_list_page.dart';
import 'upload_page.dart';

class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = ["Age 0-4", "Age 4-8", "Age 8-12"];

    return Scaffold(
      appBar: AppBar(title: const Text("Choose Category")),
      body: ListView(
        children: [
          ...categories.map(
            (cat) => CategoryCard(
              title: cat,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BookListPage(category: cat),
                  ),
                );
              },
            ),
          ),
          CategoryCard(
            title: "📤 Upload a Book",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UploadPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
