import 'package:flutter/material.dart';
import 'category_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '📚 Welcome to BookApp',
              style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
            ),
             Image.network(
              'https://img.freepik.com/free-vector/hand-drawn-flat-design-stack-books-illustration_23-2149341898.jpg?semt=ais_items_boosted&w=740',
              height: 400,
              width: 350,
              fit: BoxFit.cover,
            ),
            
            const SizedBox(height: 10),
            SizedBox(
              width: 250,
              height: 50,
              child: ElevatedButton(
                child: const Text(
                  "Get Started",
                  style: TextStyle(fontSize: 28),                
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CategoryPage()),
                );
              },
            ),
        ),
          ],
        ),
      ),
    );
  }
}
