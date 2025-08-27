import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ReviewData {
  final String id;
  final String userName;
  final String userImage;
  final int rating;
  final String comment;
  final DateTime createdAt;

  ReviewData({
    required this.id,
    required this.userName,
    required this.userImage,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'userImage': userImage,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create from JSON
  factory ReviewData.fromJson(Map<String, dynamic> json) {
    return ReviewData(
      id: json['id'] ?? '',
      userName: json['userName'] ?? '',
      userImage: json['userImage'] ?? 'assets/images/profile_img.png',
      rating: json['rating'] ?? 0,
      comment: json['comment'] ?? '',
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class EventData {
  final String id;
  String title;
  String description;
  String imageUrl;
  String price;
  List<ReviewData> reviews;
  final DateTime createdAt;
  DateTime updatedAt;

  EventData({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.reviews,
    required this.createdAt,
    required this.updatedAt,
  });

  // Calculate average rating
  double get rating {
    if (reviews.isEmpty) return 0.0;
    final sum = reviews.fold(0, (prev, review) => prev + review.rating);
    return sum / reviews.length;
  }

  // Get review count
  int get reviewCount => reviews.length;

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'price': price,
      'reviews': reviews.map((review) => review.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create from JSON
  factory EventData.fromJson(Map<String, dynamic> json) {
    return EventData(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      price: json['price'] ?? '',
      reviews: (json['reviews'] as List?)
              ?.map((reviewJson) => ReviewData.fromJson(reviewJson))
              .toList() ??
          [],
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Update event information
  void updateInfo({
    String? title,
    String? description,
    String? imageUrl,
    String? price,
  }) {
    if (title != null) this.title = title;
    if (description != null) this.description = description;
    if (imageUrl != null) this.imageUrl = imageUrl;
    if (price != null) this.price = price;
    updatedAt = DateTime.now();
  }

  // Add review
  void addReview(ReviewData review) {
    reviews.add(review);
    updatedAt = DateTime.now();
  }

  // Remove review
  void removeReview(String reviewId) {
    reviews.removeWhere((review) => review.id == reviewId);
    updatedAt = DateTime.now();
  }
}

// Reservation class to track customer bookings
class Reservation {
  final String id;
  final String eventId;
  final String eventTitle;
  final String eventImageUrl;
  final String customerUsername;
  final String customerName;
  final String eventDate;
  final String guestCount;
  final String status; // 'pending', 'confirmed', 'cancelled'
  final DateTime createdAt;

  Reservation({
    required this.id,
    required this.eventId,
    required this.eventTitle,
    required this.eventImageUrl,
    required this.customerUsername,
    required this.customerName,
    required this.eventDate,
    required this.guestCount,
    this.status = 'pending',
    required this.createdAt,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventId': eventId,
      'eventTitle': eventTitle,
      'eventImageUrl': eventImageUrl,
      'customerUsername': customerUsername,
      'customerName': customerName,
      'eventDate': eventDate,
      'guestCount': guestCount,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create from JSON
  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'] ?? '',
      eventId: json['eventId'] ?? '',
      eventTitle: json['eventTitle'] ?? '',
      eventImageUrl: json['eventImageUrl'] ?? '',
      customerUsername: json['customerUsername'] ?? '',
      customerName: json['customerName'] ?? '',
      eventDate: json['eventDate'] ?? '',
      guestCount: json['guestCount'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Create a copy with updated status
  Reservation copyWith({String? status}) {
    return Reservation(
      id: id,
      eventId: eventId,
      eventTitle: eventTitle,
      eventImageUrl: eventImageUrl,
      customerUsername: customerUsername,
      customerName: customerName,
      eventDate: eventDate,
      guestCount: guestCount,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}

// Notification class to handle customer notifications
class NotificationData {
  final String id;
  final String title;
  final String message;
  final String type; // 'approved', 'declined', 'added_to_cart'
  final DateTime createdAt;
  final bool isRead;
  final String? reservationId;
  final String? eventTitle;

  NotificationData({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.reservationId,
    this.eventTitle,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'reservationId': reservationId,
      'eventTitle': eventTitle,
    };
  }

  // Create from JSON
  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? '',
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      isRead: json['isRead'] ?? false,
      reservationId: json['reservationId'],
      eventTitle: json['eventTitle'],
    );
  }

  // Create a copy with updated fields
  NotificationData copyWith({bool? isRead}) {
    return NotificationData(
      id: id,
      title: title,
      message: message,
      type: type,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
      reservationId: reservationId,
      eventTitle: eventTitle,
    );
  }
}

// Event management class
class EventManager {
  static const String _eventsKey = 'events_data';
  static const String _basketKey = 'basket_data';
  static const String _reservationsKey = 'reservations_data';
  static const String _notificationsKey = 'notifications_data';

  // Save all events to SharedPreferences
  static Future<void> saveEvents(List<EventData> events) async {
    final prefs = await SharedPreferences.getInstance();
    final eventsJson = events.map((event) => event.toJson()).toList();
    await prefs.setString(_eventsKey, jsonEncode(eventsJson));
  }

  // Load all events from SharedPreferences
  static Future<List<EventData>> loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final eventsString = prefs.getString(_eventsKey);

    if (eventsString != null) {
      final eventsJson = jsonDecode(eventsString) as List;
      return eventsJson.map((json) => EventData.fromJson(json)).toList();
    }

    // Return default events if no data found
    return _getDefaultEvents();
  }

  // Get default events (initial data)
  static List<EventData> _getDefaultEvents() {
    return [
      EventData(
        id: '1',
        title: 'Rođendan u prirodi',
        description:
            'Organizujemo nezaboravan rođendan na otvorenom sa svim potrebnim sadržajima.',
        imageUrl:
            'https://images.unsplash.com/photo-1530103862676-de8c9debad1d?auto=format&fit=crop&w=800&q=80',
        price: '15.000 RSD',
        reviews: [
          ReviewData(
            id: '1',
            userName: 'Marija Petrović',
            userImage: 'assets/images/profile_img.png',
            rating: 5,
            comment: 'Fantastično iskustvo! Sve je bilo savršeno organizovano.',
            createdAt: DateTime.now().subtract(const Duration(days: 5)),
          ),
          ReviewData(
            id: '2',
            userName: 'Stefan Nikolić',
            userImage: 'assets/images/profile_img.png',
            rating: 4,
            comment: 'Odličan događaj, preporučujem svima!',
            createdAt: DateTime.now().subtract(const Duration(days: 3)),
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      EventData(
        id: '2',
        title: 'Svadba iz snova',
        description:
            'Kompletna organizacija svadbe sa dekoracijom, hranom i muzikom.',
        imageUrl:
            'https://images.unsplash.com/photo-1519741497674-611481863552?auto=format&fit=crop&w=800&q=80',
        price: '150.000 RSD',
        reviews: [
          ReviewData(
            id: '3',
            userName: 'Ana Jovanović',
            userImage: 'assets/images/profile_img.png',
            rating: 5,
            comment: 'Naša svadba je bila magična, hvala vam!',
            createdAt: DateTime.now().subtract(const Duration(days: 10)),
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        updatedAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      EventData(
        id: '3',
        title: 'Korporativni događaj',
        description:
            'Profesionalna organizacija poslovnih događaja i konferencija.',
        imageUrl:
            'https://images.unsplash.com/photo-1511578314322-379afb476865?auto=format&fit=crop&w=800&q=80',
        price: '50.000 RSD',
        reviews: [],
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      EventData(
        id: '4',
        title: 'Dečiji party',
        description: 'Zabavan rođendan za decu sa animatorima i igrama.',
        imageUrl:
            'https://images.unsplash.com/photo-1513475382585-d06e58bcb0e0?auto=format&fit=crop&w=800&q=80',
        price: '8.000 RSD',
        reviews: [
          ReviewData(
            id: '4',
            userName: 'Milica Stojanović',
            userImage: 'assets/images/profile_img.png',
            rating: 5,
            comment: 'Deca su bila oduševljena! Odličan tim.',
            createdAt: DateTime.now().subtract(const Duration(days: 2)),
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      EventData(
        id: '5',
        title: 'Konzert na otvorenom',
        description:
            'Organizacija muzičkih koncerata i festivala sa kompletnom opremom.',
        imageUrl:
            'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?auto=format&fit=crop&w=800&q=80',
        price: '80.000 RSD',
        reviews: [
          ReviewData(
            id: '5',
            userName: 'Petar Jovanović',
            userImage: 'assets/images/profile_img.png',
            rating: 5,
            comment: 'Neverojatn zvuk i atmosfera! Preporučujem svima.',
            createdAt: DateTime.now().subtract(const Duration(days: 7)),
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
        updatedAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
      EventData(
        id: '6',
        title: 'Proslava godišnjice',
        description: 'Elegantne proslave godišnjica sa luksuznim dekoracijama.',
        imageUrl:
            'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?auto=format&fit=crop&w=800&q=80',
        price: '45.000 RSD',
        reviews: [
          ReviewData(
            id: '6',
            userName: 'Jelena Marković',
            userImage: 'assets/images/profile_img.png',
            rating: 4,
            comment: 'Prelepo organizovano! Gosti su bili oduševljeni.',
            createdAt: DateTime.now().subtract(const Duration(days: 4)),
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 18)),
        updatedAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
      EventData(
        id: '7',
        title: 'Matura party',
        description:
            'Nezaboravna maturska zabava sa DJ-em i specijalnim efektima.',
        imageUrl:
            'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?auto=format&fit=crop&w=800&q=80',
        price: '25.000 RSD',
        reviews: [
          ReviewData(
            id: '7',
            userName: 'Nikola Stojanović',
            userImage: 'assets/images/profile_img.png',
            rating: 5,
            comment: 'Najbolja matura ikad! Hvala vam puno!',
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 12)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      EventData(
        id: '8',
        title: 'Krštenje deteta',
        description:
            'Intimne proslave krštenja sa tradicionalnim ukrašavanjem.',
        imageUrl:
            'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?auto=format&fit=crop&w=800&q=80',
        price: '12.000 RSD',
        reviews: [
          ReviewData(
            id: '8',
            userName: 'Milica Radović',
            userImage: 'assets/images/profile_img.png',
            rating: 5,
            comment: 'Divno organizovano krštenje, svi su bili zadovoljni.',
            createdAt: DateTime.now().subtract(const Duration(days: 6)),
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 22)),
        updatedAt: DateTime.now().subtract(const Duration(days: 6)),
      ),
    ];
  }

  // Add new event
  static Future<void> addEvent(EventData event) async {
    final events = await loadEvents();
    events.add(event);
    await saveEvents(events);
  }

  // Update existing event
  static Future<void> updateEvent(EventData updatedEvent) async {
    final events = await loadEvents();
    final index = events.indexWhere((event) => event.id == updatedEvent.id);

    if (index != -1) {
      events[index] = updatedEvent;
      await saveEvents(events);
    }
  }

  // Delete event
  static Future<void> deleteEvent(String eventId) async {
    final events = await loadEvents();
    events.removeWhere((event) => event.id == eventId);
    await saveEvents(events);
  }

  // Get event by ID
  static Future<EventData?> getEventById(String eventId) async {
    final events = await loadEvents();
    try {
      return events.firstWhere((event) => event.id == eventId);
    } catch (e) {
      return null;
    }
  }

  // Add review to event
  static Future<void> addReviewToEvent(
      String eventId, ReviewData review) async {
    final events = await loadEvents();
    final event = events.where((e) => e.id == eventId).firstOrNull;

    if (event != null) {
      event.addReview(review);
      await saveEvents(events);
    }
  }

  // Remove review from event
  static Future<void> removeReviewFromEvent(
      String eventId, String reviewId) async {
    final events = await loadEvents();
    final event = events.where((e) => e.id == eventId).firstOrNull;

    if (event != null) {
      event.removeReview(reviewId);
      await saveEvents(events);
    }
  }

  // Reservation management

  // Save all reservations to SharedPreferences
  static Future<void> saveReservations(List<Reservation> reservations) async {
    final prefs = await SharedPreferences.getInstance();
    final reservationsJson =
        reservations.map((reservation) => reservation.toJson()).toList();
    await prefs.setString(_reservationsKey, jsonEncode(reservationsJson));
  }

  // Load all reservations from SharedPreferences
  static Future<List<Reservation>> loadReservations() async {
    final prefs = await SharedPreferences.getInstance();
    final reservationsString = prefs.getString(_reservationsKey);

    if (reservationsString != null) {
      final reservationsJson = jsonDecode(reservationsString) as List;
      return reservationsJson
          .map((json) => Reservation.fromJson(json))
          .toList();
    }

    return [];
  }

  // Add a new reservation
  static Future<void> addReservation(Reservation reservation) async {
    final reservations = await loadReservations();
    reservations.add(reservation);
    await saveReservations(reservations);
  }

  // Update reservation status
  static Future<void> updateReservationStatus(
      String reservationId, String status) async {
    final reservations = await loadReservations();
    final index = reservations.indexWhere((r) => r.id == reservationId);
    if (index != -1) {
      reservations[index] = reservations[index].copyWith(status: status);
      await saveReservations(reservations);
    }
  }

  // Get pending reservations for organizer dashboard
  static Future<List<Reservation>> getPendingReservations() async {
    final reservations = await loadReservations();
    return reservations.where((r) => r.status == 'pending').toList();
  }

  // Basket management

  static Future<List<Reservation>> loadBasket() async {
    final prefs = await SharedPreferences.getInstance();
    final basketString = prefs.getString(_basketKey);

    if (basketString != null) {
      final basketJson = jsonDecode(basketString) as List;
      return basketJson.map((json) => Reservation.fromJson(json)).toList();
    }

    return [];
  }

  static Future<void> saveBasket(List<Reservation> basketItems) async {
    final prefs = await SharedPreferences.getInstance();
    final basketJson = basketItems.map((item) => item.toJson()).toList();
    await prefs.setString(_basketKey, jsonEncode(basketJson));
  }

  static Future<void> addToBasket(Reservation reservation) async {
    final basketItems = await loadBasket();

    // Remove any existing reservation for the same event by the same user
    basketItems.removeWhere((item) =>
        item.eventId == reservation.eventId &&
        item.customerUsername == reservation.customerUsername);

    basketItems.add(reservation);
    await saveBasket(basketItems);
  }

  static Future<void> removeFromBasket(String reservationId) async {
    final basketItems = await loadBasket();
    basketItems.removeWhere((item) => item.id == reservationId);
    await saveBasket(basketItems);
  }

  static Future<List<EventData>> getBasketEvents() async {
    final basketItems = await loadBasket();
    final allEvents = await loadEvents();

    return allEvents
        .where((event) => basketItems.any((item) => item.eventId == event.id))
        .toList();
  }

  static Future<void> clearBasket() async {
    await saveBasket([]);
  }

  // New method to submit all basket items as reservations
  static Future<void> submitBasketAsReservations() async {
    final basketItems = await loadBasket();
    final currentReservations = await loadReservations();

    // Convert all basket items to pending reservations
    for (final basketItem in basketItems) {
      final reservation = Reservation(
        id: basketItem.id,
        eventId: basketItem.eventId,
        eventTitle: basketItem.eventTitle,
        eventImageUrl: basketItem.eventImageUrl,
        customerUsername: basketItem.customerUsername,
        customerName: basketItem.customerName,
        eventDate: basketItem.eventDate,
        guestCount: basketItem.guestCount,
        status: 'pending', // Change from 'basket' to 'pending'
        createdAt: basketItem.createdAt,
      );

      currentReservations.add(reservation);
    }

    // Save updated reservations and clear basket
    await saveReservations(currentReservations);
    await clearBasket();
  }

  // Notification management

  // Save all notifications to SharedPreferences
  static Future<void> saveNotifications(
      List<NotificationData> notifications) async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson =
        notifications.map((notification) => notification.toJson()).toList();
    await prefs.setString(_notificationsKey, jsonEncode(notificationsJson));
  }

  // Load all notifications from SharedPreferences
  static Future<List<NotificationData>> loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsString = prefs.getString(_notificationsKey);

    if (notificationsString != null) {
      final notificationsJson = jsonDecode(notificationsString) as List;
      return notificationsJson
          .map((json) => NotificationData.fromJson(json))
          .toList();
    }

    return [];
  }

  // Add a new notification
  static Future<void> addNotification(NotificationData notification) async {
    final notifications = await loadNotifications();
    notifications.insert(
        0, notification); // Add at the beginning for newest first
    await saveNotifications(notifications);
  }

  // Mark notification as read
  static Future<void> markNotificationAsRead(String notificationId) async {
    final notifications = await loadNotifications();
    final index = notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      notifications[index] = notifications[index].copyWith(isRead: true);
      await saveNotifications(notifications);
    }
  }

  // Mark all notifications as read
  static Future<void> markAllNotificationsAsRead() async {
    final notifications = await loadNotifications();
    final updatedNotifications =
        notifications.map((n) => n.copyWith(isRead: true)).toList();
    await saveNotifications(updatedNotifications);
  }

  // Get unread notification count
  static Future<int> getUnreadNotificationCount() async {
    final notifications = await loadNotifications();
    return notifications.where((n) => !n.isRead).length;
  }

  // Get notifications for a specific user (customer)
  static Future<List<NotificationData>> getNotificationsForUser(
      String username) async {
    final notifications = await loadNotifications();
    // For now, we'll return all notifications. In a real app, you'd filter by user
    return notifications;
  }

  // Create notification when reservation status changes
  static Future<void> createReservationStatusNotification(
      String customerUsername,
      String eventTitle,
      String status,
      String reservationId) async {
    String title, message, type;

    switch (status) {
      case 'approved':
      case 'confirmed':
        title = 'Rezervacija odobrena';
        message = 'Vaša rezervacija za "$eventTitle" je odobrena!';
        type = 'approved';
        break;
      case 'declined':
      case 'cancelled':
        title = 'Rezervacija odbijena';
        message = 'Vaša rezervacija za "$eventTitle" je odbijena.';
        type = 'declined';
        break;
      default:
        return; // Don't create notification for other statuses
    }

    final notification = NotificationData(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      type: type,
      createdAt: DateTime.now(),
      reservationId: reservationId,
      eventTitle: eventTitle,
    );

    await addNotification(notification);
  }
}

// Global variables
List<EventData> events = [];

// Initialize events data
Future<void> initializeEvents() async {
  events = await EventManager.loadEvents();
}

// For backward compatibility - EventDetailData is now just EventData
typedef EventDetailData = EventData;
