import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'add_party_screen.dart';

class PartyListScreen extends StatefulWidget {
  @override
  _PartyListScreenState createState() => _PartyListScreenState();
}

class _PartyListScreenState extends State<PartyListScreen> {
  List<String> _partyList = [];

  @override
  void initState() {
    super.initState();
    _loadParties();
  }

  // Load saved parties from SharedPreferences
  _loadParties() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _partyList = prefs.getStringList('partyList') ?? [];
    });
  }

  // Add a new party to the list
  _addParty(String party) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _partyList.add(party);
    prefs.setStringList('partyList', _partyList);
    setState(() {});
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
              itemBuilder: (context, index) {
                final party = _partyList[index].split(', ');
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: ListTile(
                    title: Text(
                      party[0], // Party name
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(party[1]),  // Party description
                        Text('Date: ${party[2]}'),  // Party date
                      ],
                    ),
                    trailing: Icon(Icons.party_mode),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddPartyScreen(context),
        child: Icon(Icons.add),
        tooltip: 'Add Party',
      ),
    );
  }

  // Navigate to the AddPartyScreen
  _navigateToAddPartyScreen(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddPartyScreen()),
    );
    if (result != null) {
      _addParty(result);
    }
  }
}
