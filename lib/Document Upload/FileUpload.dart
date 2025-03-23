import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import 'Result.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? _selectedFile;
  bool _isPicking = false;
  bool _isHashing = false; // Track hashing state

  Future<void> _pickFile() async {
    setState(() {
      _isPicking = true;
    });
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
        });
      }
    } catch (e) {
      print("Error picking file: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking file: ${e.toString()}'),
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      setState(() {
        _isPicking = false;
      });
    }
  }

  Future<void> _hashFile() async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a file first.')),
      );
      return;
    }

    setState(() {
      _isHashing = true;
    });

    try {
      final bytes = await _selectedFile!.readAsBytes();
      final digest = sha256.convert(bytes);
      final hash = digest.toString();

      // Navigate to the next screen with the hash
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(hash: hash, fileHash: '',),
        ),
      );
    } catch (e) {
      print("Error hashing file: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error hashing file: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isHashing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A2027),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Stack(
              alignment: Alignment.center,
              children: [
                ElevatedButton(
                  onPressed: _isPicking ? null : _pickFile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF64B5F6),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                    shadowColor: const Color(0xFF64B5F6).withOpacity(0.4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Select File',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isPicking)
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 3,
                  ),
              ],
            ),
            const SizedBox(height: 30),
            if (_selectedFile != null)
              AnimatedPadding(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D3748),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF4A5568),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
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
                      const SizedBox(height: 12),
                      Text(
                        _selectedFile!.path,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),
            if (_selectedFile != null)
              Stack(
                  alignment: Alignment.center,
                  children:[
                    ElevatedButton(
                      onPressed: _isHashing ? null : _hashFile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50), // Green for hash
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                        shadowColor: const Color(0xFF4CAF50).withOpacity(0.4),
                      ),
                      child: const Text(
                        'Hash File',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if(_isHashing) const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white),strokeWidth: 3,)
                  ]
              ),
          ],
        ),
      ),
    );
  }
}

/*class HashResultScreen extends StatelessWidget {
  final String hash;

  const HashResultScreen({super.key, required this.hash});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A2027),
      appBar: AppBar(
        title: const Text('Hash Result', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2D3748),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SelectableText(
            hash,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}*/