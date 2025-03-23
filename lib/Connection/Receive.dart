import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart'; // For saving files

class ReceivingScreen extends StatefulWidget {
  final int port;

  ReceivingScreen({required this.port});

  @override
  _ReceivingScreenState createState() => _ReceivingScreenState();
}

class _ReceivingScreenState extends State<ReceivingScreen> {
  double _progress = 0.0;
  String _status = 'Waiting for file...';
  String _filePath = '';
  ServerSocket? _serverSocket;
  int _fileSize = 0;
  int _bytesReceived = 0;
  Uint8List _fileData = Uint8List(0); // Store received data

  @override
  void initState() {
    super.initState();
    _startReceiving();
  }

  Future<void> _startReceiving() async {
    try {
      _serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, widget.port);
      _serverSocket?.listen((Socket client) {
        _handleClient(client);
      });
      setState(() {
        _status = 'Listening on port ${widget.port}';
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
    }
  }

  Future<void> _handleClient(Socket client) async {
    try {
      client.listen((List<int> data) {
        _fileData = Uint8List.fromList([..._fileData, ...data]);
        _bytesReceived += data.length;

        if (_fileSize == 0) { // First chunk contains file size.
          _fileSize = data.length; //Assumes that the first chunk is the file size.
        }

        setState(() {
          _progress = _bytesReceived / _fileSize;
          _status = 'Receiving... (${(_progress * 100).toStringAsFixed(2)}%)';
        });

        if (_bytesReceived >= _fileSize) {
          _saveFile();
          client.close();
        }
      });
    } catch (e) {
      setState(() {
        _status = 'Error receiving data: $e';
      });
      client.close();
    }
  }

  Future<void> _saveFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/received_file'; // or generate unique name
      final file = File(filePath);
      await file.writeAsBytes(_fileData);
      setState(() {
        _filePath = filePath;
        _status = 'File saved to: $filePath';
      });
    } catch (e) {
      setState(() {
        _status = 'Error saving file: $e';
      });
    }
  }

  @override
  void dispose() {
    _serverSocket?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Receiving File')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(_status),
            SizedBox(height: 20),
            LinearProgressIndicator(value: _progress),
            SizedBox(height: 20),
            if (_filePath.isNotEmpty) Text('Saved to: $_filePath'),
          ],
        ),
      ),
    );
  }
}