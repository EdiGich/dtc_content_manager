import 'package:flutter/material.dart';
import 'package:dtc_content_manager/services/news_events_service.dart';

class EventsPage extends StatefulWidget {
  @override
  _EventsPageState createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  final NewsEventsService _service = NewsEventsService();
  late Future<List<dynamic>> _eventsList;

  @override
  void initState() {
    super.initState();
    _refreshEvents();
  }

  void _refreshEvents() {
    setState(() {
      _eventsList = _service.fetchEvents();
    });
  }

  Future<void> _addEvent() async {
    final newEvent = {
      'title': 'New Event',
      'description': 'This is a newly created event.',
      'date': '2024-12-25',
      'time': '15:00',
      'image': null,
    };

    try {
      await _service.createEvent(newEvent);
      _refreshEvents();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event created successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create event')),
      );
    }
  }

  Future<void> _deleteEvent(int eventId) async {
    try {
      await _service.deleteEvent(eventId);
      _refreshEvents();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete event')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Events'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _addEvent,
            ),
          ],
      ),

      body: FutureBuilder<List<dynamic>>(
        future: _eventsList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Failed to load events'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No events available'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final event = snapshot.data![index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(event['title']),
                    subtitle: Text(
                      '${event['date']} at ${event['time']}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteEvent(event['id']),
                    ),
                    leading: event['image'] != null
                        ? Image.network(
                      event['image'],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    )
                        : null,
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
