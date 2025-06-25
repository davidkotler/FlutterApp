import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class BookCard extends StatelessWidget {
  final String title;
  final String author;
  final String onDownloadPdf;
  final String onDownloadWord;
  final String bookId;

  // ValueNotifier to track loading state
  final ValueNotifier<bool> _isDownloading = ValueNotifier(false);

  BookCard({
    super.key,
    required this.title,
    required this.author,
    required this.onDownloadPdf,
    required this.onDownloadWord,
    required this.bookId,
  });

  Future<void> _downloadFile({
    required BuildContext context,
    required String url,
    required String fileName,
    required String extension,
  }) async {
    try {
      _isDownloading.value = true;
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName$extension';
      final file = File(filePath);
      print('URL is: $url');
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('✅ File saved to $filePath')));
        }
        await OpenFile.open(file.path);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to download file. Status: ${response.statusCode}',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('❗ Error: $e')));
      }
    } finally {
      _isDownloading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isDownloading,
      builder: (context, isDownloading, child) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            leading: const Icon(
              Icons.menu_book,
              size: 40,
              color: Colors.indigo,
            ),
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(author),
            trailing:
                isDownloading
                    ? const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                    : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.picture_as_pdf,
                            color: Colors.red,
                          ),
                          tooltip: 'Download PDF',
                          onPressed:
                              () => _downloadFile(
                                context: context,
                                url: onDownloadPdf,
                                fileName: '$bookId-pdf',
                                extension: '.pdf',
                              ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.description,
                            color: Colors.blue,
                          ),
                          tooltip: 'Download Word',
                          onPressed:
                              () => _downloadFile(
                                context: context,
                                url: onDownloadWord,
                                fileName: '$bookId-word',
                                extension: '.docx',
                              ),
                        ),
                      ],
                    ),
          ),
        );
      },
    );
  }
}
