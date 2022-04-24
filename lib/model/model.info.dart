import 'package:http/http.dart';

class Pexel {
  final String url, photographer, original, portrait, alt;

  Pexel({
    required this.url,
    required this.photographer,
    required this.original,
    required this.portrait,
    required this.alt,
  });

  Map<String, Object> toMap(Pexel pexel) {
    return {
      'original': pexel.original,
      'portrait': pexel.portrait,
      'photographer': pexel.photographer,
      'alt': pexel.alt,
    };
  }

  factory Pexel.toMap(Map<String, dynamic> map,) {
    return Pexel(
      url: map['url'],
      photographer: map['photographer'],
      original: map['src']['original'],
      portrait: map['src']['portrait'],
      alt: map['alt'],
    );
  }
}
