import 'package:equatable/equatable.dart';

class Article extends Equatable {
  final String id;
  final String title;
  final String description;
  final String content;
  final String imageUrl;
  final DateTime publishedAt;
  final String source;
  final String author;
  final String url;
  final String category;
  final bool isBookmarked;

  const Article({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.imageUrl,
    required this.publishedAt,
    required this.source,
    required this.author,
    required this.url,
    required this.category,
    this.isBookmarked = false,
  });

  // Factory constructor from JSON (News API response)
  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: _generateId(json),
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? 'No Description',
      content: json['content'] ?? '',
      imageUrl: json['urlToImage'] ?? '',
      publishedAt:
          DateTime.tryParse(json['publishedAt'] ?? '') ?? DateTime.now(),
      source: json['source']?['name'] ?? 'Unknown Source',
      author: json['author'] ?? 'Unknown Author',
      url: json['url'] ?? '',
      category: json['category'] ?? 'general',
    );
  }

  // Generate unique ID from title and source
  static String _generateId(Map<String, dynamic> json) {
    final title = json['title'] ?? '';
    final source = json['source']?['name'] ?? '';
    return '${title.hashCode}_${source.hashCode}';
  }

  // Convert to JSON for caching
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'content': content,
      'urlToImage': imageUrl,
      'publishedAt': publishedAt.toIso8601String(),
      'source': {'name': source},
      'author': author,
      'url': url,
      'category': category,
      'isBookmarked': isBookmarked,
    };
  }

  // Copy with method for updates
  Article copyWith({
    String? id,
    String? title,
    String? description,
    String? content,
    String? imageUrl,
    DateTime? publishedAt,
    String? source,
    String? author,
    String? url,
    String? category,
    bool? isBookmarked,
  }) {
    return Article(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      publishedAt: publishedAt ?? this.publishedAt,
      source: source ?? this.source,
      author: author ?? this.author,
      url: url ?? this.url,
      category: category ?? this.category,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }

  // toString method for debugging
  @override
  String toString() {
    return 'Article(id: $id, title: $title, source: $source, category: $category, isBookmarked: $isBookmarked)';
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    content,
    imageUrl,
    publishedAt,
    source,
    author,
    url,
    category,
    isBookmarked,
  ];
}
