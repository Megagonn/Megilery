import 'package:http/http.dart';

class Pexel {
  final String url, photographer, original, portrait;

  Pexel({
    required this.url,
    required this.photographer,
    required this.original,
    required this.portrait,
  });

  factory Pexel.toMap(Map<String, dynamic> map,) {
    return Pexel(
      url: map['url'],
      photographer: map['photographer'],
      original: map['src']['original'],
      portrait: map['src']['portrait'],
    );
  }
}
