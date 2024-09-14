import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:device_calendar/device_calendar.dart'; // for calendar integration
import 'package:contacts_service/contacts_service.dart'; // for contacts integration

class AddPartyScreen extends StatefulWidget {
  final String existingParty;
  final Function onDeleteParty;
  
  AddPartyScreen({this.existingParty, this.onDeleteParty});

  @override
  _AddPartyScreenState createState() => _AddPartyScreenState();
}

class _AddPartyScreenState extends State<AddPartyScreen> {
  final _partyNameController = TextEditingController();
  final _partyDescriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  List<Contact> _invitedContacts = [];

  @override
  void initState() {
    super.initState();
    if (widget.existingParty != null) {
      _loadExistingParty(widget.existingParty);
    }
  }

  // Load the existing party details for editing
  void _loadExistingParty(String party) {
    final parts = party.split(', ');
    _partyNameController.text = parts[0];
    _partyDescriptionController.text = parts[1];
    _selectedDate = DateTime.parse(parts[2]);
  }

  // Select date function
  _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Select contacts function
  _selectContacts() async {
    Iterable<Contact> contacts = await ContactsService.getContacts();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select Contacts'),
          content: Container(
            width: double.minPositive,
            height: 300,
            child: ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts.elementAt(index);
                return CheckboxListTile(
                  title: Text(contact.displayName ?? 'Unknown'),
                  value: _invitedContacts.contains(contact),
                  onChanged: (bool selected) {
                    setState(() {
                      if (selected) {
                        _invitedContacts.add(contact);
                      } else {
                        _invitedContacts.remove(contact);
                      }
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  // Add party to calendar (MUST rule)
  Future<void> _addToCalendar() async {
    final calendarPlugin = DeviceCalendarPlugin();
    final calendarsResult = await calendarPlugin.retrieveCalendars();
    final calendarId = calendarsResult.data.firstWhere((cal) => cal.isDefault, orElse: () => null).id;

    final event = Event(
      calendarId,
      title: _partyNameController.text,
      description: _partyDescriptionController.text,
      start: _selectedDate,
      end: _selectedDate.add(Duration(hours: 2)), // assuming a 2-hour event
    );
    await calendarPlugin.createOrUpdateEvent(event);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingParty != null ? 'Edit Party' : 'Add Party'),
        actions: widget.existingParty != null
            ? [
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    widget.onDeleteParty();
                    Navigator.pop(context);
                  },
                )
              ]
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: _partyNameController,
              decoration: InputDecoration(
                labelText: 'Party Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _partyDescriptionController,
              decoration: InputDecoration(
                labelText: 'Party Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Party Date: ${DateFormat.yMMMd().format(_selectedDate)}',
                  style: TextStyle(fontSize: 16),
                ),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  child: Text('Select Date'),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _selectContacts,
              child: Text('Invite Contacts'),
            ),
            _invitedContacts.isEmpty
                ? Text('No contacts selected')
                : Text(
                    'Invited Contacts: ${_invitedContacts.map((c) => c.displayName).join(', ')}'),
            Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final party = '${_partyNameController.text}, ${_partyDescriptionController.text}, ${_selectedDate.toIso8601String()}';
                  _addToCalendar(); // Save to phone calendar
                  Navigator.pop(context, party);
                },
                child: Text(widget.existingParty != null ? 'Update Party' : 'Add Party'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
