import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../providers/books_provider.dart';
import '../core/theme.dart';
import '../core/app_icon.dart';

class ReadingTimerPage extends StatefulWidget {
  final int? totalPages;
  final String? bookId;

  const ReadingTimerPage({
    super.key,
    required this.totalPages,
    required this.bookId,
  });

  @override
  State<ReadingTimerPage> createState() => _ReadingTimerPageState();
}

class _ReadingTimerPageState extends State<ReadingTimerPage> {
  int initialMinutes = 20;
  int minutes = 20;
  int seconds = 0;
  bool isRunning = false;
  bool _isEndingSession = false;
  bool _hasStartedSession = false;

  int totalSeconds = 1200; // 20 minuti di default
  int remainingSeconds = 1200; // 20 minuti di default

  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Ticker(_onTick);
    _loadDefaultMinutes();
  }

  Future<void> _loadDefaultMinutes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedMinutes = prefs.getInt('minutiTarget') ?? 20;
      if (mounted) {
        setState(() {
          initialMinutes = savedMinutes;
          minutes = savedMinutes;
          seconds = 0;
          totalSeconds = minutes * 60;
          remainingSeconds = totalSeconds;
        });
      }
    } catch (e) {
      // Silently ignore errors
    }
  }

  void _startTimer() {
    if (isRunning) return;
    setState(() {
      isRunning = true;
      _hasStartedSession = true;
    });

    if (widget.bookId != null) {
      final booksProvider = Provider.of<BooksProvider>(context, listen: false);
      booksProvider.updateLastReadingSession(widget.bookId!);
    }

    _ticker.start();
  }

  void _pauseTimer() {
    setState(() => isRunning = false);
    _ticker.stop();
  }

  void _onTick(Duration elapsed) {
    if (!isRunning || !mounted) return;
    setState(() {
      if (remainingSeconds > 0) {
        remainingSeconds--;
      } else {
        isRunning = false;
        _ticker.stop();
        _endSession();
      }
    });
  }

  void _resetTimer() {
    setState(() {
      isRunning = false;
      minutes = initialMinutes;
      seconds = 0;
      totalSeconds = minutes * 60;
      remainingSeconds = totalSeconds;
      _hasStartedSession = false;
    });
    _ticker.stop();
  }

  void _endSession() async {
    if (_isEndingSession) return;
    _isEndingSession = true;
    setState(() {
      isRunning = false;
    });
    _ticker.stop();
    _isEndingSession = false;
    if (!mounted) return;

    final page = await showModalBottomSheet<int>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      builder: (context) => _PageInputSheet(totalPages: widget.totalPages),
    );

    if (!mounted) return;

    if (page != null && widget.bookId != null && widget.totalPages != null) {
      final booksProvider = Provider.of<BooksProvider>(context, listen: false);
      try {
        final updateFuture = booksProvider.updateReadingPage(
          widget.bookId!,
          page,
        );
        final sessionMinutes = ((totalSeconds - remainingSeconds) / 60).round();
        Future updateSession = Future.value();
        if (sessionMinutes > 0) {
          updateSession = booksProvider.addReadingSession(
            widget.bookId!,
            sessionMinutes,
          );
        }
        final result = await Future.any([
          Future.wait([updateFuture, updateSession]),
          Future.delayed(const Duration(seconds: 2), () => 'TIMEOUT'),
        ]);
        if (result == 'TIMEOUT') {
          // Silently ignore timeout
        } else {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Progresso aggiornato'),
              backgroundColor: Colors.blueAccent,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Errore nell\'aggiornamento: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }

    if (mounted) {
      Navigator.pop(context, page);
    }
  }

  void _changeMinutes(int delta) {
    setState(() {
      minutes = (minutes + delta).clamp(1, 180);
      totalSeconds = minutes * 60;
      remainingSeconds = totalSeconds;
    });
  }

  @override
  void dispose() {
    _ticker.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayMinutes = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final displaySeconds = (remainingSeconds % 60).toString().padLeft(2, '0');

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? AppTheme.lightBackground
          : AppTheme.darkBackground,

      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? AppTheme.lightBackground
            : AppTheme.darkBackground,
        title: Text(
          'Sessione di Lettura',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              // Sezione Timer Display
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.light
                        ? AppTheme.lightSurface
                        : AppTheme.darkSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.light
                          ? AppTheme.lightSurface
                          : AppTheme.lightSurface.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Tempo Rimanente',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12.5),
                      Text(
                        '$displayMinutes:$displaySeconds',
                        style: Theme.of(context).textTheme.displayLarge
                            ?.copyWith(
                              color: isRunning
                                  ? AppTheme.primary
                                  : Theme.of(
                                      context,
                                    ).textTheme.displayLarge?.color,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 200,
                        height: 8,
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).brightness == Brightness.light
                              ? Colors.grey[200]
                              : AppTheme.lightSurface.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: totalSeconds > 0
                              ? (totalSeconds - remainingSeconds) / totalSeconds
                              : 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: isRunning
                                  ? AppTheme.primary
                                  : (Theme.of(context).brightness ==
                                            Brightness.light
                                        ? Colors.grey[400]
                                        : AppTheme.lightSurface.withOpacity(
                                            0.6,
                                          )),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // Sezione Controlli Minuti
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.light
                      ? AppTheme.lightSurface
                      : AppTheme.darkSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.light
                        ? AppTheme.lightSurface
                        : AppTheme.lightSurface.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Durata Sessione',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12.5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: AppIcon(AppIconType.remove),
                            onPressed: isRunning
                                ? null
                                : () => _changeMinutes(-1),
                            color: isRunning
                                ? AppTheme.primary.withOpacity(0.3)
                                : AppTheme.primary,
                          ),
                        ),
                        const SizedBox(width: 24),
                        Text(
                          '$minutes min',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(width: 24),
                        Container(
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: AppIcon(AppIconType.add),
                            onPressed: isRunning
                                ? null
                                : () => _changeMinutes(1),
                            color: isRunning
                                ? AppTheme.primary.withOpacity(0.3)
                                : AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // Sezione Play/Pause
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: AppIcon(
                    isRunning ? AppIconType.pause : AppIconType.playArrow,
                    size: 36,
                    color: AppTheme.lightSurface,
                  ),
                  onPressed: isRunning ? _pauseTimer : _startTimer,
                ),
              ),

              const SizedBox(height: 25),

              // Sezione Pulsanti Azione
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _resetTimer,
                        icon: AppIcon(AppIconType.refresh, size: 20),
                        label: const Text(
                          'Ricomincia',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).brightness == Brightness.light
                              ? AppTheme.lightSurface
                              : Colors.transparent,
                          foregroundColor:
                              Theme.of(context).brightness == Brightness.light
                              ? Colors.grey[700]
                              : AppTheme.lightSurface,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Colors.grey[300]!
                                  : AppTheme.lightSurface,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _hasStartedSession ? _endSession : null,
                        icon: AppIcon(AppIconType.stop, size: 20),
                        label: const Text(
                          'Termina',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _hasStartedSession
                              ? Colors.red[400]
                              : AppTheme.lightSurface,
                          foregroundColor: _hasStartedSession
                              ? AppTheme.lightSurface
                              : Colors.grey[600],
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12.5),
            ],
          ),
        ),
      ),
    );
  }
}

