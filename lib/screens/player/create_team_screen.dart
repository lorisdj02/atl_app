import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import '../../models/team.dart';
import '../../models/sport_category.dart';
import '../../database/db_controller.dart';
import '../../providers/user_provider.dart';
import '../../utils/atl_colors.dart';
import '../../utils/text_formatters.dart';

class CreateTeamScreen extends StatefulWidget {
  final SportCategory currentSport;

  const CreateTeamScreen({
    super.key,
    required this.currentSport,
  });

  @override
  State<CreateTeamScreen> createState() => _CreateTeamScreenState();
}

class _CreateTeamScreenState extends State<CreateTeamScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _aliasController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String? _selectedCity;
  bool _isVip = false;
  bool _visibility = true; // Public by default
  File? _imageFile;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _aliasController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore nel caricamento immagine: $e')),
        );
      }
    }
  }

  Future<void> _createTeam() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentUser = userProvider.activeUser;

      if (currentUser == null) {
        throw Exception('User not found');
      }

      if ((await DB.Teams.isNameUnique(_nameController.text)) == false) {
        throw Exception('Team name already in use');
      }

      // TODO: Upload immagine su server e ottenere URL
      String? imageUrl;
      if (_imageFile != null) {
        // Qui dovrai implementare l'upload al tuo backend
        // imageUrl = await uploadImage(_imageFile!);
        imageUrl = null; // Placeholder
      }

      int captainId = userProvider.activeRoleId!;

      // Crea il team
      final newTeam = Team(
        id: DateTime.now().millisecondsSinceEpoch, // Temporary ID
        cityId: _selectedCity,
        name: _nameController.text.trim(),
        alias: _aliasController.text.trim(),
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        captainId: captainId, // Usa playerId dell'utente corrente
        catId: widget.currentSport.id,
        imageUrl: imageUrl,
        vip: _isVip,
        players: 1, // Solo il capitano inizialmente
        visibility: _visibility,
      );

      if((await DB().createTeam(
        newTeam.id,
        newTeam.cityId,
        newTeam.name,
        newTeam.alias,
        newTeam.description,
        newTeam.captainId,
        newTeam.catId,
        newTeam.imageUrl,
        newTeam.vip,
        newTeam.visibility,
      )) == false) {
        throw Exception('Failed to create team');
      }


      // Aggiorna l'utente con il teamId
      final updatedUser = currentUser.copyWith(teamId: newTeam.id);
      await userProvider.updateUser(updatedUser);
      userProvider.setCurrentTeamId(newTeam.id);

      if (mounted) {
        print('🔧 [DEBUG] Team created successfully: ${newTeam.name}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Team creato con successo!'),
            backgroundColor: Colors.green,
          ),
        );
        //Navigator.of(context).pop(true); // Ritorna true per indicare successo
        Navigator.of(context).pop(); // Ritorna alla schermata precedente
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ATLColors.background,
      appBar: AppBar(
        backgroundColor: widget.currentSport.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Create team',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.dark_mode, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Dark mode coming soon')),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo Upload
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 2,
                            ),
                          ),
                          child: _imageFile != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    _imageFile!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.upload_file,
                                      size: 48,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Upload logo',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Nome Team
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'Name of the team',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Inserisci il nome del team';
                        }
                        if (value.trim().length < 3) {
                          return 'Il nome deve essere di almeno 3 caratteri';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Alias Team (opzionale)
                    TextFormField(
                      controller: _aliasController,
                      inputFormatters: [
                        UpperCaseTextFormatter(),
                      ],
                      decoration: InputDecoration(
                        hintText: 'Team alias',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Inserisci l\'alias del team';
                        }
                        if (value.trim().length < 3) {
                          return 'L\'alias deve essere di 3 caratteri';
                        }
                        return null;
                      },
                      maxLength: 3,
                      textCapitalization: TextCapitalization.characters,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Descrizione (opzionale)
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        hintText: 'Team description (optional)',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      maxLines: 3,
                      maxLength: 200,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Città
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _selectedCity,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Select city',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: '1',
                            child: Text('Milano'),
                          ),
                          DropdownMenuItem(
                            value: '2',
                            child: Text('Taranto'),
                          ),
                          DropdownMenuItem(
                            value: '3',
                            child: Text('Roma'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedCity = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Seleziona una città';
                          }
                          return null;
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Visibility (Public/Private)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonFormField<bool>(
                        value: _visibility,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Visibility (Public/Private)',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: true,
                            child: Text('Public'),
                          ),
                          DropdownMenuItem(
                            value: false,
                            child: Text('Private'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _visibility = value ?? true;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 32),
                    
                    // Create Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _createTeam,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.currentSport.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'CREATE TEAM',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
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
