import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../core/book_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collection/collection.dart';

class ReadingSession {
  final String bookId;
  final DateTime date;
  final int minutes;
  ReadingSession({
    required this.bookId,
    required this.date,
    required this.minutes,
  });
  Map<String, dynamic> toJson() => {
    'bookId': bookId,
    'date': date.toIso8601String(),
    'minutes': minutes,
  };
  factory ReadingSession.fromJson(Map<String, dynamic> json) => ReadingSession(
    bookId: json['bookId'],
    date: DateTime.parse(json['date']),
    minutes: json['minutes'],
  );
}

class BooksProvider with ChangeNotifier {
  List<Book> _books = [];
  bool _isLoading = false;
  String? _error;
  Book? _selectedBook;

  final List<Book> _currentlyReading = [];
  final List<Book> _toRead = [];
  final List<Book> _finished = [];
  final List<Book> _favorites = [];

  final Map<String, int> _customRatings = {};
  final Map<String, int> _readingPage = {};
  final Map<String, String> _customEmojis = {};
  final Map<String, String> _customComments = {};

  String? _lastReadBookId;
  DateTime? _lastReadingSession;

  final List<ReadingSession> _readingSessions = [];

  static const String baseUrl = 'https://www.googleapis.com/books/v1/volumes';

  List<Book> get books => _books;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Book? get selectedBook => _selectedBook;

  List<Book> get currentlyReading => List.unmodifiable(_currentlyReading);
  List<Book> get toRead => List.unmodifiable(_toRead);
  List<Book> get finished => List.unmodifiable(_finished);
  List<Book> get favorites => List.unmodifiable(_favorites);

  Map<String, int> get customRatings => Map.unmodifiable(_customRatings);
  String? get lastReadBookId => _lastReadBookId;
  DateTime? get lastReadingSession => _lastReadingSession;

  List<ReadingSession> get readingSessions =>
      List.unmodifiable(_readingSessions);

  int get todayMinutesRead {
    final today = DateTime.now();
    return _readingSessions
        .where(
          (s) =>
              s.date.year == today.year &&
              s.date.month == today.month &&
              s.date.day == today.day,
        )
        .fold(0, (sum, s) => sum + s.minutes);
  }

  List<String> get finishedBookCoversThisYear {
    final now = DateTime.now();
    return _finished
        .where(
          (b) => b.finishedDate != null && b.finishedDate!.year == now.year,
        )
        .map((b) => b.coverUrl)
        .toList();
  }

  Book? get lastReadBook {
    if (_lastReadBookId == null) return null;

    return _currentlyReading.firstWhereOrNull(
          (book) => book.id == _lastReadBookId,
        ) ??
        _finished.firstWhereOrNull((book) => book.id == _lastReadBookId);
  }

  // Constructor: carica dati async in init() che va chiamato dopo istanza
  BooksProvider() {
    _init();
  }

  Future<void> _init() async {
    await _loadToReadBooks();
    await _loadCurrentlyReadingBooks();
    await _loadFinishedBooks();
    await _loadReadingPages();
    await _loadLastReadBook();
    await _loadReadingSessions();
    await _loadCustomRatings();
    await _loadCustomEmojis();
    await _loadCustomComments();
    notifyListeners();
  }

  Future<void> fetchBooks() async {
    await searchBooks('bestseller');
  }

