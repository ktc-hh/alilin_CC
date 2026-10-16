/// A single pin (image post) in Pinly.
class Pin {
  final String id;
  final String title;
  final String description;
  final String author;
  final String imageUrl;

  /// width / height — used to build the staggered (Pinterest-style) layout.
  final double aspectRatio;

  const Pin({
    required this.id,
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.aspectRatio,
    this.description = '',
  });

  /// Builds a Pin from the Picsum Photos API response.
  /// Example item: {"id":"10","author":"Paul Jarvis","width":2500,"height":1667,...}
  factory Pin.fromApi(Map<String, dynamic> json) {
    final id = json['id'].toString();
    final w = (json['width'] as num).toDouble();
    final h = (json['height'] as num).toDouble();
    final ratio = (w / h).clamp(0.6, 1.3).toDouble();
    final requestedHeight = (600 / ratio).round();

    return Pin(
      id: id,
      title: 'Photo by ${json['author']}',
      author: json['author'] as String,
      description:
          'A beautiful photo shared by ${json['author']}. Save it to your '
          'Pinly collection for inspiration later.',
      imageUrl: 'https://picsum.photos/id/$id/600/$requestedHeight',
      aspectRatio: ratio,
    );
  }

  factory Pin.fromJson(Map<String, dynamic> json) => Pin(
        id: json['id'] as String,
        title: json['title'] as String,
        description: (json['description'] as String?) ?? '',
        author: json['author'] as String,
        imageUrl: json['imageUrl'] as String,
        aspectRatio: (json['aspectRatio'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'author': author,
        'imageUrl': imageUrl,
        'aspectRatio': aspectRatio,
      };
}
