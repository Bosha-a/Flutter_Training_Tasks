import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(debugShowCheckedModeBanner: false,home: SocialMediaCard()));
}

class SocialMediaCard extends StatefulWidget {
  const SocialMediaCard({super.key});

  @override
  State<SocialMediaCard> createState() => _SocialMediaCardState();
}

class _SocialMediaCardState extends State<SocialMediaCard>
    with SingleTickerProviderStateMixin {
  bool isLiked = false;
  bool showCommentField = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      }
    });
  }

  void _handleDoubleTap() {
    setState(() {
      isLiked = true;
    });
    _controller.forward();
  }

  void _showProfileModal(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Profile Details"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(
              'https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcRs80wcNFYC-cDoRbj54Bg1KtvTx_WPXyQodNfddw7B-fe9kUHyYDX0ZHmjWZLmdPAgoeCH72hBbtGa44Uy4dBn7NuAl19jbYMaaLbW20X5',
            ),
          ),
          const SizedBox(height: 10),
          const Text("Elon Mask", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text("SpaceX Founder & CEO"), // Bio
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Row(
                children: [
                  Icon(Icons.facebook, size: 18),
                  SizedBox(width: 8),
                  Expanded(child: Text("facebook.com/elon")),
                ],
              ),
              SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.link, size: 18),
                  SizedBox(width: 8),
                  Expanded(child: Text("twitter.com/elonmusk")),
                ],
              ),
              SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.camera_alt, size: 18),
                  SizedBox(width: 8),
                  Expanded(child: Text("instagram.com/elon")),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context), child: const Text("Close")),
      ],
    ),
  );
}

  void _showShareOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => ListView(
        shrinkWrap: true,
        children: const [
          ListTile(leading: Icon(Icons.link), title: Text('Copy Link')),
          ListTile(leading: Icon(Icons.share), title: Text('Share to...')),
          ListTile(leading: Icon(Icons.chat), title: Text('Message')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Social Media Card"),centerTitle: true),
      body: Center(
        child: Card(
          elevation: 4,
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _showProfileModal(context),
                    child: const CircleAvatar(
                      backgroundImage: NetworkImage('https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcRs80wcNFYC-cDoRbj54Bg1KtvTx_WPXyQodNfddw7B-fe9kUHyYDX0ZHmjWZLmdPAgoeCH72hBbtGa44Uy4dBn7NuAl19jbYMaaLbW20X5'),
                      radius: 24,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text("Elon Mask", style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onDoubleTap: _handleDoubleTap,
                child: const Text(
                  "The fool doth think he is wise, but the wise man knows himself to be a fool.",
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() => isLiked = !isLiked);
                      _controller.forward();
                    },
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Icon(
                        Icons.favorite,
                        color: isLiked ? Colors.red : Colors.grey,
                        size: 28,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.comment),
                    onPressed: () {
                      setState(() => showCommentField = true);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () => _showShareOptions(context),
                  ),
                ],
              ),
              if (showCommentField)
                TextField(
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Write a comment...',
                    border: OutlineInputBorder(),
                  ),
                ),
            ]),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
