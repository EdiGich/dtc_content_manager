// add_news_page.dart
import 'package:flutter/material.dart';
import 'package:dtc_content_manager/services/news_events_service.dart';

class AddNewsPage extends StatefulWidget {
  final Function refreshNews;

  const AddNewsPage({Key? key, required this.refreshNews}) : super(key: key);

  @override
  _AddNewsPageState createState() => _AddNewsPageState();
}

class _AddNewsPageState extends State<AddNewsPage> {
  final _formKey = GlobalKey<FormState>();
  final NewsEventsService _service = NewsEventsService();

  String _title = '';
  String _content = '';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

   Future<void> _submitNews() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final String formattedTime = _selectedTime.hour.toString().padLeft(2, '0') +
          ':' +
          _selectedTime.minute.toString().padLeft(2, '0') +
          ':00';

      final newNewsPost = {
        'title': _title,
        'content': _content,
        'date': _selectedDate.toIso8601String().split('T').first,
        'time': formattedTime,
      };

      try {
        await _service.createNews(newNewsPost);
        widget.refreshNews();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('News posted successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to Post')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add News'),
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
                  decoration: const InputDecoration(labelText: 'Add a description'),
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Description content is required' : null,
                  onSaved: (value) => _content = value!,
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
                Center(
                  child: ElevatedButton(
                    onPressed: _submitNews,
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
