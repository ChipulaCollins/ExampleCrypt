import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart'; // For file selection
import 'Transfer.dart';

class FileSelectionScreen extends StatefulWidget {
  final String userAddress;

  FileSelectionScreen({required this.userAddress});

  @override
  _FileSelectionScreenState createState() => _FileSelectionScreenState();
}

class _FileSelectionScreenState extends State<FileSelectionScreen> {
  String? _filePath;
  String? _fileName;

  Future<void> _selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        _filePath = result.files.single.path;
        _fileName = result.files.single.name;
      });
    } else {
      // User canceled the picker
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select File')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Select a file to send to: ${widget.userAddress}'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _selectFile,
              child: Text('Choose File'),
            ),
            SizedBox(height: 10),
            if (_fileName != null) Text('Selected File: $_fileName'),
            SizedBox(height: 20),
            if (_filePath != null)
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TransferScreen(
                        filePath: _filePath!,
                        userAddress: widget.userAddress,
                      ),
                    ),
                  );
                },
                child: Text('Send File'),
              ),
          ],
        ),
      ),
    );
  }
}