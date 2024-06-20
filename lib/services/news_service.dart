import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:news/models/article.dart';

class NewsService {
  static const _apiKey = '3fbd5e01f4ce41519de80c6d16596e6e';
  static const _baseUrl = 'https://newsapi.org/v2';

  Future<List<Article>> fetchTopHeadlines() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/top-headlines?country=in&apiKey=$_apiKey'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<Article> articles = (data['articles'] as List)
          .map((json) => Article.fromJson(json))
          .toList();
      return articles;
    } else {
      throw Exception('Failed to load news');
    }
  }
}
