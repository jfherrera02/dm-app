import 'package:dmessages/features/domain/storage_repository.dart';
import 'package:dmessages/news/domain/repo/news_repository.dart';
import 'package:dmessages/news/presentation/cubits/news_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NewsCubit extends Cubit<NewsState> {
  final NewsRepository newsRepo;
  final StorageRepository storageRepo;

  // constructor
  // accept the news repo and the storage repo
  // this is the repo that will be used to upload images to the backend
  NewsCubit({
    required this.newsRepo,
    required this.storageRepo,
  }) : super(NewsInitial());

  // now we can fetch news articles
  // for now we will display top US news articles
  Future<void> fetchNews() async {
    try {
      emit(NewsLoading());

      // fetch the news articles from the repo
      final newsArticles = await newsRepo.fetchNews();

      // emit the success state with the news articles
      emit(NewsLoaded(newsArticles));
    } catch (e) {
      emit(NewsError("Failed fetching news: $e"));
    }
  }
}
