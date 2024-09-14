import 'package:flutter/material.dart';
import 'add_party_screen.dart'; // For navigating to add/edit party form
import 'database_helper.dart'; // For database operations

class PartyListScreen extends StatefulWidget {
  @override
  _PartyListScreenState createState() => _PartyListScreenState();
}

class _PartyListScreenState extends State<PartyListScreen> {
  List<Map<String, dynamic>> _partyList = []; // To hold the list of parties

  @override
  void initState() {
    super.initState();
    _refreshPartyList(); // Fetch and display party list
  }

  void _refreshPartyList() async {
    final data = await DatabaseHelper.instance.getParties(); // Fetch parties from DB
    setState(() {
      _partyList = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Party Planner'),
      ),
      body: _partyList.isEmpty
          ? Center(child: Text('No parties yet. Add one!'))
          : ListView.builder(
              itemCount: _partyList.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(_partyList[index]['name']),
                subtitle: Text(_partyList[index]['date']),
                onTap: () {
                  // Navigate to the Edit Party Screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddPartyScreen(party: _partyList[index]),
                    ),
                  ).then((_) => _refreshPartyList()); // Refresh list after edit
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to Add Party Screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddPartyScreen()),
          ).then((_) => _refreshPartyList()); // Refresh list after adding party
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
