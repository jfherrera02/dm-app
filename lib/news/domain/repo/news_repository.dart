import 'package:dmessages/news/domain/news_article.dart';

abstract class NewsRepository {
  Future<List<NewsArticle>> fetchNews();
  Future<List<NewsArticle>> fetchNewsByCountry(String country);
}
