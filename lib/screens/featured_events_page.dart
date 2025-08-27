import 'dart:async';
import 'package:flutter/material.dart';
import '../models/event_models.dart';
import '../widgets/common_header.dart';
import '../widgets/universal_image.dart';

class FeaturedEventsPage extends StatefulWidget {
  const FeaturedEventsPage({super.key});

  @override
  State<FeaturedEventsPage> createState() => _FeaturedEventsPageState();
}

class _FeaturedEventsPageState extends State<FeaturedEventsPage> {
  int currentPage = 0;
  late PageController pageController;
  Timer? _timer;
  bool _isUserInteracting = false;
  List<EventData> allEvents = [];

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      final events = await EventManager.loadEvents();
      if (mounted) {
        setState(() {
          allEvents = events;
        });
        _startAutoScroll();
      }
    } catch (e) {
      print('Error loading events: $e');
      if (mounted) {
        setState(() {
          allEvents = [];
        });
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _timer?.cancel();

    // Get screen width for responsive calculation
    final context = this.context;
    if (!context.mounted) return;

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 600;
    final eventsPerPage = isMobile ? 2 : 3;
    final totalPages = (allEvents.length / eventsPerPage).ceil();

    if (totalPages <= 1) return;

    // Increased interval to reduce CPU usage
    _timer = Timer.periodic(const Duration(seconds: 6), (timer) {
      if (!_isUserInteracting && mounted) {
        int nextPage = (currentPage + 1) % totalPages;
        pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _handleUserInteraction() {
    setState(() {
      _isUserInteracting = true;
    });

    // Increased reset duration for better UX
    final isMobile =
        context.mounted ? MediaQuery.of(context).size.width <= 600 : false;
    final resetDuration =
        isMobile ? const Duration(seconds: 8) : const Duration(seconds: 12);

    Timer(resetDuration, () {
      if (mounted) {
        setState(() {
          _isUserInteracting = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 600;
    final isTablet = screenWidth <= 900;

    if (allEvents.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF6F3FF),
        appBar: const CommonHeader(currentPage: 'events'),
        body: const Column(
          children: [
            PurpleDivider(),
            Expanded(
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.deepPurple,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Responsive events per page
    final eventsPerPage = isMobile ? 2 : (isTablet ? 3 : 3);
    final totalPages = (allEvents.length / eventsPerPage).ceil();
    final pages = <List<EventData>>[];

    for (int i = 0; i < totalPages; i++) {
      final startIndex = i * eventsPerPage;
      final endIndex = (startIndex + eventsPerPage < allEvents.length)
          ? startIndex + eventsPerPage
          : allEvents.length;
      pages.add(allEvents.sublist(startIndex, endIndex));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F3FF),
      appBar: const CommonHeader(currentPage: 'events'),
      body: Column(
        children: [
          const PurpleDivider(),
          Expanded(
            child: Column(
              children: [
                // Title Section
                Padding(
                  padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
                  child: Text(
                    "Izdvojeni događaji",
                    style: TextStyle(
                      fontSize: isMobile ? 24 : 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                // Events PageView
                Expanded(
                  child: GestureDetector(
                    onPanStart: (_) => _handleUserInteraction(),
                    onTap: _handleUserInteraction,
                    child: PageView.builder(
                      controller: pageController,
                      itemCount: pages.length,
                      itemBuilder: (context, index) =>
                          _buildEventsGrid(pages[index], screenWidth),
                      onPageChanged: (page) {
                        setState(() {
                          currentPage = page;
                        });
                      },
                      allowImplicitScrolling: true,
                    ),
                  ),
                ),
                // Page indicators (only show if more than 1 page)
                if (totalPages > 1)
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 16.0 : 24.0,
                        vertical: isMobile ? 16.0 : 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        totalPages,
                        (index) => _buildPageIndicator(index, isMobile),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsGrid(List<EventData> events, double screenWidth) {
    final isMobile = screenWidth <= 600;
    final cardHeight = isMobile ? 280.0 : 320.0;
    final maxCardWidth =
        isMobile ? double.infinity : 350.0; // Fixed max width for desktop cards

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16.0 : 24.0),
      child: isMobile
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: events
                  .map(
                    (event) => Container(
                      height: cardHeight,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: RepaintBoundary(
                        child: _FeaturedEventCard(
                          event: event,
                          isMobile: true,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            )
          : Wrap(
              alignment: WrapAlignment.center,
              spacing: 16.0, // Horizontal spacing between cards
              runSpacing: 16.0, // Vertical spacing if cards wrap
              children: events
                  .map(
                    (event) => Container(
                      width: maxCardWidth,
                      height: cardHeight,
                      child: RepaintBoundary(
                        child: _FeaturedEventCard(
                          event: event,
                          isMobile: false,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
    );
  }

  Widget _buildPageIndicator(int pageIndex, bool isMobile) {
    final eventsPerPage = isMobile ? 2 : 3;
    // ignore: unused_local_variable
    final totalPages = (allEvents.length / eventsPerPage).ceil();
    final indicatorSize = isMobile ? 32.0 : 40.0;
    final fontSize = isMobile ? 12.0 : 14.0;

    return GestureDetector(
      onTap: () {
        _handleUserInteraction();
        pageController.animateToPage(
          pageIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: Container(
        width: indicatorSize,
        height: indicatorSize,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: pageIndex == currentPage
              ? Colors.deepPurple
              : Colors.grey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(indicatorSize / 2),
        ),
        child: Center(
          child: Text(
            '${pageIndex + 1}',
            style: TextStyle(
              color: pageIndex == currentPage ? Colors.white : Colors.grey[600],
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
            ),
          ),
        ),
      ),
    );
  }
}

class _FeaturedEventCard extends StatefulWidget {
  final EventData event;
  final bool isMobile;

  const _FeaturedEventCard({
    required this.event,
    required this.isMobile,
  });

  @override
  State<_FeaturedEventCard> createState() => _FeaturedEventCardState();
}

class _FeaturedEventCardState extends State<_FeaturedEventCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final borderRadius = widget.isMobile ? 12.0 : 16.0;
    final titleFontSize = widget.isMobile ? 16.0 : 24.0;
    final descriptionFontSize = widget.isMobile ? 14.0 : 18.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: _isHovered ? Colors.deepPurple : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isHovered ? 0.15 : 0.08),
              blurRadius: _isHovered ? 20 : 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: widget.isMobile
            ? _buildMobileLayout(
                titleFontSize, descriptionFontSize, borderRadius)
            : _buildDesktopLayout(
                titleFontSize, descriptionFontSize, borderRadius),
      ),
    );
  }

  Widget _buildMobileLayout(
      double titleFontSize, double descriptionFontSize, double borderRadius) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image section - fixed height
        SizedBox(
          height: 160,
          child: UniversalImage(
            imageUrl: widget.event.imageUrl,
            width: double.infinity,
            height: 160,
            fit: BoxFit.cover,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(borderRadius)),
          ),
        ),
        // Content section - fixed height
        SizedBox(
          height: 120,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.event.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: titleFontSize,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: Text(
                          widget.event.description,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: descriptionFontSize,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                // Button
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 36,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/event-details',
                        arguments: widget.event.id,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("Pogledaj detalje",
                        style: TextStyle(fontSize: 13)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(
      double titleFontSize, double descriptionFontSize, double borderRadius) {
    return Row(
      children: [
        // Image section
        SizedBox(
          width: 200,
          child: UniversalImage(
            imageUrl: widget.event.imageUrl,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            borderRadius:
                BorderRadius.horizontal(left: Radius.circular(borderRadius)),
          ),
        ),
        // Content section
        Expanded(
          child: Container(
            height: 320,
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.event.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: titleFontSize,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Text(
                    widget.event.description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: descriptionFontSize,
                      height: 1.4,
                    ),
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/event-details',
                      arguments: widget.event.id,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Pogledaj detalje"),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
