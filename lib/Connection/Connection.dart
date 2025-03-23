/*import 'package:flutter/material.dart';
import 'package:multicast_dns/multicast_dns.dart'; // For local network discovery
import 'Select.dart';

class ConnectionScreen extends StatefulWidget {
  @override
  _ConnectionScreenState createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  final MDnsClient _mdnsClient = MDnsClient();
  List<String> _foundUsers = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _startDiscovery();
  }

  Future<void> _startDiscovery() async {
    setState(() {
      _isSearching = true;
      _foundUsers.clear();
    });

    await _mdnsClient.start();

    // Listen for service pointers to find services.
    await for (PtrResourceRecord ptr in _mdnsClient.lookupPtrRecords(
        ResourceRecordQuery.service(name: '_myapp._tcp'))) { // Use unique service name
      // Look up the SRV record to find the server's hostname and port.
      await for (SrvResourceRecord srv in _mdnsClient.lookupSrvRecords(
          ResourceRecordQuery.service(ptr.domainName))) {
        // Look up the A record to find the server's IP address.
        await for (ARecord a in _mdnsClient.lookupARecords(
            ResourceRecordQuery.addressIPv4(srv.target))) {
          setState(() {
            _foundUsers.add('${a.address}:${srv.port}'); // Store IP:Port
          });
        }
      }
    }
    setState(() {
      _isSearching = false;
    });
    _mdnsClient.stop();
  }

  @override
  void dispose() {
    _mdnsClient.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Connections')),
      body: _isSearching
          ? Center(child: CircularProgressIndicator())
          : _foundUsers.isEmpty
          ? Center(child: Text('No users found.'))
          : ListView.builder(
        itemCount: _foundUsers.length,
        itemBuilder: (context, index) {
          final user = _foundUsers[index];
          return ListTile(
            title: Text(user),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FileSelectionScreen(userAddress: user), //Pass the selected user address
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startDiscovery,
        child: Icon(Icons.refresh),
      ),
    );
  }
}*/