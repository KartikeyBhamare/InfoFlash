class Article {
  final String? title;
  final String? description;
  final String? url;
  final String? imageUrl;

  Article({this.title, this.description, this.url, this.imageUrl});

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'] as String?,
      description: json['description'] as String?,
      url: json['url'] as String?,
      imageUrl: json['urlToImage'] as String?, // Use 'urlToImage' for imageUrl
    );
  }
}
