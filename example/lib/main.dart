import 'package:flutter/material.dart';
import 'package:deo_emerges/deo_emerges.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deo Emerges Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Deo Emerges Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final DeoClient _client = DeoClient(
    config: DeoConfig(
      baseUrl: 'https://jsonplaceholder.typicode.com',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      enableLogging: true,
    ),
  );

  // Using Provider adapter
  late final DeoProviderAdapter _providerAdapter;
  
  // Response data
  List<dynamic> _posts = [];
  bool _isLoading = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _providerAdapter = DeoProviderAdapter(_client);
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      // Basic GET request
      final response = await _client.get<List<dynamic>>('/posts');
      setState(() {
        _posts = response.data ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e is DeoError ? e.message : e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _createPost() async {
    // Using the adapter to handle loading state and errors
    final result = await _providerAdapter.execute(() async {
      final response = await _client.post<Map<String, dynamic>>(
        '/posts',
        data: {
          'title': 'New Post',
          'body': 'This is a new post created with Deo Emerges',
          'userId': 1,
        },
      );
      return response.data;
    });

    if (_providerAdapter.error != null) {
      setState(() {
        _error = _providerAdapter.error!.message;
      });
    } else if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post created: ${result['title']}'))
      );
      _fetchData(); // Refresh the list
    }
  }

  Future<void> _fetchConcurrent() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      // Concurrent requests example
      final responses = await _client.concurrent([
        () => _client.get('/posts/1'),
        () => _client.get('/posts/2'),
        () => _client.get('/posts/3'),
      ]);

      setState(() {
        _isLoading = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fetched ${responses.length} posts concurrently'))
        );
      });
    } catch (e) {
      setState(() {
        _error = e is DeoError ? e.message : e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text('Error: $_error'))
              : ListView.builder(
                  itemCount: _posts.length,
                  itemBuilder: (context, index) {
                    final post = _posts[index];
                    return ListTile(
                      title: Text(post['title']),
                      subtitle: Text(post['body']),
                    );
                  },
                ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _fetchData,
            tooltip: 'Fetch Data',
            child: const Icon(Icons.refresh),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _createPost,
            tooltip: 'Create Post',
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _fetchConcurrent,
            tooltip: 'Fetch Concurrent',
            child: const Icon(Icons.flash_on),
          ),
        ],
      ),
    );
  }
}