import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:untitled/Document%20Upload/encr.dart';

class ResultScreen extends StatelessWidget {
  final String? fileHash;
  final privatekey = private;
  final publickey = public;


  ResultScreen({super.key, required this.fileHash, required String hash});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
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
                      'SHA-256 Hash:',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                    /*Text(
                      privatekey as String,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      publickey as String,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),*/
                    const SizedBox(height: 8),
                    SelectableText(
                      fileHash ?? 'No hash calculated',
                      style: TextStyle(
                        color:
                            fileHash != null ? Colors.cyanAccent : Colors.grey,
                        fontSize: 14,
                        fontFamily: 'Courier New',
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.left,
                    )
                        .animate()
                        .fadeIn(duration: const Duration(milliseconds: 500)),
                  ],
                ),
              ).animate().slideY(
                  begin: 1,
                  end: 0,
                  duration: const Duration(milliseconds: 500)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Back',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
