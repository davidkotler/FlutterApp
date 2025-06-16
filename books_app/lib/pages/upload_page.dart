import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _author = '';
  String _category = 'age 6-10';
  PlatformFile? _pdfFile;
  PlatformFile? _wordFile;
  bool _isUploading = false;

  Future<void> _pickPdfFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      setState(() {
        _pdfFile = result.files.first;
      });
    }
  }

  Future<void> _pickWordFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['doc', 'docx'],
    );
    if (result != null) {
      setState(() {
        _wordFile = result.files.first;
      });
    }
  }

  Future<String?> _uploadFileToSupabase(String path, PlatformFile file) async {
    try {
      final supabase = Supabase.instance.client;
      final bookFileBytes = file.bytes!;
      // Upload file bytes
      final response = await supabase.storage
          .from('books') // your storage bucket name
          .uploadBinary(path, bookFileBytes);
      fileOptions:
      const FileOptions(upsert: true);

      // // Get public URL
      // final publicUrl = supabase.storage.from('books').getPublicUrl(path).data;
      // return publicUrl;
    } catch (e) {
      print('Upload error: $e');
      return null;
    }
    return null;
  }

  Future<void> _uploadBook() async {
    if (_pdfFile == null && _wordFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one file')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    final id = DateTime.now().millisecondsSinceEpoch.toString();

    String? pdfUrl;
    String? wordUrl;

    if (_pdfFile != null) {
      pdfUrl = await _uploadFileToSupabase(
        'books/$id/${_pdfFile!.name}',
        _pdfFile!,
      );
      if (pdfUrl == null) {
        _showError('Failed to upload PDF file');
        setState(() => _isUploading = false);
        return;
      }
    }

    if (_wordFile != null) {
      wordUrl = await _uploadFileToSupabase(
        'books/$id/${_wordFile!.name}',
        _wordFile!,
      );
      if (wordUrl == null) {
        _showError('Failed to upload Word file');
        setState(() => _isUploading = false);
        return;
      }
    }

    // Save metadata to Firestore
    await FirebaseFirestore.instance.collection('Books').doc(id).set({
      'title': _title,
      'author': _author,
      'category': _category,
      'pdf_url': pdfUrl ?? '',
      'word_url': wordUrl ?? '',
      'uploaded_at': Timestamp.now(),
    });

    setState(() {
      _isUploading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Book uploaded successfully!')),
    );

    Navigator.pop(context);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Book")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Title'),
                onSaved: (val) => _title = val ?? '',
                validator:
                    (val) => val == null || val.isEmpty ? 'Enter title' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Author'),
                onSaved: (val) => _author = val ?? '',
                validator:
                    (val) => val == null || val.isEmpty ? 'Enter author' : null,
              ),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items:
                    ['age 6-10', 'age 10-15']
                        .map(
                          (category) => DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          ),
                        )
                        .toList(),
                onChanged:
                    (value) => setState(() {
                      _category = value!;
                    }),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.picture_as_pdf),
                label: Text(
                  _pdfFile != null ? "PDF: ${_pdfFile!.name}" : "Upload PDF",
                ),
                onPressed: _pickPdfFile,
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.description),
                label: Text(
                  _wordFile != null
                      ? "Word: ${_wordFile!.name}"
                      : "Upload Word",
                ),
                onPressed: _pickWordFile,
              ),
              const SizedBox(height: 20),
              _isUploading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                    child: const Text("Upload"),
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        _formKey.currentState?.save();
                        _uploadBook();
                      }
                    },
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
