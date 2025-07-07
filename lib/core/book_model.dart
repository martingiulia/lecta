import 'dart:convert';

import 'package:http/http.dart' as http;

class Book {
  final String id;
  final String title;
  final String author;
  final String description;
  final String coverUrl;
  final double rating;
  final int pages;
  final String? publisher;
  final String? isbn;
  final String? language;
  final List<String> genres; // Cambiato da String? a List<String>

  final DateTime? publishDate;
  final DateTime? finishedDate;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.coverUrl,
    required this.rating,
    required this.pages,
    required this.publisher,
    required this.isbn,
    required this.language,
    required this.genres, // Cambiato da genre a genres
    required this.publishDate,
    this.finishedDate,
  });

  // Getter per compatibilità con il codice esistente
  String? get genre => genres.isNotEmpty ? genres.first : null;

  // Funzione helper per ottenere solo il cognome
  String get lastName {
    final nameParts = author.trim().split(' ');
    return nameParts.isNotEmpty ? nameParts.last : author;
  }

  factory Book.fromGoogleBooks(Map<String, dynamic> item) {
    final volumeInfo = item['volumeInfo'] ?? {};
    final imageLinks = volumeInfo['imageLinks'] ?? {};
    final industryIdentifiers = volumeInfo['industryIdentifiers'] as List?;

    String? isbn;
    if (industryIdentifiers != null) {
      for (var identifier in industryIdentifiers) {
        if (identifier['type'] == 'ISBN_13' ||
            identifier['type'] == 'ISBN_10') {
          isbn = identifier['identifier'];
          break;
        }
      }
    }

    return Book(
      id: item['id'] ?? '',
      title: volumeInfo['title'] ?? 'Senza titolo',
      author:
          (volumeInfo['authors'] as List?)?.join(', ') ?? 'Autore sconosciuto',
      description:
          volumeInfo['description'] ?? 'Nessuna descrizione disponibile',
      coverUrl: imageLinks['thumbnail']?.replaceAll('http:', 'https:') ?? '',
      rating: (volumeInfo['averageRating'] ?? 0).toDouble(),
      pages: volumeInfo['pageCount'] ?? 0,
      publisher: volumeInfo['publisher'],
      isbn: isbn,
      language: volumeInfo['language'],
      genres: _extractGenres(volumeInfo['categories'] as List?),
      publishDate: volumeInfo['publishedDate'] != null
          ? _parseDate(volumeInfo['publishedDate'])
          : null,
      finishedDate: null,
    );
  }

  static List<String> _extractGenres(List<dynamic>? categories) {
    if (categories == null || categories.isEmpty) return [];

    final Set<String> extractedGenres = {};

    for (final category in categories) {
      final categoryStr = category as String;
      final parts = categoryStr.split('/').map((part) => part.trim()).toList();

      for (final part in parts) {
        // Filtra "General" e parti troppo corte o vuote
        if (part.isNotEmpty &&
            part.toLowerCase() != 'general' &&
            part.length > 2) {
          extractedGenres.add(part);
        }
      }
    }

    return extractedGenres.toList();
  }

  static DateTime? _parseDate(String dateString) {
    try {
      if (dateString.length == 4) {
        return DateTime(int.parse(dateString));
      } else if (dateString.length == 7) {
        return DateTime.parse('$dateString-01');
      } else {
        return DateTime.parse(dateString);
      }
    } catch (_) {
      return null;
    }
  }

  static Future<List<Book>> getBooksByAuthor(
    String authorName, {
    String? excludeBookId,
  }) async {
    try {
      final cleanAuthorName = authorName.trim().replaceAll(' ', '+');

      final response = await http.get(
        Uri.parse(
          'https://www.googleapis.com/books/v1/volumes?q=inauthor:"$cleanAuthorName"&maxResults=10',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> items = data['items'] ?? [];

        List<Book> books = items
            .map((item) => Book.fromGoogleBooks(item))
            .toList();

        if (excludeBookId != null) {
          books = books.where((book) => book.id != excludeBookId).toList();
        }

        final uniqueBooks = <String, Book>{};
        for (final book in books) {
          final key = book.title.toLowerCase().trim();
          if (!uniqueBooks.containsKey(key)) {
            uniqueBooks[key] = book;
          }
        }

        return uniqueBooks.values.toList();
      } else {
        throw Exception(
          'Errore nella ricerca per autore: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Errore di connessione nella ricerca per autore: $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'description': description,
      'coverUrl': coverUrl,
      'rating': rating,
      'pages': pages,
      'publisher': publisher,
      'isbn': isbn,
      'language': language,
      'genres': genres, // Cambiato da genre a genres
      'publishDate': publishDate?.toIso8601String(),
      'finishedDate': finishedDate?.toIso8601String(),
    };
  }

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      description: json['description'] ?? '',
      coverUrl: json['coverUrl'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      pages: json['pages'] ?? 0,
      publisher: json['publisher'],
      isbn: json['isbn'],
      language: json['language'],
      genres: json['genres'] != null
          ? List<String>.from(json['genres'])
          : (json['genre'] != null
                ? [json['genre']]
                : []), // Compatibilità backward
      publishDate: json['publishDate'] != null && json['publishDate'] != ''
          ? DateTime.tryParse(json['publishDate'])
          : null,
      finishedDate: json['finishedDate'] != null && json['finishedDate'] != ''
          ? DateTime.tryParse(json['finishedDate'])
          : null,
    );
  }
}
