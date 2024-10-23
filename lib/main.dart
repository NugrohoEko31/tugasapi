import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Poetry App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PoetryPage(),
    );
  }
}

class PoetryPage extends StatefulWidget {
  const PoetryPage({super.key});

  @override
  _PoetryPageState createState() => _PoetryPageState();
}

class _PoetryPageState extends State<PoetryPage> {
  Map<String, dynamic>? poem;
  bool isLoading = false;

  // Function to fetch a random poem from PoetryDB API
  Future<void> fetchRandomPoem() async {
    setState(() {
      isLoading = true;
    });

    final response = await http.get(Uri.parse('https://poetrydb.org/random'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        poem = data[0];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load poem')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchRandomPoem(); // Fetch a random poem on page load
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Random Poem'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchRandomPoem, // Fetch a new poem when tapped
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : poem == null
              ? const Center(child: Text('No poem available'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(poem!['title'],
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text('By ${poem!['author']}',
                          style: const TextStyle(
                              fontSize: 18, fontStyle: FontStyle.italic)),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView(
                          children: [
                            ...poem!['lines'].map<Widget>((line) => Text(line)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}