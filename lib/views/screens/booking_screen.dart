import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BookingScreen extends StatelessWidget {
  const BookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Fetch bookings dynamically
    final bookingsStream = FirebaseFirestore.instance
        .collection('bookings')
        .orderBy('timestamp', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Bookings"),
        backgroundColor: Colors.green[700],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: bookingsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading bookings"));
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text("No bookings yet."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final booking = docs[i];
              final data = booking.data() as Map<String, dynamic>;
              final turfName = data['turfName'] ?? 'Unknown Turf';
              final slot = data['slot'] ?? 'Unknown Slot';
              final timestamp = data['timestamp'] as Timestamp?;
              final date = timestamp?.toDate() ?? DateTime.now();

              return BookingTile(
                turfName: turfName,
                slot: slot,
                date: DateFormat('MMM dd, yyyy – hh:mm a').format(date),
              );
            },
          );
        },
      ),
    );
  }
}

class BookingTile extends StatelessWidget {
  final String turfName;
  final String slot;
  final String date;

  const BookingTile({
    super.key,
    required this.turfName,
    required this.slot,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.sports_soccer, color: Colors.green),
        title: Text(turfName),
        subtitle: Text("$date\nSlot: $slot"),
        isThreeLine: true,
      ),
    );
  }
}
