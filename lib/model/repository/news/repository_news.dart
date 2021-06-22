import 'dart:async';
import 'dart:convert';
import 'package:voltlauncher/misc/iterable_extensions.dart';
import 'package:voltlauncher/misc/file_extensions.dart';
import 'package:voltlauncher/misc/localdirectories.dart';
import 'package:voltlauncher/model/apis/revoltio/io_api.dart';
import 'package:voltlauncher/model/apis/revoltio/io_newsitem.dart';
import 'package:voltlauncher/model/objects/news/newsitem.dart';
import 'package:voltlauncher/model/objects/sources/newssource.dart';
import 'package:voltlauncher/model/repository/repository.dart';

class RepositoryNews {
  /// The parent repository.
  late Repository _repository;

  /// The cache.
  late _RepositoryNewsCache _cache;

  RepositoryNews(Repository repository) {
    _repository = repository;
    _cache = _RepositoryNewsCache();
  }

  /// Fetch the news
  Future<List<NewsItem>> fetchNews({bool refresh = false}) async {
    // Load from cache
    List<NewsItem>? news = (!refresh) ? await this._cache.fetchNewsFromCache() : null;

    // Check if there's no cached news (or refresh is true)
    if (news == null) {
      news = [];
      // Get the news sources
      List<NewsSource> sources = await _repository.sources.fetchNewsSources();
      // Load the news from each source
      for (NewsSource source in sources) {
        switch (source.apiType) {
          case NewsSourceApiType.volt:
            // TODO: Handle this case.
            break;
          case NewsSourceApiType.revoltIO:
            List<IONewsItem> ioNews = await IOApi.fetchNews(source: source, url: source.url);
            news.addAll(ioNews.map((e) => e.toNewsItem()).toList());
            break;
        }
      }
      // Update the cache
      this._cache.saveNewsToCache(news);
    }

    // Sort the news by date (newest first)
    news.sort((a, b) => a.date.compareTo(b.date) * -1);

    return news;
  }

  /// Clears the cache.
  void clearCache() => this._cache.clear();
}

class _RepositoryNewsCache {
  List<NewsItem>? _news;

  void clear() {
    LocalDirectories.appData.cache.newsFile.deleteIfExists();
    this._news = null;
  }

  Future<List<NewsItem>?> fetchNewsFromCache() async {
    if (this._news != null) {
      // Data was already loaded
      return this._news;
    } else {
      // Load from the cache file
      if (await LocalDirectories.appData.cache.newsFile.exists()) {
        List<dynamic> json = jsonDecode(await LocalDirectories.appData.cache.newsFile.readAsString());
        return this._news = (await json.mapAsync((e) async => await NewsItem.fromJson(e))).toList();
      } else {
        return null;
      }
    }
  }

  Future<bool> saveNewsToCache(List<NewsItem> news) async {
    this._news = news;

    List<dynamic> json = [];
    json.addAll(news.map((e) => e.toJson()));
    await LocalDirectories.appData.cache.directory.create(recursive: true);
    await LocalDirectories.appData.cache.newsFile.writeAsString(JsonEncoder.withIndent('\t').convert(json));
    return true;
  }
}
