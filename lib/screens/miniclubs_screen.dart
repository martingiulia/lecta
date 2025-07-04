import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'chat_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../core/theme.dart';

class BookClubPage extends StatefulWidget {
  const BookClubPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BookClubPageState createState() => _BookClubPageState();
}

class _BookClubPageState extends State<BookClubPage> {
  List<Club> clubs = [];

  @override
  void initState() {
    super.initState();
    _loadClubs();
  }

  Future<void> _loadClubs() async {
    final prefs = await SharedPreferences.getInstance();
    final clubsString = prefs.getString('clubs');
    if (clubsString != null) {
      final List<dynamic> decoded = jsonDecode(clubsString);
      setState(() {
        clubs = decoded.map((e) => Club.fromJson(e)).toList();
      });
    }
  }

  Future<void> _saveClubs() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(clubs.map((c) => c.toJson()).toList());
    await prefs.setString('clubs', encoded);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Book Club',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        actions: [
          IconButton(
            onPressed: _showAddClubBottomSheet,
            icon: const Icon(Icons.add, size: 25),
            tooltip: 'Crea Book Club',
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: clubs.isEmpty
          ? _buildEmptyState()
          : Padding(
              padding: EdgeInsets.all(25),
              child: ListView.builder(
                itemCount: clubs.length,
                itemBuilder: (context, index) {
                  return ClubCard(
                    club: clubs[index],
                    onDelete: () => _deleteClub(index),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/bookclub.png', width: 300, height: 250),

          Text(
            'Nessun book club ancora',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SizedBox(height: 8),
          Text(
            'Crea il tuo primo bookclub per\niniziare a chattare con i tuoi amici',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  void _showAddClubBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return AddClubBottomSheet(
          onAddClub: (Club club) {
            _addClub(club);
          },
        );
      },
    );
  }

  void _addClub(Club club) {
    setState(() {
      clubs.add(club);
    });
    _saveClubs();
  }

  void _deleteClub(int index) {
    setState(() {
      clubs.removeAt(index);
    });
    _saveClubs();
  }
}

class AddClubBottomSheet extends StatefulWidget {
  final Function(Club) onAddClub;

  const AddClubBottomSheet({super.key, required this.onAddClub});

  @override
  // ignore: library_private_types_in_public_api
  _AddClubBottomSheetState createState() => _AddClubBottomSheetState();
}

class _AddClubBottomSheetState extends State<AddClubBottomSheet> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _inviteController = TextEditingController();
  Color _selectedChatColor = Colors.blue;
  String? _backgroundImagePath;

  final List<Color> _chatColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.teal,
    Colors.indigo,
  ];

  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? AppTheme.lightBackground
            : AppTheme.darkBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  SizedBox(height: 25),
                  // Title
                  Text(
                    'Crea Nuovo Book Club',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  SizedBox(height: 25),

                  // Nome del club
                  Text(
                    'Nome del club',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(height: 6),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Inserisci il nome del club',
                      hintStyle: Theme.of(context).textTheme.bodySmall,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                  SizedBox(height: 25),

                  // Invita amici
                  Text(
                    'Invita amici',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(height: 6),
                  TextField(
                    controller: _inviteController,
                    decoration: InputDecoration(
                      hintText: 'Inserisci email o username',
                      hintStyle: Theme.of(context).textTheme.bodySmall,
                      suffixIcon: Icon(
                        Icons.person_add,
                        color: Colors.grey[600],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                  SizedBox(height: 25),

                  // Carica foto sfondo
                  Text(
                    'Foto dello sfondo',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(height: 6),
                  GestureDetector(
                    onTap: _selectBackgroundImage,
                    child: Container(
                      width: double.infinity,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.light
                            ? AppTheme.lightBackground
                            : AppTheme.darkBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: _backgroundImagePath != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                File(_backgroundImagePath!),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 120,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate,
                                  size: 50,
                                  color: Colors.grey[600],
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Tocca per aggiungere foto',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                    ),
                  ),
                  SizedBox(height: 25),

                  // Colore chat
                  Text(
                    'Colore della chat',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(height: 6),
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _chatColors.length,
                      itemBuilder: (context, index) {
                        Color color = _chatColors[index];
                        bool isSelected = _selectedChatColor == color;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedChatColor = color;
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.only(right: 12),
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(color: Colors.black, width: 3)
                                  : null,
                            ),
                            child: isSelected
                                ? Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 25,
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 25),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.grey[300]!),
                            ),
                          ),
                          child: Text(
                            'Annulla',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                      SizedBox(width: 25),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _createClub,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Crea Club',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _selectBackgroundImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _backgroundImagePath = pickedFile.path;
      });
    }
  }

  void _createClub() {
    if (_nameController.text.isNotEmpty) {
      Club newClub = Club(
        name: _nameController.text,
        memberCount: 1,
        chatColor: _selectedChatColor,
        backgroundImage: _backgroundImagePath,
        invitedFriends: _inviteController.text.isNotEmpty
            ? [_inviteController.text]
            : [],
      );

      widget.onAddClub(newClub);
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Inserisci il nome del club'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _inviteController.dispose();
    super.dispose();
  }
}

class ClubCard extends StatelessWidget {
  final Club club;
  final VoidCallback onDelete;

  const ClubCard({super.key, required this.club, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final bool hasBackground = club.backgroundImage != null;
    final int maxAvatars = 4;
    final int extraMembers = club.memberCount - maxAvatars;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookClubChatPage(
              clubName: club.name,
              backgroundImage: club.backgroundImage,
              chatColor: club.chatColor ?? Colors.blue,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 25),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: hasBackground
                      ? null
                      : (Theme.of(context).brightness == Brightness.light
                            ? AppTheme.lightBackground
                            : AppTheme.darkBackground),
                  image: hasBackground
                      ? DecorationImage(
                          image: FileImage(File(club.backgroundImage!)),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
              ),

              // Gradient overlay
              Container(
                height: 180,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: hasBackground
                        ? [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.6),
                          ]
                        : [Colors.transparent, Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),

              // Card content
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top row: name + delete
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              club.name,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: hasBackground
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                            ),
                          ),
                          InkWell(
                            onTap: onDelete,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: hasBackground
                                    ? Colors.white.withValues(alpha: 0.2)
                                    : Colors.grey[300],
                              ),
                              child: Icon(
                                Icons.close,
                                size: 18,
                                color: hasBackground
                                    ? Colors.white
                                    : Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Spacer(),

                      // Member Avatars
                      Row(
                        children: [
                          ...List.generate(
                            club.memberCount.clamp(0, maxAvatars),
                            (index) => Container(
                              margin: EdgeInsets.only(right: 8),
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: club.chatColor ?? Colors.grey[800],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),

                          // +N indicator
                          if (extraMembers > 0)
                            Container(
                              width: 32,
                              height: 32,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white),
                              ),
                              child: Text(
                                '+$extraMembers',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Club {
  final String name;
  final int memberCount;
  final Color? chatColor;
  final String? backgroundImage;
  final List<String>? invitedFriends;

  Club({
    required this.name,
    required this.memberCount,
    this.chatColor,
    this.backgroundImage,
    this.invitedFriends,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'memberCount': memberCount,
    'chatColor': chatColor?.toARGB32(),
    'backgroundImage': backgroundImage,
    'invitedFriends': invitedFriends,
  };

  factory Club.fromJson(Map<String, dynamic> json) => Club(
    name: json['name'],
    memberCount: json['memberCount'],
    chatColor: json['chatColor'] != null ? Color(json['chatColor']) : null,
    backgroundImage: json['backgroundImage'],
    invitedFriends: json['invitedFriends'] != null
        ? List<String>.from(json['invitedFriends'])
        : null,
  );
}