class Ticker {
  final void Function(Duration) onTick;
  Duration _elapsed = Duration.zero;
  bool _active = false;
  late final Stopwatch _stopwatch;
  late final Duration _interval;

  Ticker(this.onTick, {Duration interval = const Duration(seconds: 1)}) {
    _interval = interval;
    _stopwatch = Stopwatch();
  }

  void start() {
    _active = true;
    _stopwatch.start();
    _tick();
  }

  void stop() {
    _active = false;
    _stopwatch.stop();
  }

  void _tick() async {
    while (_active) {
      await Future.delayed(_interval);
      if (_active) {
        _elapsed = _stopwatch.elapsed;
        onTick(_elapsed);
      }
    }
  }
}

class _PageInputSheet extends StatefulWidget {
  final int? totalPages;
  const _PageInputSheet({this.totalPages});

  @override
  State<_PageInputSheet> createState() => _PageInputSheetState();
}

class _PageInputSheetState extends State<_PageInputSheet> {
  final TextEditingController _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirmPage() {
    final value = int.tryParse(_controller.text);
    final totalPages = widget.totalPages ?? 0;

    if (value == null || value <= 0) {
      setState(() => _error = 'Inserisci un numero valido');
    } else if (totalPages > 0 && value > totalPages) {
      setState(() => _error = 'Non puoi superare le pagine totali');
    } else {
      if (mounted) {
        Navigator.of(context).pop(value);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final int totalPages = widget.totalPages ?? 0;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.light
              ? AppTheme.lightSurface
              : AppTheme.darkSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A che pagina sei arrivato?',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12.5),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    style: Theme.of(context).textTheme.bodyMedium,
                    decoration: InputDecoration(
                      hintText: 'Numero pagina',
                      errorText: _error,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color:
                              Theme.of(context).brightness == Brightness.light
                              ? Colors.grey[300]!
                              : AppTheme.lightSurface,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color:
                              Theme.of(context).brightness == Brightness.light
                              ? Colors.grey[300]!
                              : AppTheme.lightSurface,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppTheme.primary,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor:
                          Theme.of(context).brightness == Brightness.light
                          ? Colors.grey[50]
                          : Colors.transparent,
                    ),
                    onChanged: (value) {
                      setState(() => _error = null);
                      final page = int.tryParse(value);
                      if (page != null && totalPages > 0 && page > totalPages) {
                        _controller.text = totalPages.toString();
                        _controller.selection = TextSelection.fromPosition(
                          TextPosition(offset: _controller.text.length),
                        );
                      }
                    },
                    onSubmitted: (_) => _confirmPage(),
                  ),
                ),
                if (totalPages > 0) ...[
                  const SizedBox(width: 8),
                  Text(
                    '/ $totalPages',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _confirmPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Conferma'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
