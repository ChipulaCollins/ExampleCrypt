import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'Result.dart';

class Upload extends StatefulWidget {
  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  File? _selectedFile;
  String? _fileHash;
  bool _isProcessing = false;

  Future<void> _pickAndHashFile() async {
    setState(() {
      _isProcessing = true;
      _fileHash = null;
    });

    try {
      final result = await FilePicker.platform.pickFiles();
      if (result != null) {
        _selectedFile = File(result.files.single.path!);
        final fileBytes = await _selectedFile!.readAsBytes();
        final digest = sha256.convert(fileBytes);
        _fileHash = digest.toString();
      }
    } catch (e) {
      print("Error picking/hashing file: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          duration: const Duration(seconds: 5),
        ),
      );
      _fileHash = null;
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('File Upload and Hash'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ElevatedButton(
                onPressed: _isProcessing ? null : _pickAndHashFile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007BFF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 8,
                  shadowColor: const Color(0xFF007BFF).withOpacity(0.4),
                ),
                child: _isProcessing
                    ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3,
                )
                    : const Text(
                  'Select and Hash File',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ).animate().scale(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
              const SizedBox(height: 30),
              if (_selectedFile != null)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF333333),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selected File:',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedFile!.path.split('/').last,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'SHA-256 Hash:',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SelectableText(
                        _fileHash ?? 'No hash calculated',
                        style: TextStyle(
                          color: _fileHash != null ? Colors.cyanAccent : Colors.grey,
                          fontSize: 14,
                          fontFamily: 'Courier New',
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.left,
                      ).animate().fadeIn(duration: const Duration(milliseconds: 500)),
                      const SizedBox(height: 20),
                      if (_fileHash != null)
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ResultScreen(fileHash: _fileHash!),
                              ),
                            );
                          },
                          child: const Text('Copy to Result Screen'),
                        ),
                    ],
                  ),
                ).animate().slideY(begin: 1, end: 0, duration: const Duration(milliseconds: 500)),
            ],
          ),
        ),
      ),
    );
  }
}