// placeholder for the news page
import 'package:dmessages/news/domain/news_article.dart';
import 'package:dmessages/news/domain/news_sources.dart'; // New model for sources
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsPage extends StatefulWidget {
  final String? uid;
  const NewsPage({super.key, this.uid});

  @override
  State<NewsPage> createState() => NewsPageState();
}

class NewsPageState extends State<NewsPage>
    with SingleTickerProviderStateMixin {
  // fetch news
  final Dio _dio = Dio();
  // create a list of news articles
  List<NewsArticle> articles = [];
  // create a list for all countries news
  List<NewsArticle> allCountryArticles = [];
  // create a list of news sources (for filter tab)
  List<NewsSource> sources = [];
  // tab controller for navigation
  late TabController _tabController;

  // filter selections
  String selectedCategory = 'general';
  String selectedCountry = 'us'; // default to current user's country

  @override
  void initState() {
    super.initState();
    // init tab controller with 3 tabs
    _tabController = TabController(length: 3, vsync: this);
    // fetch all countries news when switching to that tab
    _tabController.addListener(() {
      if (_tabController.index == 1) {
        getAllCountriesNews();
      }
    });
    // initial fetch of top headlines
    _getNews();
  }

  @override
  void dispose() {
    // cleanup
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Global News'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Home'),
            Tab(text: 'All Countries'),
            Tab(text: 'Filter'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildNewsUI(),
          buildAllCountriesUI(),
          buildFilterTab(),
        ],
      ),
    );
  }

  // main UI for news cards
  Widget buildNewsUI() {
    return ListView.builder(
      itemCount: articles.length,
      itemBuilder: (context, index) {
        final article = articles[index];
        return _buildArticleCard(article);
      },
    );
  }

  // UI for all countries news
  Widget buildAllCountriesUI() {
    return ListView.builder(
      itemCount: allCountryArticles.length,
      itemBuilder: (context, index) {
        final article = allCountryArticles[index];
        return _buildArticleCard(article);
      },
    );
  }

  // shared card builder for articles
  Widget _buildArticleCard(NewsArticle article) {
    return GestureDetector(
      onTap: () {
        // open the url in the browser
        launchURL(article.url ?? '');
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.network(
                article.urlToImage ?? '',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/images/placeholder.png',
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title ?? 'No Title',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    article.description ?? 'No Description',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        article.source?.name ?? 'Unknown Source',
                        style: const TextStyle(
                            fontStyle: FontStyle.italic, color: Colors.grey),
                      ),
                      Text(
                        article.publishedAt != null
                            ? '${article.publishedAt!.toLocal()}'.split(' ')[0]
                            : 'No Date',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // filter tab UI
  Widget buildFilterTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list, size: 30),
            onSelected: (value) async {
              if (value.startsWith("category:")) {
                selectedCategory = value.split(":")[1];
              } else if (value.startsWith("country:")) {
                selectedCountry = value.split(":")[1];
              }
              await getFilterNews();
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                  value: 'category:business',
                  child: Text('Category: Business')),
              const PopupMenuItem<String>(
                  value: 'category:entertainment',
                  child: Text('Category: Entertainment')),
              const PopupMenuItem<String>(
                  value: 'category:general', child: Text('Category: General')),
              const PopupMenuItem<String>(
                  value: 'category:health', child: Text('Category: Health')),
              const PopupMenuItem<String>(
                  value: 'category:science', child: Text('Category: Science')),
              const PopupMenuItem<String>(
                  value: 'category:sports', child: Text('Category: Sports')),
              const PopupMenuItem<String>(
                  value: 'category:technology',
                  child: Text('Category: Technology')),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                  value: 'country:us', child: Text('Country: United States')),
              const PopupMenuItem<String>(
                  value: 'country:kr', child: Text('Country: South Korea')),
              const PopupMenuItem<String>(
                  value: 'country:br', child: Text('Country: Brazil')),
            ],
          ),
        ),
        Expanded(child: buildSourcesUI()),
      ],
    );
  }

  // show sources with logo images
  Widget buildSourcesUI() {
    return ListView.builder(
      itemCount: sources.length,
      itemBuilder: (context, index) {
        final source = sources[index];
        final logoUrl =
            'https://logo.clearbit.com/${Uri.parse(source.url).host}?size=256';
        return GestureDetector(
          onTap: () => launchURL(source.url),
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(15)),
                  child: Image.network(
                    logoUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return SizedBox(
                        height: 200,
                        child: Center(
                          child: Icon(Icons.public,
                              size: 60, color: Colors.grey[400]),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        source.name,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        source.description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            source.category.toUpperCase(),
                            style: const TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.grey),
                          ),
                          Text(
                            source.country.toUpperCase(),
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _getNews() async {
    // This function will be used to fetch news articles
    final response = await _dio.get(
        '${dotenv.env['NEWSHEADLINES']}?country=us&apiKey=${dotenv.env['NEWSKEY']}');
    final articlesJson = response.data['articles'] as List;
    setState(() {
      List<NewsArticle> newsArticles =
          articlesJson.map((article) => NewsArticle.fromJson(article)).toList();
      // Filter out articles with null image URLs
      // This is to ensure that we only display articles with images
      newsArticles =
          newsArticles.where((article) => article.urlToImage != null).toList();
      articles = newsArticles;
    });
  }

  Future<void> getAllCountriesNews() async {
    // This function fetches news for all friend countries
    // TODO: replace placeholder with actual friend countries list
    final List<String> friendCountries = ['China', 'Korea', 'Mexico'];
    List<NewsArticle> aggregated = [];
    for (var code in friendCountries) {
      final resp = await _dio.get(
          '${dotenv.env['NEWSEVERY']}?q=$code&apiKey=${dotenv.env['NEWSKEY']}');

      final list = resp.data['articles'] as List;
      aggregated.addAll(list.map((j) => NewsArticle.fromJson(j)));
    }
    setState(() {
      allCountryArticles =
          aggregated.where((a) => a.urlToImage != null).toList();
    });
  }

  Future<void> getFilterNews() async {
    // This function will be used to fetch news sources
    print('Selected Category: $selectedCategory');
    print('Selected Country: $selectedCountry');
    print('NEWS SOURCES: ${dotenv.env['NEWSSOURCE']}');
    final response = await _dio.get(
        '${dotenv.env['NEWSSOURCE']}?category=$selectedCategory&country=$selectedCountry&apiKey=${dotenv.env['NEWSKEY']}');
    // print the response
    print('Response: ${response.data}');
    final sourcesJson = response.data['sources'] as List;
    setState(() {
      sources = sourcesJson.map((s) => NewsSource.fromJson(s)).toList();
    });
  }

  // take a url and go to the url in the browser
  Future<void> launchURL(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw 'Could not launch $url';
    }
  }
}
