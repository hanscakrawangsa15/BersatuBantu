import 'dart:convert' show base64Encode;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

typedef OnFilePicked = void Function(String? filePath, String? base64Bytes, String fileName);

class FileUploadWidget extends StatefulWidget {
  final OnFilePicked onPicked;
  final String label;
  final String fileType; // 'akta', 'npwp', 'other'

  const FileUploadWidget({
    super.key,
    required this.onPicked,
    required this.fileType,
    this.label = 'Choose proof file',
  });

  @override
  State<FileUploadWidget> createState() => _FileUploadWidgetState();
}

class _FileUploadWidgetState extends State<FileUploadWidget> {
  String? selectedFileName;

  Future<void> pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.single;
        setState(() => selectedFileName = file.name);

        if (kIsWeb) {
          // Web: get bytes and encode as base64
          if (file.bytes != null) {
            final base64 = base64Encode(file.bytes!);
            widget.onPicked(null, base64, file.name);
          }
        } else {
          // Mobile: use file path
          if (file.path != null) {
            widget.onPicked(file.path, null, file.name);
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (selectedFileName != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Chip(
              label: Text(selectedFileName!),
              onDeleted: () => setState(() => selectedFileName = null),
            ),
          ),
        ElevatedButton.icon(
          onPressed: pickFile,
          icon: const Icon(Icons.upload_file),
          label: Text(widget.label),
        ),
      ],
    );
  }
}
