import 'package:flutter/material.dart';
import '../../models/turf.dart';

class TurfCard extends StatelessWidget {
  final Turf turf;

  const TurfCard({super.key, required this.turf});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      elevation: 5,
      child: ListTile(
        leading: Image.network(
          turf.imageUrl,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
        ),
        title: Text(turf.name),
        subtitle: Text('${turf.location} | ⭐ ${turf.rating}'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.pushNamed(context, '/turf-details');
        },
      ),
    );
  }
}
