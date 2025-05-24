import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

class BookCard extends StatelessWidget {
  final String title;
  final String author;
  final String onDownloadPdf;
  final String onDownloadWord;
  final String bookId;

  const BookCard({
    super.key,
    required this.title,
    required this.author,
    required this.onDownloadPdf,
    required this.onDownloadWord,
    required this.bookId,
  });

  Future<void> _launchPDF(String url, String type) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/${bookId}${type}';
    final file = File(filePath);
    final String bookUrl = url;

    final bookResponse = await http.get(Uri.parse(bookUrl));
    if (bookResponse.statusCode == 200) {
      await file.writeAsBytes(bookResponse.bodyBytes);
    } else {
      throw HttpException("Failed to download");
    }
  }

  @override
  Widget build(BuildContext context) {
    globalContext = context; // set the global context for snackbars

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        leading: const Icon(Icons.menu_book, size: 40, color: Colors.indigo),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(author),
        trailing: SizedBox(
          width: 96,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
                tooltip: 'Download PDF',
                onPressed: () => _launchPDF(onDownloadPdf, ".pdf"),
              ),
              IconButton(
                icon: const Icon(Icons.description, color: Colors.blue),
                tooltip: 'Download Word',
                onPressed: () => _launchPDF(onDownloadWord, ".word"),
              ),
            ],
          ),
        ),
        onTap: () {
          // Optional: navigate to book detail page
        },
      ),
    );
  }
}

// To allow showing snackbars inside a stateless widget
BuildContext? globalContext;
