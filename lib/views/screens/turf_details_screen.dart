import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/turf.dart';

class TurfDetailsScreen extends StatefulWidget {
  final Turf turf;

  const TurfDetailsScreen({super.key, required this.turf});

  @override
  State<TurfDetailsScreen> createState() => _TurfDetailsScreenState();
}

class _TurfDetailsScreenState extends State<TurfDetailsScreen> {
  String? selectedSlot;
  DateTime selectedDate = DateTime.now();
  Set<String> bookedSlots = {};

  @override
  void initState() {
    super.initState();
    _fetchBookedSlots();
  }

  Future<void> _fetchBookedSlots() async {
    final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
    final snapshot = await FirebaseFirestore.instance
        .collection('turfs')
        .doc(widget.turf.id)
        .collection('bookings')
        .where('date', isEqualTo: dateStr)
        .get();

    final booked = snapshot.docs.map((doc) => doc['slot'] as String).toSet();

    setState(() {
      bookedSlots = booked;
      selectedSlot = null; // Reset slot on date change
    });
  }

  Future<void> bookSlot(String turfId, String turfName, String slot) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You must be logged in to book a slot.")),
      );
      return;
    }

    final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
    final bookingRef = FirebaseFirestore.instance
        .collection('turfs')
        .doc(turfId)
        .collection('bookings');

    final existing = await bookingRef
        .where('date', isEqualTo: dateStr)
        .where('slot', isEqualTo: slot)
        .get();

    if (existing.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ This slot is already booked.")),
      );
      return;
    }

    await bookingRef.add({
      'userId': user.uid,
      'userName': user.displayName ?? 'Anonymous',
      'turfName': turfName,
      'slot': slot,
      'date': dateStr,
      'timestamp': FieldValue.serverTimestamp(),
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Booking Confirmed"),
        content: Text(
          "You have booked $turfName at $slot on $dateStr.",
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _fetchBookedSlots(); // refresh UI
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      _fetchBookedSlots();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Turf turf = widget.turf;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(turf.name,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
        backgroundColor: Colors.green[700],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🌄 Turf Image
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                turf.imageUrl,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 220,
                  color: Colors.grey[200],
                  alignment: Alignment.center,
                  child: const Text('Image not available'),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 📍 Location & Rating
            _infoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle("Location", icon: Icons.location_on),
                  Row(
                    children: [
                      Expanded(
                        child: Text(turf.location,
                            style: GoogleFonts.poppins(fontSize: 14)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.map, color: Colors.blue),
                        onPressed: () {
                          final query =
                              Uri.encodeComponent(turf.location.trim());
                          launchUrl(Uri.parse(
                              'https://www.google.com/maps/search/?api=1&query=$query'));
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _sectionTitle("Rating", icon: Icons.star),
                  Text("${turf.rating.toStringAsFixed(1)} / 5",
                      style: GoogleFonts.poppins(fontSize: 14)),
                ],
              ),
            ),

            if (turf.availableSlots.isNotEmpty)
              _infoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle("Select Date", icon: Icons.calendar_today),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _pickDate,
                          icon: const Icon(Icons.date_range),
                          label: Text(
                            DateFormat('EEE, MMM d').format(selectedDate),
                            style: GoogleFonts.poppins(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _sectionTitle("Available Slots", icon: Icons.access_time),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: turf.availableSlots.map((slot) {
                        final isBooked = bookedSlots.contains(slot);
                        final isSelected = selectedSlot == slot;
                        return Opacity(
                          opacity: isBooked ? 0.5 : 1.0,
                          child: GestureDetector(
                            onTap: isBooked
                                ? null
                                : () => setState(() => selectedSlot = slot),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.green.shade600
                                    : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                slot,
                                style: GoogleFonts.poppins(
                                  color:
                                      isSelected ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: selectedSlot == null
                            ? null
                            : () => bookSlot(turf.id, turf.name, selectedSlot!),
                        icon: const Icon(Icons.check_circle),
                        label: Text(
                          "Book Slot",
                          style: GoogleFonts.poppins(
                              fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
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
    );
  }

  Widget _infoCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionTitle(String text, {IconData? icon}) {
    return Row(
      children: [
        if (icon != null) Icon(icon, size: 20, color: Colors.green[800]),
        if (icon != null) const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }
}
