import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:news_app_mvvm/core/network/api_client.dart';
import 'package:news_app_mvvm/core/network/token_provider.dart';
import 'package:news_app_mvvm/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:news_app_mvvm/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:news_app_mvvm/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:news_app_mvvm/features/auth/domain/repositories/auth_repository.dart';
import 'package:news_app_mvvm/features/auth/domain/usecases/get_profile_usecase.dart';
import 'package:news_app_mvvm/features/auth/domain/usecases/login_usecase.dart';
import 'package:news_app_mvvm/features/auth/domain/usecases/register_usecase.dart';
import 'package:news_app_mvvm/features/auth/domain/usecases/logout_usecase.dart';
import 'package:news_app_mvvm/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:news_app_mvvm/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:news_app_mvvm/core/viewmodels/global_alert_viewmodel.dart';

// News Module
import 'package:news_app_mvvm/features/news/data/datasources/news_local_data_source.dart';
import 'package:news_app_mvvm/features/news/data/datasources/news_remote_data_source.dart';
import 'package:news_app_mvvm/features/news/data/repositories/news_repository_impl.dart';
import 'package:news_app_mvvm/features/news/domain/repositories/news_repository.dart';
import 'package:news_app_mvvm/features/news/domain/usecases/check_bookmark_status_usecase.dart';
import 'package:news_app_mvvm/features/news/domain/usecases/get_article_usecase.dart';
import 'package:news_app_mvvm/features/news/domain/usecases/get_bookmarks_usecase.dart';
import 'package:news_app_mvvm/features/news/domain/usecases/get_categories_usecase.dart';
import 'package:news_app_mvvm/features/news/domain/usecases/get_news_feed_usecase.dart';
import 'package:news_app_mvvm/features/news/domain/usecases/toggle_bookmark_usecase.dart';
import 'package:news_app_mvvm/features/news/presentation/viewmodels/article_detail_viewmodel.dart';
import 'package:news_app_mvvm/features/news/presentation/viewmodels/explore_viewmodel.dart';
import 'package:news_app_mvvm/features/news/presentation/viewmodels/bookmark_viewmodel.dart';
import 'package:news_app_mvvm/features/news/presentation/viewmodels/search_viewmodel.dart';
import 'package:news_app_mvvm/features/news/presentation/viewmodels/news_feed_viewmodel.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ==================== External ====================
  const secureStorage = FlutterSecureStorage();
  sl.registerLazySingleton<FlutterSecureStorage>(() => secureStorage);

  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // ==================== Datasources ====================
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(secureStorage: sl(), sharedPreferences: sl()),
  );

  sl.registerLazySingleton<TokenProvider>(
    () => sl<AuthLocalDataSource>() as TokenProvider,
  );

  // ==================== Core ====================
  sl.registerLazySingleton<ApiClient>(() => ApiClient(
    tokenProvider: sl(),
    globalAlertViewModel: sl(),
  ));

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(apiClient: sl()),
  );

  sl.registerLazySingleton<NewsLocalDataSource>(
    () => NewsLocalDataSourceImpl(sharedPreferences: sl()),
  );

  sl.registerLazySingleton<NewsRemoteDataSource>(
    () => NewsRemoteDataSourceImpl(apiClient: sl()),
  );

  // ==================== Repository ====================
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );

  sl.registerLazySingleton<NewsRepository>(
    () => NewsRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );

  // ==================== Use Cases ====================
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => GetProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));

  sl.registerLazySingleton(() => GetCategoriesUseCase(sl()));
  sl.registerLazySingleton(() => GetNewsFeedUseCase(sl()));
  sl.registerLazySingleton(() => GetArticleUseCase(sl()));
  sl.registerLazySingleton(() => GetBookmarksUseCase(sl()));
  sl.registerLazySingleton(() => ToggleBookmarkUseCase(sl()));
  sl.registerLazySingleton(() => CheckBookmarkStatusUseCase(sl()));

  // ==================== ViewModel (Provider) ====================
  // Sengaja dibuat LazySingleton karena AuthViewModel dan GlobalAlertViewModel
  // menyimpan state secara global (Root App).
  
  sl.registerLazySingleton<GlobalAlertViewModel>(() => GlobalAlertViewModel());
  
  sl.registerLazySingleton<AuthViewModel>(
    () => AuthViewModel(
      loginUseCase: sl(),
      registerUseCase: sl(),
      getProfileUseCase: sl(),
      updateProfileUseCase: sl(),
      logoutUseCase: sl(),
    ),
  );

  sl.registerFactory<NewsFeedViewModel>(
    () => NewsFeedViewModel(
      getCategoriesUseCase: sl(),
      getNewsFeedUseCase: sl(),
    ),
  );

  sl.registerFactory<BookmarkViewModel>(
    () => BookmarkViewModel(
      getBookmarksUseCase: sl(),
      toggleBookmarkUseCase: sl(),
    ),
  );

  sl.registerFactory<ArticleDetailViewModel>(
    () => ArticleDetailViewModel(
      getArticleUseCase: sl(),
      checkBookmarkStatusUseCase: sl(),
      toggleBookmarkUseCase: sl(),
    ),
  );

  sl.registerFactory<ExploreViewModel>(
    () => ExploreViewModel(getNewsFeedUseCase: sl()),
  );

  sl.registerFactory<SearchViewModel>(
    () => SearchViewModel(getNewsFeedUseCase: sl()),
  );
}
