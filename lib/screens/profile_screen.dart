import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import '../providers/theme_provider.dart';
import '../providers/books_provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../core/theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? AppTheme.lightBackground
          : AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? AppTheme.lightBackground
            : AppTheme.darkBackground,
        elevation: 0,
        title: Text(
          'Profilo',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: const Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              'Nome Utente',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'utente@email.com',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: ListView(
                children: [
                  _buildProfileOption(
                    context,
                    Icons.palette_outlined,
                    'Cambia Mood',
                    onTap: () => _showThemeBottomSheet(context),
                  ),
                  _buildProfileOption(
                    context,
                    Icons.schedule_outlined,
                    'Promemoria di Lettura',
                    onTap: () => _showReadingRemindersDialog(context),
                  ),
                  _buildProfileOption(
                    context,
                    Icons.import_export_outlined,
                    'Importa/Esporta Libreria',
                    onTap: () => _showLibraryOptionsDialog(context),
                  ),
                  const Divider(height: 32),
                  _buildProfileOption(context, Icons.logout, 'Logout'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(
    BuildContext context,
    IconData icon,
    String title, {
    VoidCallback? onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.secondary),
        title: Text(title, style: Theme.of(context).textTheme.bodyMedium),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        onTap:
            onTap ??
            () {
              if (mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('$title selezionato')));
              }
            },
      ),
    );
  }

  void _showThemeBottomSheet(BuildContext context) async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();
    if (!context.mounted) return;

    final currentTheme = themeProvider.themeMode;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      // ignore: deprecated_member_use
      backgroundColor: Theme.of(context).dialogBackgroundColor,
      builder: (BuildContext modalContext) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Scegli il tuo mood',
                style: Theme.of(modalContext).textTheme.titleMedium,
              ),
              const SizedBox(height: 20),
              _buildThemeOption(
                modalContext,
                Icons.light_mode,
                'Tema Chiaro',
                'Sempre luminoso e chiaro',
                () async {
                  themeProvider.setThemeMode(ThemeMode.light);
                  await prefs.setString('themeMode', 'light');
                  if (modalContext.mounted) {
                    Navigator.pop(modalContext);
                  }
                },
                isSelected: currentTheme == ThemeMode.light,
              ),
              _buildThemeOption(
                modalContext,
                Icons.dark_mode,
                'Tema Scuro',
                'Sempre scuro per i tuoi occhi',
                () async {
                  themeProvider.setThemeMode(ThemeMode.dark);
                  await prefs.setString('themeMode', 'dark');
                  if (modalContext.mounted) {
                    Navigator.pop(modalContext);
                  }
                },
                isSelected: currentTheme == ThemeMode.dark,
              ),
              _buildThemeOption(
                modalContext,
                Icons.brightness_auto,
                'Tema Dinamico',
                'Chiaro di giorno, scuro di sera',
                () async {
                  themeProvider.setThemeMode(ThemeMode.system);
                  await prefs.setString('themeMode', 'system');
                  if (modalContext.mounted) {
                    Navigator.pop(modalContext);
                  }
                },
                isSelected: currentTheme == ThemeMode.system,
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap, {
    bool isSelected = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.secondary,
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.green, size: 24),
          ],
        ),
      ),
    );
  }

  void _showReadingRemindersDialog(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    if (!context.mounted) return;

    bool enabled = prefs.getBool('readingReminderEnabled') ?? false;
    String time = prefs.getString('readingReminderTime') ?? '20:00';
    String frequency =
        prefs.getString('readingReminderFrequency') ?? 'Giornaliera';
    TimeOfDay selectedTime = TimeOfDay(
      hour: int.parse(time.split(':')[0]),
      minute: int.parse(time.split(':')[1]),
    );

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (builderContext, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: Text(
                'Promemoria di Lettura',
                style: Theme.of(builderContext).textTheme.titleMedium,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    title: const Text('Abilita promemoria'),
                    subtitle: const Text('Ricevi notifiche per leggere'),
                    value: enabled,
                    onChanged: (bool value) async {
                      setState(() => enabled = value);
                      await prefs.setBool('readingReminderEnabled', value);
                      if (value) {
                        _scheduleReadingNotification(selectedTime, frequency);
                      } else {
                        _cancelReadingNotification();
                      }
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.access_time),
                    title: const Text('Orario promemoria'),
                    subtitle: Text(time),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: builderContext,
                        initialTime: selectedTime,
                      );
                      if (picked != null && builderContext.mounted) {
                        setState(() {
                          selectedTime = picked;
                          time = picked.format(builderContext);
                        });
                        await prefs.setString(
                          'readingReminderTime',
                          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}',
                        );
                        if (enabled) {
                          _scheduleReadingNotification(picked, frequency);
                        }
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.repeat),
                    title: const Text('Frequenza'),
                    subtitle: Text(frequency),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () async {
                      final options = ['Giornaliera', 'Settimanale'];
                      final selected = await showDialog<String>(
                        context: builderContext,
                        builder: (innerContext) => SimpleDialog(
                          title: const Text('Frequenza'),
                          children: options
                              .map(
                                (e) => SimpleDialogOption(
                                  child: Text(e),
                                  onPressed: () =>
                                      Navigator.pop(innerContext, e),
                                ),
                              )
                              .toList(),
                        ),
                      );
                      if (selected != null) {
                        setState(() => frequency = selected);
                        await prefs.setString(
                          'readingReminderFrequency',
                          selected,
                        );
                        if (enabled) {
                          _scheduleReadingNotification(selectedTime, selected);
                        }
                      }
                    },
                  ),
                ],
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: Text(
                          'Salva',
                          style: Theme.of(builderContext).textTheme.bodyMedium,
                        ),
                      ),
                    ),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: Text(
                          'Annulla',
                          style: Theme.of(
                            builderContext,
                          ).textTheme.labelMedium?.copyWith(color: Colors.grey),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _scheduleReadingNotification(TimeOfDay time, String frequency) async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    tz.initializeTimeZones();
    final now = tz.TZDateTime.now(tz.local);
    var scheduledTime = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Tempo di leggere! 📚',
      'Non dimenticare il tuo momento di lettura quotidiano.',
      scheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reading_reminder',
          'Promemoria di Lettura',
          channelDescription: 'Notifiche per ricordare di leggere',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: frequency == 'Giornaliera'
          ? DateTimeComponents.time
          : DateTimeComponents.dayOfWeekAndTime,
    );
  }

  void _cancelReadingNotification() async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin.cancel(0);
  }

  void _showLibraryOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            'Gestisci Libreria',
            style: Theme.of(dialogContext).textTheme.titleMedium,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.upload_outlined),
                title: const Text('Importa Libreria'),
                subtitle: const Text('Carica i tuoi libri da file'),
                onTap: () async {
                  Navigator.pop(dialogContext);
                  await _importLibrary();
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.download_outlined),
                title: const Text('Esporta Libreria'),
                subtitle: const Text('Salva la tua collezione'),
                onTap: () async {
                  Navigator.pop(dialogContext);
                  await _exportLibrary();
                },
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(
                  'Chiudi',
                  style: Theme.of(
                    dialogContext,
                  ).textTheme.labelMedium?.copyWith(color: Colors.grey),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _importLibrary() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (!mounted) return;

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      if (!mounted) return;

      try {
        jsonDecode(content);
        // Qui puoi adattare per importare solo i libri, o tutta la struttura
        // Esempio: booksProvider.importBooks(data);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Libreria importata!'),
            duration: Duration(seconds: 2),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Errore nell\'importazione: ${e.toString()}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _exportLibrary() async {
    final booksProvider = Provider.of<BooksProvider>(context, listen: false);
    final books = booksProvider.books;
    final jsonBooks = books.map((b) => b.toJson()).toList();
    final jsonString = jsonEncode(jsonBooks);
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/libreria_export.json');
    await file.writeAsString(jsonString);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Libreria esportata in ${file.path}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class ProfileScreenWrapper extends StatefulWidget {
  const ProfileScreenWrapper({super.key});

  @override
  State<ProfileScreenWrapper> createState() => _ProfileScreenWrapperState();
}

class _ProfileScreenWrapperState extends State<ProfileScreenWrapper> {
  @override
  void initState() {
    super.initState();
    _requestNotificationPermissions();
  }

  Future<void> _requestNotificationPermissions() async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    // iOS
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    // Android 13+
    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlugin != null) {
      try {
        await androidPlugin.requestNotificationsPermission();
      } catch (_) {
        // Se il metodo non esiste, ignora (versione vecchia del plugin)
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const ProfileScreen();
  }
}