  Future<void> fetchBookById(String bookId) async {
    _setLoading(true);
    try {
      final response = await http.get(Uri.parse('$baseUrl/$bookId'));
      if (response.statusCode == 200) {
        final bookData = json.decode(response.body);
        _selectedBook = Book.fromGoogleBooks(bookData);
        _error = null;
      } else {
        _error = 'Errore nel caricamento del libro: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Errore di connessione: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> searchBooks(String query) async {
    if (query.isEmpty) {
      _books = [];
      notifyListeners();
      return;
    }
    _setLoading(true);
    try {
      final url = Uri.parse(
        '$baseUrl?q=${Uri.encodeComponent(query)}&maxResults=20',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List<dynamic>? ?? [];
        _books = items.map((item) => Book.fromGoogleBooks(item)).toList();
        _error = null;
      } else {
        _error = 'Errore nella ricerca: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Errore di connessione: $e';
      _books = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchBooksByCategory(String category) async {
    _setLoading(true);
    try {
      final url = Uri.parse(
        '$baseUrl?q=subject:${Uri.encodeComponent(category)}&maxResults=20',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List<dynamic>? ?? [];
        _books = items.map((item) => Book.fromGoogleBooks(item)).toList();
        _error = null;
      } else {
        _error = 'Errore nella ricerca per categoria: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Errore di connessione: $e';
      _books = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchBooksByAuthor(String author) async {
    _setLoading(true);
    try {
      final url = Uri.parse(
        '$baseUrl?q=inauthor:${Uri.encodeComponent(author)}&maxResults=20',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List<dynamic>? ?? [];
        _books = items.map((item) => Book.fromGoogleBooks(item)).toList();
        _error = null;
      } else {
        _error = 'Errore nella ricerca per autore: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Errore di connessione: $e';
      _books = [];
    } finally {
      _setLoading(false);
    }
  }

  // Aggiunge libro a To Read se non già presente
  void addToToRead(Book book) {
    if (!_toRead.any((b) => b.id == book.id)) {
      _toRead.add(book);
      _saveToReadBooks();
      notifyListeners();
    }
  }

  // Rimuove libro da To Read
  void removeFromToRead(String bookId) {
    _toRead.removeWhere((book) => book.id == bookId);
    _saveToReadBooks();
    notifyListeners();
  }

  // Inizia lettura, sposta libro da To Read a Currently Reading
  void startReading(String bookId, [Book? book]) {
    final bookIndex = _toRead.indexWhere((b) => b.id == bookId);
    Book? bookToStart = (bookIndex >= 0) ? _toRead.removeAt(bookIndex) : book;
    if (bookToStart != null && !_currentlyReading.any((b) => b.id == bookId)) {
      _currentlyReading.add(bookToStart);
      _readingPage[bookId] = _readingPage[bookId] ?? 0;
      _lastReadBookId = bookId;
      _lastReadingSession = DateTime.now();
      _saveLastReadBook();
      _saveToReadBooks();
      _saveCurrentlyReadingBooks();
      notifyListeners();
    }
  }

  // Aggiorna ultima sessione di lettura
  void updateLastReadingSession(String bookId) {
    _lastReadBookId = bookId;
    _lastReadingSession = DateTime.now();
    _saveLastReadBook();
    notifyListeners();
  }

  // Finisce la lettura, sposta da Currently Reading a Finished
  void finishReading(String bookId, {int? rating}) {
    final bookIndex = _currentlyReading.indexWhere((b) => b.id == bookId);
    if (bookIndex >= 0) {
      final book = _currentlyReading.removeAt(bookIndex);
      if (!_finished.any((b) => b.id == bookId)) {
        final finishedBook = Book(
          id: book.id,
          title: book.title,
          author: book.author,
          description: book.description,
          coverUrl: book.coverUrl,
          rating: book.rating,
          pages: book.pages,
          publisher: book.publisher,
          isbn: book.isbn,
          language: book.language,
          genres: book.genres,
          publishDate: book.publishDate,
          finishedDate: DateTime.now(),
        );
        _finished.add(finishedBook);
      }
      _readingPage.remove(bookId);
      if (rating != null) _customRatings[bookId] = rating;
      _saveCurrentlyReadingBooks();
      _saveFinishedBooks();
      notifyListeners();
    }
  }

  // Gestione preferiti: aggiungi o rimuovi
  void toggleFavorite(Book book) {
    final index = _favorites.indexWhere((b) => b.id == book.id);
    if (index >= 0) {
      _favorites.removeAt(index);
    } else {
      _favorites.add(book);
    }
    notifyListeners();
  }

  bool isFavorite(String bookId) => _favorites.any((b) => b.id == bookId);

  void removeFavorite(String bookId) {
    _favorites.removeWhere((b) => b.id == bookId);
    notifyListeners();
  }

  BookStatus getBookStatus(String bookId) {
    if (_currentlyReading.any((b) => b.id == bookId)) {
      return BookStatus.currentlyReading;
    }
    if (_toRead.any((b) => b.id == bookId)) return BookStatus.toRead;
    if (_finished.any((b) => b.id == bookId)) return BookStatus.finished;
    return BookStatus.notInLibrary;
  }

  void removeFromLibrary(String bookId) {
    _toRead.removeWhere((b) => b.id == bookId);
    _currentlyReading.removeWhere((b) => b.id == bookId);
    _finished.removeWhere((b) => b.id == bookId);
    _favorites.removeWhere((b) => b.id == bookId);
    _readingPage.remove(bookId);
    _customRatings.remove(bookId);
    notifyListeners();
  }

  // ========== SharedPreferences ==========

  Future<void> _saveToReadBooks() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = _toRead.map((b) => json.encode(b.toJson())).toList();
    await prefs.setStringList('toReadBooks', encoded);
  }

  Future<void> _loadToReadBooks() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('toReadBooks') ?? [];
    _toRead.clear();
    _toRead.addAll(list.map((item) => Book.fromJson(json.decode(item))));
  }

  Future<void> _saveCurrentlyReadingBooks() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = _currentlyReading
        .map((b) => json.encode(b.toJson()))
        .toList();
    await prefs.setStringList('currentlyReadingBooks', encoded);
    await _saveReadingPages();
  }

  Future<void> _loadCurrentlyReadingBooks() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('currentlyReadingBooks') ?? [];
    _currentlyReading.clear();
    _currentlyReading.addAll(
      list.map((item) => Book.fromJson(json.decode(item))),
    );
  }

  Future<void> _saveFinishedBooks() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = _finished.map((b) => json.encode(b.toJson())).toList();
    await prefs.setStringList('finishedBooks', encoded);
  }

  Future<void> _loadFinishedBooks() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('finishedBooks') ?? [];
    _finished.clear();
    _finished.addAll(list.map((item) => Book.fromJson(json.decode(item))));
  }

  Future<void> _saveReadingPages() async {
    final prefs = await SharedPreferences.getInstance();
    final mapAsString = _readingPage.map((k, v) => MapEntry(k, v.toString()));
    await prefs.setString('readingPages', json.encode(mapAsString));
  }

  Future<void> _loadReadingPages() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString('readingPages');
    if (str != null) {
      final map = json.decode(str) as Map<String, dynamic>;
      _readingPage.clear();
      map.forEach((key, value) {
        _readingPage[key] = int.tryParse(value.toString()) ?? 0;
      });
    }
  }

  Future<void> _saveLastReadBook() async {
    final prefs = await SharedPreferences.getInstance();
    if (_lastReadBookId != null) {
      await prefs.setString('lastReadBookId', _lastReadBookId!);
    }
    if (_lastReadingSession != null) {
      await prefs.setInt(
        'lastReadingSession',
        _lastReadingSession!.millisecondsSinceEpoch,
      );
    }
  }

  Future<void> _loadLastReadBook() async {
    final prefs = await SharedPreferences.getInstance();
    _lastReadBookId = prefs.getString('lastReadBookId');
    final millis = prefs.getInt('lastReadingSession');
    if (millis != null) {
      _lastReadingSession = DateTime.fromMillisecondsSinceEpoch(millis);
    }
  }

  Future<void> _saveReadingSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = _readingSessions.map((s) => s.toJson()).toList();
    await prefs.setString('readingSessions', json.encode(encoded));
  }

  Future<void> _loadReadingSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString('readingSessions');
    if (str != null) {
      final list = json.decode(str) as List<dynamic>;
      _readingSessions.clear();
      _readingSessions.addAll(
        list.map((item) => ReadingSession.fromJson(item)),
      );
    }
  }

