import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import '../widgets/common_header.dart';
import '../widgets/universal_image.dart';
import '../models/event_models.dart';

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({super.key});

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  List<EventData> eventTypes = [];
  EventData? selectedEventType;
  String? customImageBase64;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEventTypes();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _loadEventTypes() async {
    try {
      final loadedEventTypes = await EventManager.loadEvents();
      setState(() {
        eventTypes = loadedEventTypes;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        eventTypes = [];
        isLoading = false;
      });
    }
  }

  Future<void> _createEvent() async {
    if (!_formKey.currentState!.validate() ||
        (selectedEventType == null && customImageBase64 == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Molim popunite sva polja i odaberite sliku događaja')),
      );
      return;
    }

    try {
      String imageUrl;
      if (customImageBase64 != null) {
        // Use custom uploaded image
        imageUrl = 'base64:$customImageBase64';
      } else {
        // Use selected event type image
        imageUrl = selectedEventType!.imageUrl;
      }

      final newEvent = EventData(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        imageUrl: imageUrl,
        price: _priceController.text.trim(),
        reviews: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save the event using EventManager
      final events = await EventManager.loadEvents();
      events.add(newEvent);
      await EventManager.saveEvents(events);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Događaj je uspešno kreiran!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Greška pri kreiranju događaja'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickCustomImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        final base64String = base64Encode(bytes);

        setState(() {
          customImageBase64 = base64String;
          selectedEventType = null; // Clear predefined selection
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Greška pri odabiru slike: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonHeader(currentPage: 'create_event'),
      body: Column(
        children: [
          const PurpleDivider(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 600),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withValues(alpha: 0.1),
                              spreadRadius: 0,
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(32),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header
                              const Text(
                                'Dodaj novi događaj',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Select Event Image Section
                              const Text(
                                'Izaberite sliku događaja',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Event Type Selection Grid
                              if (eventTypes.isNotEmpty) ...[
                                SizedBox(
                                  height: 120,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: eventTypes.length + 1,
                                    itemBuilder: (context, index) {
                                      if (index == eventTypes.length) {
                                        // Upload New option
                                        return Container(
                                          width: 100,
                                          margin:
                                              const EdgeInsets.only(right: 16),
                                          child: GestureDetector(
                                            onTap: _pickCustomImage,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: customImageBase64 != null
                                                    ? Colors.blue.shade50
                                                    : Colors.grey.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: customImageBase64 !=
                                                          null
                                                      ? Colors.blue
                                                      : Colors.grey.shade300,
                                                  width:
                                                      customImageBase64 != null
                                                          ? 3
                                                          : 2,
                                                ),
                                              ),
                                              child: customImageBase64 != null
                                                  ? Column(
                                                      children: [
                                                        Expanded(
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                const BorderRadius
                                                                    .only(
                                                              topLeft: Radius
                                                                  .circular(12),
                                                              topRight: Radius
                                                                  .circular(12),
                                                            ),
                                                            child: Image.memory(
                                                              base64Decode(
                                                                  customImageBase64!),
                                                              width: double
                                                                  .infinity,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ),
                                                        Container(
                                                          width:
                                                              double.infinity,
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 8),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors
                                                                .blue.shade50,
                                                            borderRadius:
                                                                const BorderRadius
                                                                    .only(
                                                              bottomLeft: Radius
                                                                  .circular(12),
                                                              bottomRight:
                                                                  Radius
                                                                      .circular(
                                                                          12),
                                                            ),
                                                          ),
                                                          child: const Text(
                                                            'Prilagođena',
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color:
                                                                  Colors.blue,
                                                            ),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  : Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .add_photo_alternate,
                                                          size: 32,
                                                          color: Colors
                                                              .grey.shade600,
                                                        ),
                                                        const SizedBox(
                                                            height: 8),
                                                        Text(
                                                          'Dodaj sliku',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors
                                                                .grey.shade600,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ],
                                                    ),
                                            ),
                                          ),
                                        );
                                      }

                                      final eventType = eventTypes[index];
                                      final isSelected =
                                          selectedEventType?.id == eventType.id;

                                      return Container(
                                        width: 100,
                                        margin:
                                            const EdgeInsets.only(right: 16),
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              selectedEventType = eventType;
                                              customImageBase64 =
                                                  null; // Clear custom image
                                            });
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: isSelected
                                                    ? Colors.blue
                                                    : Colors.grey.shade300,
                                                width: isSelected ? 3 : 1,
                                              ),
                                            ),
                                            child: Column(
                                              children: [
                                                Expanded(
                                                  child: UniversalImage(
                                                    imageUrl:
                                                        eventType.imageUrl,
                                                    width: double.infinity,
                                                    fit: BoxFit.cover,
                                                    borderRadius:
                                                        const BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(12),
                                                      topRight:
                                                          Radius.circular(12),
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  width: double.infinity,
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 8),
                                                  decoration: BoxDecoration(
                                                    color: isSelected
                                                        ? Colors.blue.shade50
                                                        : Colors.white,
                                                    borderRadius:
                                                        const BorderRadius.only(
                                                      bottomLeft:
                                                          Radius.circular(12),
                                                      bottomRight:
                                                          Radius.circular(12),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    eventType.title,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: isSelected
                                                          ? Colors.blue
                                                          : Colors.black87,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ] else ...[
                                Container(
                                  height: 120,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.image_not_supported,
                                        size: 48,
                                        color: Colors.grey.shade500,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Nema dostupnih tipova događaja',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              const SizedBox(height: 32),

                              // Event Name
                              const Text(
                                'Naziv događaja',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  hintText: 'Unesite naziv događaja',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade300),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade300),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                        color: Colors.blue, width: 2),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Molim unesite naziv događaja';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),

                              // Description
                              const Text(
                                'Opis',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _descriptionController,
                                maxLines: 4,
                                decoration: InputDecoration(
                                  hintText: 'Unesite opis događaja',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade300),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade300),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                        color: Colors.blue, width: 2),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Molim unesite opis događaja';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),

                              // Price
                              const Text(
                                'Cena',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _priceController,
                                decoration: InputDecoration(
                                  hintText: 'Unesite cenu',
                                  prefixText: '€ ',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade300),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade300),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                        color: Colors.blue, width: 2),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Molim unesite cenu';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 32),

                              // Action buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        side: BorderSide(
                                            color: Colors.grey.shade400),
                                      ),
                                      child: const Text(
                                        'Otkaži',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: _createEvent,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        elevation: 2,
                                      ),
                                      child: const Text(
                                        'Dodaj događaj',
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
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
