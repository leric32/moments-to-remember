import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/event_models.dart';
import '../models/user.dart';
import '../widgets/common_header.dart';
import '../widgets/universal_image.dart';

class EventDetailsPage extends StatefulWidget {
  final String eventId;

  const EventDetailsPage({super.key, required this.eventId});

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  int userRating = 0;
  final TextEditingController reviewController = TextEditingController();
  final TextEditingController eventDateController = TextEditingController();
  final TextEditingController guestCountController = TextEditingController();

  String currentView = 'reviews'; // 'reviews', 'writeReview', 'booking'

  EventData? event;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvent();
  }

  Future<void> _loadEvent() async {
    try {
      final events = await EventManager.loadEvents();
      final foundEvent = events.firstWhere(
        (e) => e.id == widget.eventId,
        orElse: () => throw Exception('Event not found'),
      );
      setState(() {
        event = foundEvent;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Greška pri učitavanju događaja: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    reviewController.dispose();
    eventDateController.dispose();
    guestCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final isMediumScreen = screenWidth < 900;

    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF6F3FF),
        appBar: const CommonHeader(currentPage: 'event_details'),
        body: const Center(
          child: CircularProgressIndicator(
            color: Colors.deepPurple,
          ),
        ),
      );
    }

    if (event == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF6F3FF),
        appBar: const CommonHeader(currentPage: 'event_details'),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                'Događaj nije pronađen',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F3FF),
      appBar: const CommonHeader(currentPage: 'event_details'),
      body: Column(
        children: [
          const PurpleDivider(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Main content section
                  Padding(
                    padding: EdgeInsets.all(isSmallScreen ? 16.0 : 24.0),
                    child: isSmallScreen
                        ? Column(
                            // Stack vertically on mobile
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Event image
                              UniversalImage(
                                imageUrl: event!.imageUrl,
                                height: 250,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              const SizedBox(height: 20),
                              // Event details
                              _buildEventDetails(isSmallScreen),
                            ],
                          )
                        : Row(
                            // Side by side on desktop
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Left side - Event image
                              Expanded(
                                flex: 1,
                                child: UniversalImage(
                                  imageUrl: event!.imageUrl,
                                  height: isMediumScreen ? 300 : 400,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              const SizedBox(width: 32),
                              // Right side - Event details
                              Expanded(
                                flex: 1,
                                child: _buildEventDetails(isSmallScreen),
                              ),
                            ],
                          ),
                  ),
                  // Content Section (Reviews, Write Review, or Booking)
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 16 : 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
                      child: Column(
                        children: [
                          _buildTabNavigation(isSmallScreen),
                          const SizedBox(height: 24),
                          _buildMainContent(isSmallScreen),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 48), // Bottom spacing
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventDetails(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Event title
        Text(
          event!.title,
          style: TextStyle(
            fontSize: isSmallScreen ? 24 : 32,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: isSmallScreen ? 12 : 16),
        // Price
        Text(
          event!.price,
          style: TextStyle(
            fontSize: isSmallScreen ? 20 : 28,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        SizedBox(height: isSmallScreen ? 12 : 16),
        // Rating
        Row(
          children: [
            ...List.generate(5, (index) {
              return Icon(
                index < event!.rating.floor()
                    ? Icons.star
                    : (index < event!.rating
                        ? Icons.star_half
                        : Icons.star_border),
                color: Colors.amber,
                size: isSmallScreen ? 20 : 24,
              );
            }),
            const SizedBox(width: 8),
            Text(
              "(${event!.rating.toStringAsFixed(1)} / ${event!.reviewCount} recenzija)",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: isSmallScreen ? 14 : 16,
              ),
            ),
          ],
        ),
        SizedBox(height: isSmallScreen ? 16 : 24),
        // Description
        Text(
          "Opis:",
          style: TextStyle(
            fontSize: isSmallScreen ? 16 : 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: isSmallScreen ? 6 : 8),
        Text(
          event!.description,
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : 16,
            color: Colors.black54,
            height: 1.5,
          ),
        ),
        SizedBox(height: isSmallScreen ? 20 : 32),
      ],
    );
  }

  Widget _buildTabNavigation(bool isSmallScreen) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: isSmallScreen
          ? Column(
              // Stack vertically on mobile
              children: [
                _buildTabButton(
                    'reviews', 'Recenzije', Icons.rate_review, isSmallScreen),
                const SizedBox(height: 4),
                _buildTabButton('writeReview', 'Napišite recenziju', Icons.edit,
                    isSmallScreen),
                const SizedBox(height: 4),
                _buildTabButton('booking', 'Rezervišite', Icons.calendar_today,
                    isSmallScreen),
              ],
            )
          : Row(
              // Horizontal on larger screens
              children: [
                Expanded(
                    child: _buildTabButton('reviews', 'Recenzije',
                        Icons.rate_review, isSmallScreen)),
                Expanded(
                    child: _buildTabButton('writeReview', 'Napišite recenziju',
                        Icons.edit, isSmallScreen)),
                Expanded(
                    child: _buildTabButton('booking', 'Rezervišite',
                        Icons.calendar_today, isSmallScreen)),
              ],
            ),
    );
  }

  Widget _buildTabButton(
      String view, String title, IconData icon, bool isSmallScreen) {
    final isActive = currentView == view;
    return Material(
      color: isActive ? Colors.deepPurple : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          setState(() {
            currentView = view;
          });
        },
        child: Container(
          width: isSmallScreen ? double.infinity : null,
          padding: EdgeInsets.symmetric(
              vertical: isSmallScreen ? 12 : 16,
              horizontal: isSmallScreen ? 16 : 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isActive ? Colors.white : Colors.grey[600],
                size: isSmallScreen ? 18 : 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.grey[600],
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  fontSize: isSmallScreen ? 13 : 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(bool isSmallScreen) {
    switch (currentView) {
      case 'reviews':
        return _buildReviewsSection(isSmallScreen);
      case 'writeReview':
        return _buildWriteReviewSection(isSmallScreen);
      case 'booking':
        return _buildBookingForm(isSmallScreen);
      default:
        return _buildReviewsSection(isSmallScreen);
    }
  }

  Widget _buildReviewsSection(bool isSmallScreen) {
    if (event!.reviews.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.rate_review_outlined,
                size: isSmallScreen ? 40 : 48,
                color: Colors.grey[400],
              ),
              SizedBox(height: isSmallScreen ? 12 : 16),
              Text(
                "Nema recenzija",
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: isSmallScreen ? 6 : 8),
              Text(
                "Budite prvi koji će ostaviti recenziju!",
                style: TextStyle(
                  fontSize: isSmallScreen ? 13 : 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${event!.reviews.length} Recenzija",
              style: TextStyle(
                fontSize: isSmallScreen ? 18 : 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  currentView = 'writeReview';
                });
              },
              icon: Icon(Icons.edit, size: isSmallScreen ? 16 : 18),
              label: Text(
                "Napišite recenziju",
                style: TextStyle(fontSize: isSmallScreen ? 13 : 14),
              ),
            ),
          ],
        ),
        SizedBox(height: isSmallScreen ? 12 : 16),
        ...event!.reviews
            .map((review) => _buildReviewCard(review, isSmallScreen)),
      ],
    );
  }

  Widget _buildReviewCard(ReviewData review, bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 12 : 16),
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: isSmallScreen ? 16 : 20,
                backgroundImage: review.userImage.startsWith('assets/')
                    ? AssetImage(review.userImage) as ImageProvider
                    : review.userImage.startsWith('base64:')
                        ? MemoryImage(
                            base64Decode(review.userImage.substring(7)))
                        : const AssetImage('assets/images/profile_img.png'),
              ),
              SizedBox(width: isSmallScreen ? 8 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isSmallScreen ? 14 : 16,
                      ),
                    ),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < review.rating
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: isSmallScreen ? 14 : 16,
                          );
                        }),
                        SizedBox(width: isSmallScreen ? 4 : 8),
                        Text(
                          _formatDate(review.createdAt),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: isSmallScreen ? 11 : 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),
          Text(
            review.comment,
            style: TextStyle(
              fontSize: isSmallScreen ? 13 : 14,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWriteReviewSection(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Napišite recenziju",
          style: TextStyle(
            fontSize: isSmallScreen ? 18 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: isSmallScreen ? 16 : 20),
        Text(
          "Ocena:",
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: isSmallScreen ? 8 : 12),
        Row(
          children: List.generate(5, (index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  userRating = index + 1;
                });
              },
              child: Icon(
                index < userRating ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: isSmallScreen ? 28 : 32,
              ),
            );
          }),
        ),
        SizedBox(height: isSmallScreen ? 16 : 20),
        Text(
          "Komentar:",
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: isSmallScreen ? 8 : 12),
        TextField(
          controller: reviewController,
          maxLines: isSmallScreen ? 4 : 5,
          decoration: InputDecoration(
            hintText: "Podelite svoje iskustvo...",
            hintStyle: TextStyle(fontSize: isSmallScreen ? 14 : 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          ),
          style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
        ),
        SizedBox(height: isSmallScreen ? 20 : 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    currentView = 'reviews';
                    userRating = 0;
                    reviewController.clear();
                  });
                },
                style: OutlinedButton.styleFrom(
                  padding:
                      EdgeInsets.symmetric(vertical: isSmallScreen ? 12 : 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  side: BorderSide(color: Colors.grey[300]!),
                  minimumSize: Size(0, isSmallScreen ? 44 : 48),
                ),
                child: Text(
                  "Otkaži",
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
            SizedBox(width: isSmallScreen ? 12 : 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _submitReview(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding:
                      EdgeInsets.symmetric(vertical: isSmallScreen ? 12 : 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: Size(0, isSmallScreen ? 44 : 48),
                ),
                child: Text(
                  "Pošaljite",
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBookingForm(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Dodaj u korpu",
          style: TextStyle(
            fontSize: isSmallScreen ? 18 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: isSmallScreen ? 8 : 12),
        Text(
          "Dodajte događaj u korpu, a zatim pošaljite sve rezervacije odjednom.",
          style: TextStyle(
            fontSize: isSmallScreen ? 13 : 14,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: isSmallScreen ? 16 : 20),
        // Event summary
        Container(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Container(
                width: isSmallScreen ? 50 : 60,
                height: isSmallScreen ? 50 : 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: UniversalImage(
                  imageUrl: event!.imageUrl,
                  fit: BoxFit.cover,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              SizedBox(width: isSmallScreen ? 12 : 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event!.title,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 2 : 4),
                    Text(
                      "Počinje od ${event!.price}",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: isSmallScreen ? 13 : 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: isSmallScreen ? 20 : 24),
        // Form fields
        isSmallScreen
            ? Column(
                // Stack fields vertically on mobile
                children: [
                  _buildFormField(
                    "Datum događaja",
                    eventDateController,
                    "mm/dd/yyyy",
                    isSmallScreen,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today,
                          color: Colors.deepPurple),
                      onPressed: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          eventDateController.text =
                              "${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}";
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFormField(
                    "Broj gostiju",
                    guestCountController,
                    "Unesite broj",
                    isSmallScreen,
                  ),
                ],
              )
            : Row(
                // Side by side on larger screens
                children: [
                  Expanded(
                    child: _buildFormField(
                      "Datum događaja",
                      eventDateController,
                      "mm/dd/yyyy",
                      isSmallScreen,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today,
                            color: Colors.deepPurple),
                        onPressed: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate:
                                DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) {
                            eventDateController.text =
                                "${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}";
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildFormField(
                      "Broj gostiju",
                      guestCountController,
                      "Unesite broj",
                      isSmallScreen,
                    ),
                  ),
                ],
              ),
        SizedBox(height: isSmallScreen ? 20 : 24),
        // Action buttons
        isSmallScreen
            ? Column(
                // Stack buttons vertically on mobile
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          currentView = 'reviews';
                          eventDateController.clear();
                          guestCountController.clear();
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            vertical: isSmallScreen ? 12 : 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: BorderSide(color: Colors.grey[300]!),
                        minimumSize:
                            Size(double.infinity, isSmallScreen ? 44 : 48),
                      ),
                      child: Text(
                        "Otkaži",
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _submitBooking(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                            vertical: isSmallScreen ? 12 : 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize:
                            Size(double.infinity, isSmallScreen ? 44 : 48),
                      ),
                      child: Text(
                        "Dodaj u korpu",
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Row(
                // Side by side on larger screens
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          currentView = 'reviews';
                          eventDateController.clear();
                          guestCountController.clear();
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            vertical: isSmallScreen ? 12 : 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: BorderSide(color: Colors.grey[300]!),
                        minimumSize: Size(0, isSmallScreen ? 44 : 48),
                      ),
                      child: Text(
                        "Otkaži",
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _submitBooking(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                            vertical: isSmallScreen ? 12 : 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize: Size(0, isSmallScreen ? 44 : 48),
                      ),
                      child: Text(
                        "Dodaj u korpu",
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ],
    );
  }

  Widget _buildFormField(String label, TextEditingController controller,
      String hint, bool isSmallScreen,
      {Widget? suffixIcon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: isSmallScreen ? 14 : 16,
          ),
        ),
        SizedBox(height: isSmallScreen ? 6 : 8),
        TextField(
          controller: controller,
          keyboardType: label.contains("Broj")
              ? TextInputType.number
              : TextInputType.text,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: isSmallScreen ? 14 : 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            suffixIcon: suffixIcon,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: isSmallScreen ? 12 : 16,
            ),
          ),
          style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
        ),
      ],
    );
  }

  void _submitBooking() async {
    if (eventDateController.text.isEmpty || guestCountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Molimo popunite sva polja"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Get current user data
      final user = await UserManager.loadCurrentUser();
      if (user == null) {
        throw Exception('Morate biti prijavljeni da biste dodali u korpu');
      }

      // Create a basket item (which is essentially a reservation that's not yet submitted)
      final basketItem = Reservation(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        eventId: event!.id,
        eventTitle: event!.title,
        eventImageUrl: event!.imageUrl,
        customerUsername: user.username,
        customerName: '${user.firstName} ${user.lastName}',
        eventDate: eventDateController.text,
        guestCount: guestCountController.text,
        status: 'basket', // Special status for basket items
        createdAt: DateTime.now(),
      );

      // Add to basket using EventManager
      await EventManager.addToBasket(basketItem);

      // Create notification for adding to cart
      final notification = NotificationData(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Novi događaj u korpi',
        message:
            'Dodali ste "${event!.title}" u korpu. Dovršite rezervaciju da osigurate termin.',
        type: 'added_to_cart',
        createdAt: DateTime.now(),
        eventTitle: event!.title,
      );
      await EventManager.addNotification(notification);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                "Događaj je dodat u korpu! Idite u korpu da pošaljete sve rezervacije."),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        // Clear the form and switch back to reviews
        setState(() {
          eventDateController.clear();
          guestCountController.clear();
          currentView = 'reviews';
        });

        // Optional: Navigate to basket page
        Navigator.pushNamed(context, '/basket');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Greška pri dodavanju u korpu: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _submitReview() async {
    if (userRating > 0 && reviewController.text.isNotEmpty) {
      try {
        // Get current user data
        final user = await UserManager.loadCurrentUser();
        if (user == null) {
          throw Exception(
              'Morate biti prijavljeni da biste ostavili recenziju');
        }

        // Create new review
        final review = ReviewData(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userName: '${user.firstName} ${user.lastName}',
          userImage: user.profileImagePath,
          rating: userRating,
          comment: reviewController.text,
          createdAt: DateTime.now(),
        );

        // Add review to event
        await EventManager.addReviewToEvent(event!.id, review);

        // Update local event data
        await _loadEvent();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Hvala vam na recenziji!"),
              backgroundColor: Colors.green,
            ),
          );
        }

        setState(() {
          userRating = 0;
          reviewController.clear();
          currentView = 'reviews'; // Switch back to reviews
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Greška: $e"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Molimo unesite ocenu i komentar"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day}.${date.month}.${date.year}";
  }
}
