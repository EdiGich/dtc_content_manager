import 'package:flutter/material.dart';
import 'package:dtc_content_manager/services/news_events_service.dart';
import 'package:dtc_content_manager/views/add_news_page.dart';


class NewsPage extends StatefulWidget {
  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  final NewsEventsService _service = NewsEventsService();
  late Future<List<dynamic>> _newsList;

  @override
  void initState() {
    super.initState();
    _newsList = _service.fetchNews();
  }

  //refresh news when a news item is deleted
  void _refreshNews(){
    setState(() {
      _newsList = _service.fetchNews();
    });
  }

  Future<void> _deleteNews(int newsId) async {
    try {
      await _service.deleteNews(newsId);
      _refreshNews();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('News post deleted!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Failed to delete news post')),
    );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('News'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddNewsPage(refreshNews: _refreshNews),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _newsList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Failed to load news'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No News available'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final newsItem = snapshot.data![index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(newsItem['title'] ?? 'Untitled'),
                    subtitle: Text('Date Published: ${newsItem['date']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteNews(newsItem['id']),
                    ),
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
