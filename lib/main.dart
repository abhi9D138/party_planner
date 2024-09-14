import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:contacts_service/contacts_service.dart'; // For phone contact access
import 'package:url_launcher/url_launcher.dart'; // For sending invitations via mail
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

  // Edit an existing party
  _editParty(int index, String updatedParty) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _partyList[index] = updatedParty;
    prefs.setStringList('partyList', _partyList);
    setState(() {});
  }

  // Remove a party from the list
  _removeParty(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _partyList.removeAt(index);
    prefs.setStringList('partyList', _partyList);
    setState(() {});
  }

  // Send an email invitation for the party
  _sendInvitation(String partyName, String partyDate, List<Contact> contacts) async {
    final uri = Uri(
      scheme: 'mailto',
      path: '', // Add email addresses here if available
      query: 'subject=Invitation to $partyName&body=You are invited to a party on $partyDate.',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  // Select contacts for inviting to the party
  Future<List<Contact>> _selectContacts() async {
    Iterable<Contact> contacts = await ContactsService.getContacts();
    // In a real app, implement a UI for selecting contacts.
    return contacts.take(5).toList(); // Select first 5 contacts for demo
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
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.mail),
                          onPressed: () async {
                            List<Contact> contacts = await _selectContacts();
                            _sendInvitation(party[0], party[2], contacts);
                          },
                          tooltip: 'Send Invitation',
                        ),
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            _navigateToEditPartyScreen(context, index, _partyList[index]);
                          },
                          tooltip: 'Edit Party',
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            _removeParty(index);
                          },
                          tooltip: 'Remove Party',
                        ),
                      ],
                    ),
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

  // Navigate to AddPartyScreen
  _navigateToAddPartyScreen(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddPartyScreen()),
    );
    if (result != null) {
      _addParty(result);
    }
  }

  // Navigate to EditPartyScreen
  _navigateToEditPartyScreen(BuildContext context, int index, String party) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPartyScreen(
          isEdit: true,
          existingParty: party,
        ),
      ),
    );
    if (result != null) {
      _editParty(index, result);
    }
  }
}

