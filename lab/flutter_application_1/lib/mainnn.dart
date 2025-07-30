import 'package:flutter/material.dart';

void main() => runApp(const RestaurantMenuApp());

class RestaurantMenuApp extends StatefulWidget {
  const RestaurantMenuApp({super.key});

  @override
  State<RestaurantMenuApp> createState() => _RestaurantMenuAppState();
}

class _RestaurantMenuAppState extends State<RestaurantMenuApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Restaurant Menu',
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.white,
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 119, 178, 226),
          ),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        cardColor: Colors.grey[900],
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      themeMode: _themeMode,
      home: RestaurantMenuScreen(
        onToggleTheme: _toggleTheme,
        isDark: _themeMode == ThemeMode.dark,
      ),
    );
  }
}

class RestaurantMenuScreen extends StatelessWidget {
  final VoidCallback onToggleTheme;
  final bool isDark;

  const RestaurantMenuScreen({
    super.key,
    required this.onToggleTheme,
    required this.isDark,
  });

  final List<Map<String, dynamic>> foodItems = const [
    {
      'title': 'Grilled Salmon',
      'description':
          'This grilled salmon tastes so good! A simple soy sauce and brown sugar marinade...',
      'price': '\$26',
      'image':
          'https://www.allrecipes.com/thmb/S9CtWJQki8yNesfmTPt8tCDl6uo=/0x512/filters:no_upscale():max_bytes(150000):strip_icc():format(webp)/ALR-12720-grilled-salmon-i-VAT-4x3-888cac0fb8a34f6fbde7bf836850cd1c.jpg',
    },
    {
      'title': 'Chicken Alfredo',
      'description':
          'This chicken Alfredo recipe with jar sauce is a quick and easy dinner...',
      'price': '\$18',
      'image':
          'https://www.allrecipes.com/thmb/YLapeTnBgIkJOiD_Vy3Ohh0QeD4=/750x0/filters:no_upscale():max_bytes(150000):strip_icc():format(webp)/11970easy-chicken-alfredofabeveryday2x1-a4112dbccf3d4149a18eb45435e77115.jpg',
    },
    {
      'title': 'Margherita Pizza',
      'description':
          'A simple pizza hailing from Naples. When done right, margherita pizza features a bubbly crust...',
      'price': '\$20',
      'image':
          'https://cookieandkate.com/images/2021/07/margherita-pizza-recipe-1-2.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = 1;

    if (screenWidth > 900) {
      crossAxisCount = 4;
    } else if (screenWidth > 600) {
      crossAxisCount = 3;
    } else if (screenWidth > 400) {
      crossAxisCount = 2;
    }

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'RESTAURANT MENU',
            style: TextStyle(
              letterSpacing: 2,
              color: Colors.blue[400],
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(isDark ? Icons.wb_sunny : Icons.nightlight_round),
              onPressed: onToggleTheme,
              tooltip: "Toggle Theme",
            ),
          ],
          bottom: const TabBar(
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.black,
            tabs: [
              Tab(text: 'Main Dishes'),
              Tab(text: 'Popular Dishes'),
              Tab(text: 'Desserts'),
              Tab(text: 'Beverages'),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 3 / 2,
            ),
            itemCount: foodItems.length,
            itemBuilder: (context, index) {
              final item = foodItems[index];
              return FoodCard(
                title: item['title'],
                description: item['description'],
                price: item['price'],
                image: item['image'],
              );
            },
          ),
        ),
      ),
    );
  }
}

class FoodCard extends StatelessWidget {
  final String title, description, price, image;

  const FoodCard({
    super.key,
    required this.title,
    required this.description,
    required this.price,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Row(
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.horizontal(left: Radius.circular(16)),
            child: Image.network(
              image,
              width: 100,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[400])),
                  const SizedBox(height: 4),
                  Text(description,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  const SizedBox(height: 8),
                  Text(price,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[400])),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
