import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Category extends Equatable {
  final String id;
  final String name;
  final String displayName;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final int articleCount;

  const Category({
    required this.id,
    required this.name,
    required this.displayName,
    required this.icon,
    required this.color,
    this.isSelected = false,
    this.articleCount = 0,
  });

  // Factory constructor to create default categories
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      displayName: json['displayName'],
      icon: _getIconFromString(json['icon']),
      color: Color(json['color']),
      isSelected: json['isSelected'] ?? false,
      articleCount: json['articleCount'] ?? 0,
    );
  }

  // Convert to JSON for caching
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'displayName': displayName,
      'icon': icon.codePoint,
      'color': color.value,
      'isSelected': isSelected,
      'articleCount': articleCount,
    };
  }

  // Copy with method for updates
  Category copyWith({
    String? id,
    String? name,
    String? displayName,
    IconData? icon,
    Color? color,
    bool? isSelected,
    int? articleCount,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isSelected: isSelected ?? this.isSelected,
      articleCount: articleCount ?? this.articleCount,
    );
  }

  static IconData _getIconFromString(dynamic iconCode) {
    if (iconCode is int) {
      return IconData(iconCode, fontFamily: 'MaterialIcons');
    }
    return Icons.category;
  }

  @override
  List<Object?> get props => [
    id,
    name,
    displayName,
    icon,
    color,
    isSelected,
    articleCount,
  ];

  // Static method to get default categories list
  static List<Category> getDefaultCategories() {
    return [
      const Category(
        id: 'general',
        name: 'general',
        displayName: 'General',
        icon: Icons.newspaper,
        color: Colors.blue,
      ),
      const Category(
        id: 'business',
        name: 'business',
        displayName: 'Business',
        icon: Icons.business,
        color: Colors.green,
      ),
      const Category(
        id: 'entertainment',
        name: 'entertainment',
        displayName: 'Entertainment',
        icon: Icons.movie,
        color: Colors.purple,
      ),
      const Category(
        id: 'health',
        name: 'health',
        displayName: 'Health',
        icon: Icons.local_hospital,
        color: Colors.red,
      ),
      const Category(
        id: 'science',
        name: 'science',
        displayName: 'Science',
        icon: Icons.science,
        color: Colors.orange,
      ),
      const Category(
        id: 'sports',
        name: 'sports',
        displayName: 'Sports',
        icon: Icons.sports_soccer,
        color: Colors.teal,
      ),
      const Category(
        id: 'technology',
        name: 'technology',
        displayName: 'Technology',
        icon: Icons.computer,
        color: Colors.indigo,
      ),
    ];
  }

  // Category selection logic
  static List<Category> updateCategorySelection(
    List<Category> categories,
    String selectedCategoryId,
  ) {
    return categories.map((category) {
      return category.copyWith(isSelected: category.id == selectedCategoryId);
    }).toList();
  }

  @override
  String toString() {
    return 'Category(id: $id, name: $name, displayName: $displayName, isSelected: $isSelected)';
  }
}
