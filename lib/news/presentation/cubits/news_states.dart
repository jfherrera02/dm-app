import 'package:dmessages/news/domain/news_article.dart';

abstract class NewsState {}

// initial state
class NewsInitial extends NewsState {}

// loading state (fetching data from api)
class NewsLoading extends NewsState {}

// loaded state (when data is fetched successfully)
class NewsLoaded extends NewsState {
  final List<NewsArticle> articles;
  NewsLoaded(this.articles);
}

// error state (when there is an error fetching data
// such as network error or malformed data)
class NewsError extends NewsState {
  final String message;
  NewsError(this.message);
}
