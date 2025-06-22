import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/book_card.dart';

class BookListPage extends StatelessWidget {
  final String category;

  const BookListPage({super.key, required this.category});

  Future<List<Map<String, dynamic>>> fetchBooks(String category) async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('Books')
            .where('category', isEqualTo: category)
            .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id; // Add the document ID to the data
      return data;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Books for $category")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchBooks(category),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            print(snapshot.error);
            return const Center(child: Text("Error loading books"));
          }

          final books = snapshot.data ?? [];

          if (books.isEmpty) {
            return const Center(child: Text("No books found."));
          }

          return ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return BookCard(
                bookId: book['id'], // Use the Firestore document ID
                title: book['title'] ?? 'No Title',
                author: book['author'] ?? 'Unknown',
                onDownloadPdf: book['pdf_url'] ?? '',
                onDownloadWord: book['word_url'] ?? '',
              );
            },
          );
        },
      ),
    );
  }
}
