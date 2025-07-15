import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Booking History"),
        backgroundColor: Colors.green[700],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          HistoryTile(
            turfName: "ON Drive",
            date: "June 10, 2025",
            slot: "6:00 AM - 7:00 AM",
          ),
          HistoryTile(
            turfName: "Game On",
            date: "May 28, 2025",
            slot: "8:00 PM - 9:00 PM",
          ),
        ],
      ),
    );
  }
}

class HistoryTile extends StatelessWidget {
  final String turfName;
  final String date;
  final String slot;

  const HistoryTile({
    super.key,
    required this.turfName,
    required this.date,
    required this.slot,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      leading: const Icon(Icons.history, color: Colors.grey),
      title: Text(turfName),
      subtitle: Text("Date: $date\nSlot: $slot"),
      isThreeLine: true,
    );
  }
}
