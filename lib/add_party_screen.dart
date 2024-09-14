import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddPartyScreen extends StatefulWidget {
  @override
  _AddPartyScreenState createState() => _AddPartyScreenState();
}

class _AddPartyScreenState extends State<AddPartyScreen> {
  final _partyNameController = TextEditingController();
  final _partyDescriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Party'),
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
            Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final party = '${_partyNameController.text}, ${_partyDescriptionController.text}, ${_selectedDate.toLocal()}';
                  Navigator.pop(context, party);
                },
                child: Text('Add Party'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
