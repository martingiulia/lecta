import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../core/app_icon.dart';

class ChallengesPage extends StatefulWidget {
  const ChallengesPage({super.key});

  @override
  State<ChallengesPage> createState() => _ChallengesPageState();
}

class _ChallengesPageState extends State<ChallengesPage> {
  int totalPoints = 0;
  int streak = 3; // Giorni consecutivi

  final List<Challenge> challenges = [
    Challenge(
      title: 'Leggi 50 pagine',
      description: 'Sfida di lettura intensa!',
      icon: Icons.menu_book,
      deadline: DateTime.now().add(const Duration(days: 3)),
      progress: 0.4,
      completed: false,
      points: 50,
    ),
    Challenge(
      title: 'Completa un libro fantasy',
      description: 'Immergiti in un mondo fantastico!',
      icon: Icons.auto_stories,
      deadline: DateTime.now().subtract(const Duration(days: 1)),
      progress: 1.0,
      completed: true,
      points: 100,
    ),
    Challenge(
      title: 'Leggi 10 min al giorno',
      description: 'Abitudine quotidiana!',
      icon: Icons.schedule,
      deadline: DateTime.now().add(const Duration(days: 7)),
      progress: 0.65,
      completed: false,
      points: 25,
    ),
  ];

  final List<Prize> prizes = [
    Prize(
      title: '€5 di buono Feltrinelli',
      description: 'Buono sconto da spendere in libreria',
      icon: Icons.card_giftcard,
      pointsRequired: 100,
      imageUrl:
          'https://lauratorretta.it/wp-content/uploads/2017/10/feltrinelli-logo-rosso-per-sito-eventi.jpg',
    ),
    Prize(
      title: '€10 di buono Amazon',
      description: 'Buono per acquisti su Amazon',
      icon: Icons.shopping_bag,
      pointsRequired: 200,
      imageUrl:
          'https://static.dezeen.com/uploads/2025/05/amazon-rebrand-2025_dezeen_2364_col_1-1.jpg',
    ),
    Prize(
      title: 'Abbonamento Kindle Unlimited',
      description: '1 mese di lettura illimitata',
      icon: Icons.tablet_mac,
      pointsRequired: 300,
      imageUrl:
          'https://platform.theverge.com/wp-content/uploads/sites/2/chorus/uploads/chorus_asset/file/9521997/kindle_app_logo.jpg',
    ),
    Prize(
      title: '€15 di buono Mondadori',
      description: 'Buono per la catena Mondadori',
      icon: Icons.store,
      pointsRequired: 250,
      imageUrl:
          'https://static.wixstatic.com/media/ad36b5_f17ddb115dae46b7a848078261c98654~mv2.jpg/v1/fill/w_980,h_1225,al_c,q_85,usm_0.66_1.00_0.01,enc_avif,quality_auto/18_mondadori.jpg',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _calculatePoints();
  }

  void _calculatePoints() {
    totalPoints = challenges
        .where((c) => c.completed)
        .fold(0, (sum, c) => sum + c.points);
  }

  void toggleCompleted(int index) {
    setState(() {
      challenges[index].completed = !challenges[index].completed;
      challenges[index].progress = challenges[index].completed ? 1.0 : 0.0;
      _calculatePoints();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? AppTheme.lightBackground
          : AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Sfide di lettura',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        actions: [
          // Punti totali
          Container(
            margin: const EdgeInsets.only(right: 12.5),
            padding: const EdgeInsets.symmetric(horizontal: 12.5, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppIcon(AppIconType.star, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text(
                  '$totalPoints',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          // Titolo Streak
          Padding(
            padding: const EdgeInsets.only(top: 25, bottom: 8),
            child: Text('Streak', style: Theme.of(context).textTheme.bodyLarge),
          ),
          // Giorni della settimana + indicatori streak
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _StreakWeekRow(streak: streak),
          ),
          // Barra streak (ora scrollabile)
          Container(
            margin: const EdgeInsets.only(bottom: 25),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF2A2A2A)
                    : const Color(0xFFE0E0E0),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12.5),
                  decoration: BoxDecoration(
                    color: Colors.orange.withAlpha(1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: AppIcon(
                    AppIconType.fire,
                    size: 20,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Streak di $streak giorni',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Continua così!',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                AppIcon(AppIconType.fire, size: 20, color: Colors.orange),
              ],
            ),
          ),

          // Titolo Sfide
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text('Sfide', style: Theme.of(context).textTheme.bodyLarge),
          ),

          // Lista sfide
          ...challenges.asMap().entries.map((entry) {
            final index = entry.key;
            final challenge = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ChallengeCard(
                challenge: challenge,
                onToggle: () => toggleCompleted(index),
              ),
            );
          }),

          const SizedBox(height: 24),

          // Titolo Premi
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              'Premi disponibili',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),

          // Sezione Premi
          SizedBox(
            height: 317,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: prizes.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 280,
                  margin: const EdgeInsets.only(right: 16),
                  child: PrizeCard(
                    prize: prizes[index],
                    totalPoints: totalPoints,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class Challenge {
  final String title;
  final String description;
  final IconData icon;
  final DateTime deadline;
  final int points;
  bool completed;
  double progress;

  Challenge({
    required this.title,
    required this.description,
    required this.icon,
    required this.deadline,
    required this.completed,
    required this.progress,
    required this.points,
  });
}

class Prize {
  final String title;
  final String description;
  final IconData icon;
  final int pointsRequired;
  final String imageUrl;

  Prize({
    required this.title,
    required this.description,
    required this.icon,
    required this.pointsRequired,
    required this.imageUrl,
  });
}

class ChallengeCard extends StatelessWidget {
  final Challenge challenge;
  final VoidCallback onToggle;

  const ChallengeCard({
    super.key,
    required this.challenge,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final daysLeft = challenge.deadline.difference(now).inDays;

    String status;
    Color statusColor;

    if (challenge.completed) {
      status = 'Completata';
      statusColor = Colors.green;
    } else if (daysLeft < 0) {
      status = 'Scaduta';
      statusColor = Colors.red;
    } else {
      status = '$daysLeft giorni';
      statusColor = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con icona, titolo e checkbox
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12.5),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withAlpha(1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: AppIcon(
                  _iconDataToAppIconType(challenge.icon),
                  size: 24,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      challenge.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      challenge.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: onToggle,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: challenge.completed
                        ? Colors.green.withAlpha(1)
                        : Colors.grey.withAlpha(1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: AppIcon(
                    AppIconType.check,
                    size: 24,
                    color: challenge.completed ? Colors.green : Colors.grey,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Progress bar
          Container(
            height: 12.5,
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : Colors.black12,
              borderRadius: BorderRadius.circular(6),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: challenge.progress,
              child: Container(
                decoration: BoxDecoration(
                  color: challenge.completed
                      ? Colors.green
                      : Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Footer con punti e status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  AppIcon(
                    AppIconType.starOutline,
                    size: 16,
                    color: Colors.amber,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${challenge.points} punti',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.amber,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PrizeCard extends StatelessWidget {
  final Prize prize;
  final int totalPoints;

  const PrizeCard({super.key, required this.prize, required this.totalPoints});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canAfford = totalPoints >= prize.pointsRequired;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Immagine del premio
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: SizedBox(
              height: 160,
              width: double.infinity,
              child: Image.network(
                prize.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback in caso l'immagine non si carichi
                  return Container(
                    color: Colors.grey.withAlpha(2),
                    child: Center(
                      child: AppIcon(
                        _iconDataToAppIconType(prize.icon),
                        size: 32,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey.withAlpha(1),
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,
                        strokeWidth: 2,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Contenuto della card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Titolo del premio
                  Text(
                    prize.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  // Descrizione
                  Text(
                    prize.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Punti richiesti e disponibili
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          AppIcon(
                            AppIconType.star,
                            size: 16,
                            color: canAfford ? Colors.amber : Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${prize.pointsRequired}',
                            style: TextStyle(
                              color: canAfford ? Colors.amber : Colors.grey,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Hai: $totalPoints',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white60 : Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Bottone per riscattare
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: canAfford
                          ? () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Premio "${prize.title}" riscattato!',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canAfford
                            ? Color(0xFF5ca3fc)
                            : Colors.grey.withAlpha(3),
                        foregroundColor: canAfford ? Colors.white : Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        minimumSize: const Size(0, 32),
                      ),
                      child: Text(
                        canAfford ? 'Riscatta' : 'Punti insufficienti',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget per la visualizzazione dei giorni della settimana e streak
class _StreakWeekRow extends StatelessWidget {
  final int streak;
  const _StreakWeekRow({required this.streak});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Giorni della settimana abbreviati (inizia da lunedì)
    const days = ['L', 'M', 'M', 'G', 'V', 'S', 'D'];
    // Simuliamo che i primi 'streak' giorni siano "letti"
    final today = DateTime.now();
    // Calcola l'indice del giorno attuale (0 = lunedì, 6 = domenica)
    int todayIndex = (today.weekday % 7);
    // Costruisci la lista dei 7 giorni, partendo da lunedì fino a domenica
    List<bool> readDays = List.generate(7, (i) => false);
    for (int i = 0; i < streak && i < 7; i++) {
      int idx = todayIndex - i;
      if (idx < 0) idx += 7;
      readDays[idx] = true;
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(7, (i) {
        final isRead = readDays[i];
        return Column(
          children: [
            Text(
              days[i],
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.brightness == Brightness.dark
                    ? Colors.white70
                    : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: isRead ? Colors.orange : Colors.transparent,
                border: Border.all(
                  color: isRead ? Colors.orange : Colors.grey.shade400,
                  width: 2,
                ),
                shape: BoxShape.circle,
              ),
              child: isRead
                  ? AppIcon(AppIconType.check, size: 12, color: Colors.white)
                  : null,
            ),
          ],
        );
      }),
    );
  }
}

// Funzione di mapping da IconData a AppIconType
AppIconType _iconDataToAppIconType(IconData icon) {
  if (icon == Icons.menu_book) return AppIconType.book;
  if (icon == Icons.auto_stories) return AppIconType.book;
  if (icon == Icons.schedule) return AppIconType.clock;
  if (icon == Icons.card_giftcard) return AppIconType.gift;
  if (icon == Icons.shopping_bag) return AppIconType.bag;
  if (icon == Icons.tablet_mac) return AppIconType.tablet;
  if (icon == Icons.store) return AppIconType.store;
  // fallback
  return AppIconType.book;
}
