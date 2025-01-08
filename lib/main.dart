import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webfeed/domain/rss_feed.dart';
import 'article.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter RSS Feed Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'RSS Feed Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Article> articles = [];
  bool isLoading = false;
  var _title = "";
  var _description = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator() // Show a loader while fetching data
            : articles.isEmpty
                ? const Text('No articles found. Press the button to fetch.')
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: articles.length,
                    itemBuilder: (BuildContext context, int index) {
                      final article = articles[index];

                      _title = utf8.decode(article.title!.codeUnits);

                      _description =
                          utf8.decode((article.description!.codeUnits));

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                            title: Text(
                              _title,
                              style: const TextStyle(
                                color:
                                    Colors.blue, // Set the title color to blue
                                fontWeight: FontWeight
                                    .bold, // Optional: Make the text bold
                              ),
                            ),
                            subtitle: Column(
                              children: [
                                Image(
                                    image: NetworkImage(article.enclosure ??
                                        "https://via.placeholder.com/150")),
                                Text(_description),
                                Text(
                                    "Published on: ${article.pubDate?.toIso8601String() ?? "No Date"}"),
                              ],
                            )),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getFeed,
        tooltip: 'Fetch Articles',
        child: const Icon(Icons.refresh),
      ),
    );
  }

  getFeed() async {
    setState(() {
      isLoading = true; // Show loader when fetching data
    });

    String urlString = "https://www.francebleu.fr/rss/infos.xml";

    try {
      final client = http.Client();
      final url = Uri.parse(urlString);
      final clientResponse = await client.get(url);

      if (clientResponse.statusCode == 200) {
        final rssFeed = RssFeed.parse(clientResponse.body);
        final items = rssFeed.items;

        if (items != null) {
          setState(() {
            articles = items.map((item) => Article(item: item)).toList();
            isLoading = false; // Stop loader after fetching
          });
        } else {
          setState(() {
            isLoading = false;
            articles = [];
          });
          print("No items found in the RSS feed.");
        }
      } else {
        setState(() {
          isLoading = false;
        });
        print(
            "Failed to fetch RSS feed. Status code: ${clientResponse.statusCode}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching RSS feed: $e");
    }
  }
}
