import 'package:flutter/material.dart';
import '/../../core/book_model.dart';
import 'package:provider/provider.dart';
import '../../providers/books_provider.dart';
import '../../core/app_icon.dart';

class RatingBottomSheet extends StatefulWidget {
  final Book book;
  const RatingBottomSheet({super.key, required this.book});

  @override
  State<RatingBottomSheet> createState() => _RatingBottomSheetState();
}

class _RatingBottomSheetState extends State<RatingBottomSheet> {
  int _starRating = 0; // Valutazione da 1 a 5 stelle
  String _selectedEmoji = '⭐'; // Emoji predefinita (stella)
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _pageController = TextEditingController();
  bool _saving = false;

  // Lista di emoji per personalizzare la visualizzazione della valutazione
  final List<String> _ratingEmojis = [
    '⭐', // Default
    '😍',
    '🥰',
    '😊',
    '🙂',
    '😐',
    '😕',
    '😞',
    '😢',
    '😡',
    '🤮',
    '🔥',
    '💯',
    '👍',
    '👎',
    '❤️',
    '💔',
    '🌟',
    '✨',
    '🎉',
  ];

  @override
  void dispose() {
    _commentController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final booksProvider = Provider.of<BooksProvider>(context, listen: false);

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 24,
        right: 24,
        top: 32,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con titolo
          Text(
            'Valutazione',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),

          // Copertina del libro centrata
          Center(
            child: Container(
              width: 120,
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                // ignore: unnecessary_null_comparison
                child: widget.book.coverUrl != null
                    ? Image.network(
                        widget.book.coverUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: AppIcon(AppIconType.book, size: 48),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: AppIcon(AppIconType.book, size: 48),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Sezione valutazione a stelle
          Text(
            'Valutazione:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _starRating = index + 1;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      _selectedEmoji,
                      style: TextStyle(
                        fontSize: 32,
                        color: index < _starRating
                            ? Colors.amber
                            : Colors.grey.withOpacity(0.3),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 24),

          // Sezione personalizzazione emoji
          Row(
            children: [
              const Text(
                'Personalizza emoji',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  _showEmojiPicker(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _selectedEmoji,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 4),
                      AppIcon(AppIconType.edit, size: 16, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Sezione commento
          const Text(
            'Il tuo commento:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: InputDecoration(
                      hintText: 'Scrivi qui il tuo commento sul libro...',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.blue,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Pulsante Salva
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _saving || _starRating == 0
                  ? null
                  : () async {
                      setState(() {
                        _saving = true;
                      });
                      await Future.delayed(const Duration(milliseconds: 300));

                      // Validazione pagina
                      int? page;
                      if (_pageController.text.trim().isNotEmpty) {
                        page = int.tryParse(_pageController.text.trim());
                        if (page == null || page <= 0) {
                          setState(() {
                            _saving = false;
                          });
                          return;
                        }
                        if (widget.book.pages > 0 && page > widget.book.pages) {
                          setState(() {
                            _saving = false;
                          });
                          return;
                        }
                      }

                      // Salva la valutazione con stelle, emoji personalizzata e commento
                      booksProvider.updateFullRating(
                        widget.book.id,
                        _starRating, // Valutazione numerica (1-5)
                        _selectedEmoji, // Emoji scelta per la visualizzazione
                        _commentController.text.trim(), // Commento
                      );
                      // Salva la pagina se presente
                      if (page != null) {
                        await booksProvider.updateReadingPage(
                          widget.book.id,
                          page,
                        );
                      }

                      setState(() => _saving = false);
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Valutazione salvata!')),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'SALVA VALUTAZIONE',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEmojiPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Scegli un emoji per la valutazione'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                childAspectRatio: 1,
              ),
              itemCount: _ratingEmojis.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedEmoji = _ratingEmojis[index];
                    });
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: _selectedEmoji == _ratingEmojis[index]
                          ? Colors.blue.withOpacity(0.2)
                          : Colors.transparent,
                      border: _selectedEmoji == _ratingEmojis[index]
                          ? Border.all(color: Colors.blue, width: 2)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        _ratingEmojis[index],
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annulla'),
            ),
          ],
        );
      },
    );
  }
}
