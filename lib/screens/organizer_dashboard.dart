import 'package:flutter/material.dart';
import 'package:moments_to_remember/widgets/universal_image.dart';
import '../models/event_models.dart';
import '../widgets/common_header.dart';

class OrganizerDashboard extends StatefulWidget {
  const OrganizerDashboard({super.key});

  @override
  State<OrganizerDashboard> createState() => _OrganizerDashboardState();
}

class _OrganizerDashboardState extends State<OrganizerDashboard> {
  List<EventData> events = [];
  List<Reservation> pendingAppointments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      // Load events
      final loadedEvents = await EventManager.loadEvents();

      // Load pending reservations
      final loadedReservations = await EventManager.getPendingReservations();

      setState(() {
        events = loadedEvents;
        pendingAppointments = loadedReservations;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error loading dashboard data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final isMediumScreen = screenWidth < 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F3FF),
      appBar: const CommonHeader(currentPage: 'organizer_dashboard'),
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
                : SingleChildScrollView(
                    padding: EdgeInsets.all(isSmallScreen ? 16.0 : 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Welcome header
                        _buildWelcomeHeader(isSmallScreen),
                        const SizedBox(height: 32),

                        // Statistics cards
                        _buildStatisticsCards(isSmallScreen, isMediumScreen),
                        const SizedBox(height: 32),

                        // Pending appointments section
                        _buildPendingAppointments(isSmallScreen),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16.0 : 24.0),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.dashboard,
              color: Colors.deepPurple,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Organizator Dashboard',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 20 : 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Upravljajte događajima i rezervacijama',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards(bool isSmallScreen, bool isMediumScreen) {
    final stats = [
      {
        'title': 'Događaji danas',
        'value': '3',
        'icon': Icons.event,
        'color': Colors.blue,
      },
      {
        'title': 'Zahtevi na čekanju',
        'value': '${pendingAppointments.length}',
        'icon': Icons.pending_actions,
        'color': Colors.orange,
      },
      {
        'title': 'Događaji ovog meseca',
        'value': '24',
        'icon': Icons.trending_up,
        'color': Colors.green,
      },
    ];

    if (isSmallScreen) {
      return Column(
        children: stats
            .map(
              (stat) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildStatCard(stat, isSmallScreen),
              ),
            )
            .toList(),
      );
    } else {
      return Row(
        children: stats
            .map(
              (stat) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: _buildStatCard(stat, isSmallScreen),
                ),
              ),
            )
            .toList(),
      );
    }
  }

  Widget _buildStatCard(Map<String, dynamic> stat, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (stat['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  stat['icon'] as IconData,
                  color: stat['color'] as Color,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            stat['value'] as String,
            style: TextStyle(
              fontSize: isSmallScreen ? 24 : 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            stat['title'] as String,
            style: TextStyle(
              fontSize: isSmallScreen ? 12 : 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingAppointments(bool isSmallScreen) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
            child: Text(
              'Zahtevi na čekanju',
              style: TextStyle(
                fontSize: isSmallScreen ? 18 : 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          if (pendingAppointments.isEmpty)
            Padding(
              padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nema novih zahteva',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 16 : 18,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            // Appointments table
            _buildAppointmentsTable(isSmallScreen),
        ],
      ),
    );
  }

  Widget _buildAppointmentsTable(bool isSmallScreen) {
    if (isSmallScreen) {
      // Mobile card layout
      return Column(
        children: pendingAppointments
            .map(
              (appointment) =>
                  _buildAppointmentCard(appointment, isSmallScreen),
            )
            .toList(),
      );
    } else {
      // Desktop table layout
      return Column(
        children: [
          // Table header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: const Row(
              children: [
                Expanded(
                    flex: 2,
                    child: Text('Događaj',
                        style: TextStyle(fontWeight: FontWeight.w600))),
                Expanded(
                    flex: 2,
                    child: Text('Korisnik',
                        style: TextStyle(fontWeight: FontWeight.w600))),
                Expanded(
                    flex: 2,
                    child: Text('Datum',
                        style: TextStyle(fontWeight: FontWeight.w600))),
                Expanded(
                    flex: 1,
                    child: Text('Gosti',
                        style: TextStyle(fontWeight: FontWeight.w600))),
                Expanded(
                    flex: 2,
                    child: Text('Akcije',
                        style: TextStyle(fontWeight: FontWeight.w600))),
              ],
            ),
          ),
          // Table rows
          ...pendingAppointments
              .map(
                (appointment) => _buildAppointmentRow(appointment),
              )
              .toList(),
        ],
      );
    }
  }

  Widget _buildAppointmentCard(Reservation appointment, bool isSmallScreen) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
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
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: UniversalImage(
                    imageUrl: appointment.eventImageUrl,
                    fit: BoxFit.cover,
                    // errorBuilder: (context, error, stackTrace) {
                    //   return Container(
                    //     color: Colors.grey[300],
                    //     child: const Icon(Icons.image, color: Colors.grey),
                    //   );
                    // },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.eventTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      appointment.customerName,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(appointment.eventDate,
                  style: TextStyle(color: Colors.grey[600])),
              const SizedBox(width: 16),
              Icon(Icons.people, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text('${appointment.guestCount} gostiju',
                  style: TextStyle(color: Colors.grey[600])),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _acceptAppointment(appointment),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Prihvati'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _rejectAppointment(appointment),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Odbaci'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentRow(Reservation appointment) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: UniversalImage(
                      imageUrl: appointment.eventImageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(appointment.eventTitle),
              ],
            ),
          ),
          Expanded(flex: 2, child: Text(appointment.customerName)),
          Expanded(flex: 2, child: Text(appointment.eventDate)),
          Expanded(flex: 1, child: Text(appointment.guestCount)),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () => _acceptAppointment(appointment),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: const Size(60, 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text('Prihvati', style: TextStyle(fontSize: 12)),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => _rejectAppointment(appointment),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: const Size(60, 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text('Odbaci', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _acceptAppointment(Reservation appointment) async {
    try {
      // Update reservation status to confirmed
      await EventManager.updateReservationStatus(appointment.id, 'confirmed');

      // Create notification for customer
      await EventManager.createReservationStatusNotification(
        appointment.customerUsername,
        appointment.eventTitle,
        'confirmed',
        appointment.id,
      );

      // Remove from pending list
      setState(() {
        pendingAppointments.removeWhere((a) => a.id == appointment.id);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Prihvaćen zahtev za ${appointment.customerName}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Greška pri prihvatanju zahteva: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _rejectAppointment(Reservation appointment) async {
    try {
      // Update reservation status to cancelled
      await EventManager.updateReservationStatus(appointment.id, 'cancelled');

      // Create notification for customer
      await EventManager.createReservationStatusNotification(
        appointment.customerUsername,
        appointment.eventTitle,
        'cancelled',
        appointment.id,
      );

      // Remove from pending list
      setState(() {
        pendingAppointments.removeWhere((a) => a.id == appointment.id);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Odbačen zahtev za ${appointment.customerName}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Greška pri odbacivanju zahteva: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
