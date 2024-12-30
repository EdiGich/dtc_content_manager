// add_event_page.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dtc_content_manager/services/news_events_service.dart';
import 'dart:io';

class AddEventPage extends StatefulWidget {
  final Function refreshEvents;

  const AddEventPage({Key? key, required this.refreshEvents}) : super(key: key);

  @override
  _AddEventPageState createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final _formKey = GlobalKey<FormState>();
  final NewsEventsService _service = NewsEventsService();

  String _title = '';
  String _description = '';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  XFile? _pickedFile;

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _pickedFile = pickedFile;
    });
  }

  Future<void> _submitEvent() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final String formattedTime = _selectedTime.hour.toString().padLeft(2, '0') +
          ':' +
          _selectedTime.minute.toString().padLeft(2, '0') +
          ':00';

      final newEvent = {
        'title': _title,
        'description': _description,
        'date': _selectedDate.toIso8601String().split('T').first,
        'time': formattedTime,
        // Pass the file path if an image is selected, otherwise pass null
        'image': _pickedFile != null ? File(_pickedFile!.path) : null,
      };

      try {
        await _service.createEvent(newEvent);
        widget.refreshEvents();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event created successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create event')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Title is required' : null,
                  onSaved: (value) => _title = value!,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Description'),
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Description is required' : null,
                  onSaved: (value) => _description = value!,
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text(
                    'Date: ${_selectedDate.toLocal().toIso8601String().split('T').first}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _selectedDate = pickedDate;
                      });
                    }
                  },
                ),
                ListTile(
                  title: Text('Time: ${_selectedTime.format(context)}'),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: _selectedTime,
                    );
                    if (pickedTime != null) {
                      setState(() {
                        _selectedTime = pickedTime;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                _pickedFile != null
                    ? Image.file(
                  File(_pickedFile!.path),
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
                    : const Text('No image selected'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: const Text('Select Image'),
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: _submitEvent,
                    child: const Text('Submit'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
