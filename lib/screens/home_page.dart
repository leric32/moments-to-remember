import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/common_header.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Timer? _timer;
  int _currentEventIndex = 0;
  final PageController _pageController = PageController();

  // List of promoted events
  final List<Map<String, String>> _promotedEvents = [
    {
      "imageUrl":
          "https://images.unsplash.com/photo-1521737852567-6949f3f9f2b5?auto=format&fit=crop&w=400&q=80",
      "title": "Venčane ceremonije",
      "description":
          "Stvorite svoj savršen dan venčanja sa našim sveobuhvatnim uslugama planiranja",
      "price": "\$2,999",
    },
    {
      "imageUrl":
          "https://images.unsplash.com/photo-1519125323398-675f0ddb6308?auto=format&fit=crop&w=400&q=80",
      "title": "Prvi rođendan",
      "description":
          "Učinite njihov prvi rođendan čarobnom proslavom za pamćenje",
      "price": "\$599",
    },
    {
      "imageUrl":
          "https://images.unsplash.com/photo-1504384308090-c894fdcc538d?auto=format&fit=crop&w=400&q=80",
      "title": "Punoletstvo",
      "description": "Proslavite ovu prekretnicu nezaboravnom zabavom",
      "price": "\$899",
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          _currentEventIndex =
              (_currentEventIndex + 1) % _promotedEvents.length;
        });
        _pageController.animateToPage(
          _currentEventIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final isMediumScreen = screenWidth < 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F3FF),
      appBar: const CommonHeader(currentPage: 'home'),
      body: Column(
        children: [
          const PurpleDivider(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Hero Section
                  Padding(
                    padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blueAccent, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: _buildRobustImage(
                              "https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=1000&q=80",
                              height: isSmallScreen ? 200 : 320,
                              width: double.infinity,
                            ),
                          ),
                          Positioned(
                            left: isSmallScreen ? 16 : 32,
                            top: isSmallScreen ? 20 : 48,
                            right: isSmallScreen ? 16 : null,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Stvaranje nezaboravnih\ntrenuka",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: isSmallScreen
                                        ? 20
                                        : (isMediumScreen ? 28 : 36),
                                    shadows: const [
                                      Shadow(
                                        color: Colors.black45,
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: isSmallScreen ? 8 : 16),
                                Text(
                                  "Vaša vrhunska agencija za organizaciju svih posebnih životnih slavlja",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isSmallScreen ? 14 : 18,
                                    shadows: const [
                                      Shadow(
                                        color: Colors.black45,
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: isSmallScreen ? 12 : 24),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepPurple,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: isSmallScreen ? 20 : 28,
                                        vertical: isSmallScreen ? 12 : 16),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/events');
                                  },
                                  child: Text(
                                    "Istražite događaje",
                                    style: TextStyle(
                                        fontSize: isSmallScreen ? 14 : 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Promoted Event Card Section (Auto-sliding)
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 12.0 : 24.0, vertical: 16),
                    child: Column(
                      children: [
                        // Section title
                        Text(
                          "Promocije",
                          style: TextStyle(
                            fontSize: isSmallScreen ? 20 : 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 12 : 16),
                        // Auto-sliding event card
                        SizedBox(
                          height: isSmallScreen ? 260 : 280,
                          child: PageView.builder(
                            controller: _pageController,
                            onPageChanged: (index) {
                              setState(() {
                                _currentEventIndex = index;
                              });
                            },
                            itemCount: _promotedEvents.length,
                            itemBuilder: (context, index) {
                              final event = _promotedEvents[index];
                              return Center(
                                child: Container(
                                  width:
                                      isSmallScreen ? screenWidth * 0.85 : 350,
                                  child: _EventCard(
                                    imageUrl: event["imageUrl"]!,
                                    title: event["title"]!,
                                    description: event["description"]!,
                                    price: event["price"]!,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 12 : 16),
                        // Dot indicators
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _promotedEvents.length,
                            (index) => GestureDetector(
                              onTap: () {
                                setState(() {
                                  _currentEventIndex = index;
                                });
                                _pageController.animateToPage(
                                  index,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                width: _currentEventIndex == index ? 12 : 8,
                                height: _currentEventIndex == index ? 12 : 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _currentEventIndex == index
                                      ? Colors.deepPurple
                                      : Colors.grey[300],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRobustImage(String imageUrl,
      {required double height, required double width}) {
    return Image.network(
      imageUrl,
      height: height,
      width: width,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _buildPlaceholder(imageUrl, height: height, width: width);
      },
      errorBuilder: (context, error, stackTrace) =>
          _buildPlaceholder(imageUrl, height: height, width: width),
    );
  }

  Widget _buildPlaceholder(String imageUrl,
      {required double height, required double width}) {
    // Create themed placeholder based on likely content type
    IconData contentIcon = Icons.landscape;
    String contentText = 'Slika';
    Color contentColor = Colors.deepPurple;

    // Check if it's the hero image
    if (imageUrl.contains('photo-1506744038136') ||
        imageUrl.contains('landscape')) {
      contentIcon = Icons.landscape;
      contentText = 'Pejzaž';
      contentColor = Colors.green;
    }
    // Check if it's an event type
    else if (imageUrl.contains('wedding') ||
        imageUrl.contains('1521737852567')) {
      contentIcon = Icons.favorite;
      contentText = 'Venčanje';
      contentColor = Colors.pink;
    } else if (imageUrl.contains('birthday') ||
        imageUrl.contains('1519125323398')) {
      contentIcon = Icons.cake;
      contentText = 'Rođendan';
      contentColor = Colors.orange;
    } else if (imageUrl.contains('graduation') ||
        imageUrl.contains('1504384308090')) {
      contentIcon = Icons.school;
      contentText = 'Punoletstvo';
      contentColor = Colors.blue;
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            contentColor.withOpacity(0.1),
            contentColor.withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: contentColor.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            contentIcon,
            color: contentColor,
            size: height > 200 ? 48 : 32,
          ),
          const SizedBox(height: 8),
          Text(
            contentText,
            style: TextStyle(
              color: contentColor,
              fontSize: height > 200 ? 16 : 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Offline način rada',
            style: TextStyle(
              color: contentColor.withOpacity(0.7),
              fontSize: height > 200 ? 12 : 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String description;
  final String price;

  const _EventCard({
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Container(
      width: isSmallScreen ? double.infinity : 350,
      constraints: BoxConstraints(
        maxWidth: isSmallScreen ? double.infinity : 350,
        minHeight: isSmallScreen ? 240 : 260,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: _buildRobustImage(
              imageUrl,
              height: isSmallScreen ? 130 : 150,
              width: double.infinity,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 10.0 : 14.0,
                vertical: isSmallScreen ? 8.0 : 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isSmallScreen ? 15 : 17)),
                SizedBox(height: isSmallScreen ? 3 : 5),
                Text(
                  description,
                  style: TextStyle(
                      color: Colors.black54, fontSize: isSmallScreen ? 12 : 13),
                  maxLines: isSmallScreen ? 2 : 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: isSmallScreen ? 8 : 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Od $price",
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.bold,
                          fontSize: isSmallScreen ? 13 : 15,
                        )),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 12 : 16,
                            vertical: isSmallScreen ? 4 : 6),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        minimumSize: Size(
                            isSmallScreen ? 75 : 90, isSmallScreen ? 28 : 32),
                      ),
                      onPressed: () {},
                      child: Text(
                        "Pogledaj detalje",
                        style: TextStyle(fontSize: isSmallScreen ? 11 : 13),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRobustImage(String imageUrl,
      {required double height, required double width}) {
    return Image.network(
      imageUrl,
      height: height,
      width: width,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _buildPlaceholder(imageUrl, height: height, width: width);
      },
      errorBuilder: (context, error, stackTrace) =>
          _buildPlaceholder(imageUrl, height: height, width: width),
    );
  }

  Widget _buildPlaceholder(String imageUrl,
      {required double height, required double width}) {
    // Create themed placeholder based on likely content type
    IconData contentIcon = Icons.event;
    String contentText = 'Događaj';
    Color contentColor = Colors.deepPurple;

    // Check if it's an event type
    if (imageUrl.contains('wedding') || imageUrl.contains('1521737852567')) {
      contentIcon = Icons.favorite;
      contentText = 'Venčanje';
      contentColor = Colors.pink;
    } else if (imageUrl.contains('birthday') ||
        imageUrl.contains('1519125323398')) {
      contentIcon = Icons.cake;
      contentText = 'Rođendan';
      contentColor = Colors.orange;
    } else if (imageUrl.contains('graduation') ||
        imageUrl.contains('1504384308090')) {
      contentIcon = Icons.school;
      contentText = 'Punoletstvo';
      contentColor = Colors.blue;
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            contentColor.withOpacity(0.1),
            contentColor.withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: contentColor.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            contentIcon,
            color: contentColor,
            size: height > 200 ? 40 : 32,
          ),
          const SizedBox(height: 8),
          Text(
            contentText,
            style: TextStyle(
              color: contentColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Offline način rada',
            style: TextStyle(
              color: contentColor.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
