// placeholder for the news page
import 'package:dmessages/news/domain/news_article.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NewsPage extends StatefulWidget {
  final String? uid;
  const NewsPage({super.key, this.uid});

  @override
  State<NewsPage> createState() => NewsPageState();
}  
  class NewsPageState extends State<NewsPage> {

    // fetch news 
    final Dio _dio = Dio();
    // create a list of news articles
    List<NewsArticle> articles = [];

    @override
    void initState() {
      super.initState();
      // Any initialization code can go here
      _getNews();
    }
  
    @override
    void dispose() {
      // Any cleanup code can go here
      super.dispose();
    }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('News'),
      ),
      body: buildNewsUI(),
    );
  }

  Widget buildNewsUI() {
    return ListView.builder(
      itemCount: articles.length,
      itemBuilder: (context, index) {
        final article = articles[index];
        return ListTile(
          title: Text(article.title ?? 'No Title'),
          subtitle: Text(article.description ?? 'No Description'),
          leading: Image.network(article.urlToImage ?? Image.asset('assets/images/placeholder.png').toString(),
          height: 250,
          width: 100,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset('assets/images/placeholder.png', fit: BoxFit.cover);
          },
          ),
        );
      },
    );
  }

  Future<void> _getNews() async {
    // This function will be used to fetch news articles
    final response = 
    await _dio.get('${dotenv.env['NEWSHEADLINES']}?country=us&category=business&apiKey=${dotenv.env['NEWSKEY']}');
    print(response);
    final articlesJson = response.data['articles'] as List;
    setState(() {
     List<NewsArticle> newsArticles = articlesJson.map((article) => NewsArticle.fromJson(article)).toList();
      // Filter out articles with null image URLs
      // This is to ensure that we only display articles with images
      newsArticles = newsArticles.where((article) => article.urlToImage != null).toList();
      articles = newsArticles;
    });
  }
}