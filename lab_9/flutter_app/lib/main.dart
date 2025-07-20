import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product Grid Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ProductGridPage(),
    );
  }
}

class ProductGridPage extends StatelessWidget {
  const ProductGridPage({super.key});

  @override
  Widget build(BuildContext context) {
    final products = [
      Product(
        title: "Wireless HeadPhone",
        imageUrl:
            "https://th.bing.com/th/id/R.ed1a6de77585f3900fc3f5a19c5c5522?rik=r9a0ula5f6LkQw&pid=ImgRaw&r=0",
        price: 200,
        rating: 4,
        discount: 20,
      ),
      Product(
        title: "Smart Watch",
        imageUrl:
            "https://m.media-amazon.com/images/I/61FHYqP01aL.__AC_SX300_SY300_QL70_ML2_.jpg",
        price: 350,
        rating: 5,
        discount: 15,
      ),
      Product(
        title: "Bluetooth Speaker",
        imageUrl:
            "https://audioteceg.com/cdn/shop/files/71ENXU84F0L._AC_SL1500_921x1085.jpg?v=1717939003",
        price: 180,
        rating: 3,
        discount: 10,
      ),
      Product(
        title: "Bluetooth Speaker",
        imageUrl:
            "https://audioteceg.com/cdn/shop/files/71ENXU84F0L._AC_SL1500_921x1085.jpg?v=1717939003",
        price: 180,
        rating: 3,
        discount: 10,
      ),
      Product(
        title: "Bluetooth Speaker",
        imageUrl:
            "https://audioteceg.com/cdn/shop/files/71ENXU84F0L._AC_SL1500_921x1085.jpg?v=1717939003",
        price: 180,
        rating: 3,
        discount: 10,
      ),
      Product(
        title: "Bluetooth Speaker",
        imageUrl:
            "https://audioteceg.com/cdn/shop/files/71ENXU84F0L._AC_SL1500_921x1085.jpg?v=1717939003",
        price: 180,
        rating: 3,
        discount: 10,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Product Grid")),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: GridView.count(
          crossAxisCount: 3,
          mainAxisSpacing: 15,
          crossAxisSpacing: 15,
          childAspectRatio: 0.68,
          children: products
              .map((product) => ProductCard(product: product))
              .toList(),
        ),
      ),
    );
  }
}

class Product {
  final int discount;
  final String imageUrl;
  final double rating;
  final double price;
  final String title;

  const Product({
    required this.discount,
    required this.imageUrl,
    required this.rating,
    required this.price,
    required this.title,
  });
}

class ProductCard extends StatefulWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool isFavorite = false;
  int count = 0;

  void changeCount(bool isAdd) {
    setState(() {
      if (isAdd && count < 10) {
        count += 1;
      }
      if (!isAdd && count > 0) {
        count -= 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.blue.shade50,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(product.imageUrl, height: 100),
              const SizedBox(height: 8),
              Text(product.title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text("${product.price} EGP",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              StarRating(
                rating: product.rating,
                size: 18,
                color: Colors.orange,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () => changeCount(false),
                    icon: const Icon(Icons.remove, color: Colors.blue),
                    padding: EdgeInsets.zero,
                  ),
                  Text("$count",
                      style:
                          const TextStyle(fontSize: 16, color: Colors.blue)),
                  IconButton(
                    onPressed: () => changeCount(true),
                    icon: const Icon(Icons.add, color: Colors.blue),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    textStyle: const TextStyle(fontSize: 14)),
                child: const Text("Add To Cart"),
              ),
            ],
          ),
        ),
        // Discount circle
        Positioned(
          top: 8,
          left: 8,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.cyan,
            ),
            child: Text("${product.discount}%",
                style: const TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ),
        // Favorite icon
        Positioned(
          top: 5,
          right: 5,
          child: IconButton(
            onPressed: () {
              setState(() {
                isFavorite = !isFavorite;
              });
            },
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.red,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}
