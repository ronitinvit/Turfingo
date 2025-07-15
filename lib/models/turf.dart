class Turf {
  final String id;
  final String name;
  final String location;
  final String imageUrl;
  final String contactDetails;
  final double rating;
  final List<String> sports;
  final List<String> availableSlots;
  final List<String> amenities;
  final String groundDetails;

  Turf({
    required this.id,
    required this.name,
    required this.location,
    required this.imageUrl,
    required this.contactDetails,
    required this.rating,
    required this.sports,
    required this.availableSlots,
    required this.amenities,
    required this.groundDetails,
  });

  factory Turf.fromMap(Map<String, dynamic> map, String id) {
    List<String> parseList(String? val) {
      if (val == null || val.trim().isEmpty) return [];
      return val.split(',').map((e) => e.trim()).toList();
    }

    double parseRating(String? val) {
      if (val == null) return 0.0;
      final numeric = double.tryParse(val.split('/').first.trim());
      return numeric ?? 0.0;
    }

    return Turf(
      id: id,
      name: map['Ground Name'] ?? 'Unknown Turf',
      location: map['Location'] ?? 'Unknown Location',
      imageUrl: map['imageUrl'] ?? map['imageURL'] ?? '',
      contactDetails: map['Contact Details'] ?? 'Not Available',
      rating: parseRating(map['Rating']),
      sports: parseList(map['sports']),
      availableSlots: parseList(map['availableSlots']),
      amenities: parseList(map['amenities']),
      groundDetails: map['groundDetails'] ?? map['Ground Details'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'Ground Name': name,
      'Location': location,
      'imageUrl': imageUrl,
      'Contact Details': contactDetails,
      'Rating': '$rating/5',
      'sports': sports.join(','),
      'availableSlots': availableSlots.join(','),
      'amenities': amenities.join(','),
      'groundDetails': groundDetails,
    };
  }
}
