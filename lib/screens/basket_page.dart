import 'package:flutter/material.dart';
import 'package:moments_to_remember/widgets/universal_image.dart';
import '../widgets/common_header.dart';
import '../models/event_models.dart';

class BasketPage extends StatefulWidget {
  const BasketPage({super.key});

  @override
  State<BasketPage> createState() => _BasketPageState();
}

class _BasketPageState extends State<BasketPage> {
  List<Reservation> basketItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBasketItems();
  }

  Future<void> _loadBasketItems() async {
    try {
      final items = await EventManager.loadBasket();
      setState(() {
        basketItems = items;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading basket items: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _removeFromBasket(String reservationId) async {
    await EventManager.removeFromBasket(reservationId);
    _loadBasketItems(); // Reload the basket
  }

  Future<void> _submitAllReservations() async {
    try {
      await EventManager.submitBasketAsReservations();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Sve rezervacije su uspešno poslate organizatoru!"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        // Reload basket (should be empty now)
        _loadBasketItems();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Greška pri slanju rezervacija: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  double get totalAmount {
    return basketItems.fold(0.0, (sum, item) {
      // This is now more of an estimated total since we don't have actual prices per reservation
      // You might want to get the actual event and calculate based on event price
      return sum + 1000.0; // Placeholder - you'd calculate actual prices
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F3FF),
      appBar: const CommonHeader(currentPage: 'basket'),
      body: Column(
        children: [
          const PurpleDivider(),
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.deepPurple,
                    ),
                  )
                : basketItems.isEmpty
                    ? _buildEmptyBasket()
                    : _buildBasketContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyBasket() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_basket_outlined,
                size: 60,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Vaša korpa je prazna',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Dodajte događaje u korpu da biste ih rezervisali',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/events');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Pretražite događaje',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasketContent() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: basketItems.length,
            itemBuilder: (context, index) {
              final reservation = basketItems[index];
              return _buildBasketItemCard(reservation);
            },
          ),
        ),
        _buildBottomSummary(),
      ],
    );
  }

  Widget _buildBasketItemCard(Reservation reservation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: UniversalImage(
                  imageUrl: reservation.eventImageUrl,
                  fit: BoxFit.cover,
                  // errorBuilder: (context, error, stackTrace) {
                  //   return Container(
                  //     color: Colors.grey[200],
                  //     child: Icon(
                  //       Icons.image_not_supported,
                  //       color: Colors.grey[400],
                  //       size: 30,
                  //     ),
                  //   );
                  // },
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Event Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reservation.eventTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Datum: ${reservation.eventDate}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Broj gostiju: ${reservation.guestCount}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rezervisao: ${reservation.customerName}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            // Remove Button
            IconButton(
              onPressed: () => _removeFromBasket(reservation.id),
              icon: const Icon(
                Icons.remove_circle_outline,
                color: Colors.red,
              ),
              tooltip: 'Ukloni iz korpe',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ukupno stavki:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${basketItems.length} rezervacija',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/events');
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: Colors.grey[300]!),
                  ),
                  child: const Text(
                    'Nastavi kupovinu',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: basketItems.isEmpty
                      ? null
                      : () {
                          _confirmBookings();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Pošalji sve rezervacije',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmBookings() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Potvrdi rezervacije'),
          content: Text(
            'Da li ste sigurni da želite da pošaljete ${basketItems.length} rezervacija na odobrenje organizatoru?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Otkaži'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _submitAllReservations();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              child: const Text('Potvrdi'),
            ),
          ],
        );
      },
    );
  }
}
