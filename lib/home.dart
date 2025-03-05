import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  final CollectionReference _items = FirebaseFirestore.instance.collection('items');

  Future<void> _addItem() async {
    if (_controller.text.isNotEmpty) {
      await _items.add({'name': _controller.text});
      _controller.clear();
    }
  }

  Future<void> _updateItem(String id, String newName) async {
    await _items.doc(id).update({'name': newName});
  }

  Future<void> _deleteItem(String id) async {
    await _items.doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Flutter Firebase Demo')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: 'Enter item name'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addItem,
              child: Text('Add Item'),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _items.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Something went wrong');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }

                  final data = snapshot.requireData;

                  return ListView.builder(
                    itemCount: data.size,
                    itemBuilder: (context, index) {
                      final item = data.docs[index];
                      final itemName = item['name'];
                      return ListTile(
                        title: Text(itemName),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                _controller.text = itemName;
                                _updateItem(item.id, _controller.text);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _deleteItem(item.id),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
