import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_animate/flutter_animate.dart'; // Import the flutter_animate package

class Upload extends StatefulWidget {
  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  File? _selectedFile;
  String? _fileHash;
  bool _isProcessing =
  false; // Track if file picking/hashing is in progress

  Future<void> _pickAndHashFile() async {
    setState(() {
      _isProcessing =
      true; // Set processing to true before starting file picking
      _fileHash =
      null; // Clear previous hash.  Good practice and good for UI feedback.
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
      _fileHash = null; // ensure null on error
    } finally {
      setState(() {
        _isProcessing =
        false; // Set processing to false after completing file picking/hashing
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Dark background
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Use Animate to add an animation to the button
              ElevatedButton(
                onPressed: _isProcessing ? null : _pickAndHashFile,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(0xFF007BFF), // A brighter button color
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30, vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 8, // Add a subtle shadow
                  shadowColor:
                  const Color(0xFF007BFF).withOpacity(0.4), // Shadow color
                ),
                child: _isProcessing
                    ? const CircularProgressIndicator(
                  valueColor:
                  AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3,
                )
                    : const Text(
                  'Select and Hash File',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ).animate().scale(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut), // Add scale animation

              const SizedBox(height: 30),

              // Show file name and hash
              if (_selectedFile != null)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E), // Darker container
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF333333), // Darker border
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
                        // show only the file name
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
                          color: _fileHash != null
                              ? Colors.cyanAccent
                              : Colors.grey, // Highlight the hash
                          fontSize: 14,
                          fontFamily: 'Courier New',
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.left,
                      ).animate().fadeIn(
                          duration: const Duration(
                              milliseconds:
                              500)), // Add fade-in to the hash
                    ],
                  ),
                ).animate().slideY(
                    begin: 1,
                    end: 0,
                    duration: const Duration(
                        milliseconds:
                        500)), // Add slide-in animation for the container
            ],
          ),
        ),
      ),
    );
  }
}

