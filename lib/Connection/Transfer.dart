import 'package:flutter/material.dart';
import 'dart:io'; // For file operations
import 'dart:convert'; //for encoding.

class TransferScreen extends StatefulWidget {
  final String filePath;
  final String userAddress;

  TransferScreen({required this.filePath, required this.userAddress});

  @override
  _TransferScreenState createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  double _progress = 0.0;
  String _status = 'Connecting...';

  @override
  void initState() {
    super.initState();
    _sendFile();
  }

  Future<void> _sendFile() async {
    try {
      final parts = widget.userAddress.split(':');
      final ip = parts[0];
      final port = int.parse(parts[1]);

      final socket = await Socket.connect(ip, port);
      setState(() {
        _status = 'Connected';
      });

      final file = File(widget.filePath);
      final fileSize = await file.length();
      final stream = file.openRead();

      int bytesSent = 0;

      await for (final chunk in stream) {
        socket.add(chunk);
        bytesSent += chunk.length;
        setState(() {
          _progress = bytesSent / fileSize;
          _status = 'Sending... (${(_progress * 100).toStringAsFixed(2)}%)';
        });
      }

      await socket.flush();
      await socket.close();

      setState(() {
        _status = 'File sent successfully!';
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('File Transfer')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(_status),
            SizedBox(height: 20),
            LinearProgressIndicator(value: _progress),
          ],
        ),
      ),
    );
  }
}