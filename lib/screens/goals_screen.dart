import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/books_provider.dart';
import '../core/theme.dart';
import '../core/app_icon.dart';

class ReadingGoalsPage extends StatefulWidget {
  const ReadingGoalsPage({super.key});

  @override
  State<ReadingGoalsPage> createState() => _ReadingGoalsPageState();
}

class _ReadingGoalsPageState extends State<ReadingGoalsPage> {
  int minutiTarget = 20, minutiAttuali = 10;
  int libriTarget = 8;

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      minutiTarget = (prefs.getInt('minutiTarget') ?? 20).clamp(10, 60);
      libriTarget = (prefs.getInt('libriTarget') ?? 8).clamp(1, 30);
    });
  }

  Future<void> _saveGoals() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('minutiTarget', minutiTarget);
    await prefs.setInt('libriTarget', libriTarget);
  }

  void _editGoalDialog(
    String tipo,
    int currentValue,
    int minValue,
    Function(int) onSave,
  ) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (context) {
        int tempValue = currentValue;
        final theme = Theme.of(context);
        return Dialog(
          backgroundColor: theme.brightness == Brightness.light
              ? AppTheme.lightSurface
              : AppTheme.darkSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  tipo == 'minuti'
                      ? 'Minuti di lettura giornalieri'
                      : 'Libri da leggere quest\'anno',
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 25),
                StatefulBuilder(
                  builder: (context, setState) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 8.0,
                            activeTrackColor: AppTheme.primary,
                            inactiveTrackColor: AppTheme.primary.withAlpha(40),
                            thumbColor: AppTheme.primary,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 12.0,
                              elevation: 4.0,
                              pressedElevation: 8.0,
                            ),
                            overlayColor: AppTheme.primary.withAlpha(20),
                            overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 20.0,
                            ),
                            valueIndicatorColor: AppTheme.primary,
                            valueIndicatorTextStyle: TextStyle(
                              color: AppTheme.lightSurface,
                              fontFamily: 'Roobert',
                              fontWeight: FontWeight.w500,
                            ),
                            showValueIndicator: ShowValueIndicator.always,
                          ),
                          child: Slider(
                            value: tempValue.toDouble(),
                            min: minValue.toDouble(),
                            max: tipo == 'minuti' ? 60 : 30,
                            divisions: tipo == 'minuti' ? 50 : 29,
                            label: '$tempValue',
                            onChanged: (value) =>
                                setState(() => tempValue = value.toInt()),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text('$tempValue', style: theme.textTheme.titleSmall),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.primary,
                          textStyle: theme.textTheme.labelMedium,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Annulla'),
                      ),
                    ),
                    const SizedBox(width: 12.5),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: AppTheme.lightSurface,
                          textStyle: theme.textTheme.labelMedium,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          onSave(tempValue);
                          _saveGoals();
                          Navigator.pop(context);
                        },
                        child: const Text('Salva'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final booksProvider = Provider.of<BooksProvider>(context);
    final minutiOggi = booksProvider.todayMinutesRead;
    final copertine = booksProvider.finishedBookCoversThisYear;
    final libriFiniti = copertine.length;

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? AppTheme.lightBackground
          : AppTheme.darkBackground,
      appBar: AppBar(
        title: Text(
          'Obiettivi di lettura',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? AppTheme.lightBackground
            : AppTheme.darkBackground,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GoalCard(
            icon: AppIconType.clock,
            title: 'Minuti al giorno',
            current: minutiOggi,
            target: minutiTarget,
            color: AppTheme.primary,
            unit: 'min',
            onEdit: () => _editGoalDialog(
              'minuti',
              minutiTarget,
              10,
              (val) => setState(() => minutiTarget = val),
            ),
          ),
          const SizedBox(height: 25),
          GoalCard(
            icon: AppIconType.book,
            title: 'Libri di quest\' anno',
            current: libriFiniti,
            target: libriTarget,
            color: AppTheme.primary,
            unit: 'libri',
            onEdit: () => _editGoalDialog(
              'libri',
              libriTarget,
              1,
              (val) => setState(() => libriTarget = val),
            ),
            child: BookGrid(
              target: libriTarget,
              read: libriFiniti,
              covers: copertine,
            ),
          ),
        ],
      ),
    );
  }
}

class GoalCard extends StatelessWidget {
  final AppIconType icon;
  final String title;
  final int current, target;
  final Color color;
  final String unit;
  final VoidCallback onEdit;
  final Widget? child;

  const GoalCard({
    required this.icon,
    required this.title,
    required this.current,
    required this.target,
    required this.color,
    required this.unit,
    required this.onEdit,
    this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final percent = target == 0 ? 0.0 : (current / target).clamp(0.0, 1.0);
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.brightness == Brightness.light
          ? AppTheme.lightSurface
          : AppTheme.darkSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: AppIcon(icon, color: AppTheme.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(title, style: theme.textTheme.bodyLarge)),
                IconButton(
                  onPressed: onEdit,
                  icon: Icon(Icons.edit, color: color),
                ),
              ],
            ),
            const SizedBox(height: 12.5),
            Text(
              '$current / $target $unit',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 12.5),
            Container(
              height: 10,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: color, width: 2),
                color: Colors.transparent,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: percent,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
            ),
            if (child != null) ...[const SizedBox(height: 12.5), child!],
          ],
        ),
      ),
    );
  }
}

class BookGrid extends StatelessWidget {
  final int target, read;
  final List<String> covers;

  const BookGrid({
    super.key,
    required this.target,
    required this.read,
    required this.covers,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: target,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.7,
      ),
      itemBuilder: (context, index) {
        final isRead = index < read;
        final cover = isRead && index < covers.length ? covers[index] : null;

        return Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: isRead
                  ? AppTheme.primary
                  : theme.brightness == Brightness.dark
                  ? Colors.grey.shade600
                  : Colors.grey.shade300,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: cover != null
                ? Image.network(cover, fit: BoxFit.cover)
                : Icon(
                    Icons.book_outlined,
                    size: 32,
                    color: theme.brightness == Brightness.dark
                        ? Colors.grey.shade400
                        : Colors.grey.shade500,
                  ),
          ),
        );
      },
    );
  }
}