  Future<void> _loadCustomRatings() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString('customRatings');
    if (str != null) {
      final map = json.decode(str) as Map<String, dynamic>;
      _customRatings.clear();
      map.forEach((key, value) {
        _customRatings[key] = int.tryParse(value.toString()) ?? 0;
      });
    }
  }

  Future<void> _loadCustomEmojis() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString('customEmojis');
    if (str != null) {
      final map = json.decode(str) as Map<String, dynamic>;
      _customEmojis.clear();
      map.forEach((key, value) {
        _customEmojis[key] = value.toString();
      });
    }
  }

  Future<void> _loadCustomComments() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString('customComments');
    if (str != null) {
      final map = json.decode(str) as Map<String, dynamic>;
      _customComments.clear();
      map.forEach((key, value) {
        _customComments[key] = value.toString();
      });
    }
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  double getReadingProgress(String bookId, int totalPages) {
    final page = _readingPage[bookId] ?? 0;
    if (totalPages <= 0) return 0.0;
    return (page / totalPages).clamp(0.0, 1.0);
  }

  Future<void> updateReadingPage(String bookId, int page) async {
    _readingPage[bookId] = page;
    final book = _currentlyReading.firstWhereOrNull((b) => b.id == bookId);
    if (book != null && book.pages > 0 && page >= book.pages) {
      _currentlyReading.removeWhere((b) => b.id == bookId);
      if (!_finished.any((b) => b.id == bookId)) {
        final finishedBook = Book(
          id: book.id,
          title: book.title,
          author: book.author,
          description: book.description,
          coverUrl: book.coverUrl,
          rating: book.rating,
          pages: book.pages,
          publisher: book.publisher,
          isbn: book.isbn,
          language: book.language,
          genres: book.genres,
          publishDate: book.publishDate,
          finishedDate: DateTime.now(),
        );
        _finished.add(finishedBook);
      }
      _readingPage.remove(bookId);
      await _saveCurrentlyReadingBooks();
      await _saveFinishedBooks();
    } else {
      // Aggiorna lastReadBookId solo se il libro è ancora in currentlyReading
      if (book != null) {
        _lastReadBookId = bookId;
        _lastReadingSession = DateTime.now();
        await _saveLastReadBook();
      }
      await _saveReadingPages();
    }
    notifyListeners();
  }

  Future<void> addReadingSession(String bookId, int minutes) async {
    _readingSessions.add(
      ReadingSession(bookId: bookId, date: DateTime.now(), minutes: minutes),
    );
    await _saveReadingSessions();
    notifyListeners();
  }

  // Aggiorna valutazione custom del libro
  void updateRating(String bookId, [dynamic rating, String? comment]) {
    if (rating != null) {
      _customRatings[bookId] = rating is int ? rating : 0;
    }
    if (comment != null && comment.isNotEmpty) {
      _customComments[bookId] = comment;
    }
    notifyListeners();
  }

  // Nuovo metodo per salvare anche l'emoji
  void updateFullRating(
    String bookId,
    int starRating,
    String emoji,
    String comment,
  ) {
    _customRatings[bookId] = starRating;
    _customEmojis[bookId] = emoji;
    _customComments[bookId] = comment;
    _saveCustomRatings();
    _saveCustomEmojis();
    _saveCustomComments();
    notifyListeners();
  }

  // Getter per recuperare i dati
  String? getCustomEmoji(String bookId) => _customEmojis[bookId];
  String? getCustomComment(String bookId) => _customComments[bookId];
  int? getCustomRating(String bookId) => _customRatings[bookId];

  Future<void> _saveCustomRatings() async {
    final prefs = await SharedPreferences.getInstance();
    final mapAsString = _customRatings.map((k, v) => MapEntry(k, v.toString()));
    await prefs.setString('customRatings', json.encode(mapAsString));
  }

  Future<void> _saveCustomEmojis() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('customEmojis', json.encode(_customEmojis));
  }

  Future<void> _saveCustomComments() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('customComments', json.encode(_customComments));
  }
}

enum BookStatus { notInLibrary, toRead, currentlyReading, finished }
