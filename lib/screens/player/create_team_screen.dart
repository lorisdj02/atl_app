import 'package:atl_app/database/db_write.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../database/db_read.dart';
import '../../models/sport_category.dart';
import '../../models/city.dart';
import '../../providers/account_provider.dart';
import '../../utils/atl_colors.dart';
import '../../utils/text_formatters.dart';
import '../../l10n/app_localizations.dart';

class CreateTeamScreen extends StatefulWidget {
  final SportCategory currentSport;

  const CreateTeamScreen({super.key, required this.currentSport});

  @override
  State<CreateTeamScreen> createState() => _CreateTeamScreenState();
}

class _CreateTeamScreenState extends State<CreateTeamScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _aliasController = TextEditingController();
  final _descriptionController = TextEditingController();

  int? _selectedCity;
  List<City> _availableCities = [];
  bool _isVip = false;
  bool _visibility = true; // Public by default
  File? _imageFile;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadCities();
  }

  Future<void> _loadCities() async {
    try {
      final List<City> cities = await DBRead.getCities();
      if (mounted) {
        setState(() {
          _availableCities = cities;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).errorLoadingCitiesShort(e.toString()),
            ),
          ),
        );
      }
    }
  }

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
          SnackBar(
            content: Text(
              AppLocalizations.of(context).errorLoadingImage(e.toString()),
            ),
          ),
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
      final l10n = AppLocalizations.of(context);
      final userProvider = Provider.of<AccountProvider>(context, listen: false);
      final currentUser = userProvider.activeAccount;

      if (currentUser == null) {
        throw Exception(l10n.userNotFound);
      }

      try{
        final success = await DBRead.checkTeamNameInCategory(_nameController.text, widget.currentSport);
        if(success == false){
          throw Exception(l10n.teamNameAlreadyInUse);
        }
      }
      catch (_){
        throw Exception(l10n.teamNameAlreadyInUse);
      }

      // TODO: Upload immagine su server e ottenere URL
      String? imageUrl;
      if (_imageFile != null) {
        // Qui dovrai implementare l'upload al tuo backend
        // imageUrl = await uploadImage(_imageFile!);
        imageUrl = null; // Placeholder
      }

      int captainId = userProvider.activeRoleId!;

      // Crea il team nel database

      final int newTeamId = await DBWrite.createTeam(
        _selectedCity,
        _nameController.text.trim(),
        _aliasController.text.trim(),
        _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        captainId,
        widget.currentSport,
        imageUrl,
        _isVip,
        _visibility,
      );

      if (newTeamId == -1) {
        throw Exception(l10n.failedToCreateTeam);
      }

      // Aggiorna l'utente con il teamId
      final updatedAccount = currentUser.copyWith(teamId: newTeamId);
      await userProvider.updateAccount(updatedAccount);
      userProvider.setCurrentTeamId(newTeamId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).teamCreatedSuccessfully),
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
            content: Text(
              AppLocalizations.of(context).errorGeneric(e.toString()),
            ),
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
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: ATLColors.background,
      appBar: AppBar(
        backgroundColor: ATLColors.getPrimaryColor(widget.currentSport),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.createTeamLabel,
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
                SnackBar(content: Text(l10n.darkModeComingSoonSnack)),
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
                                      l10n.uploadLogo,
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
                        hintText: l10n.teamName,
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
                          return l10n.enterTeamName;
                        }
                        if (value.trim().length < 3) {
                          return l10n.teamNameMinChars(3);
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Alias Team (opzionale)
                    TextFormField(
                      controller: _aliasController,
                      inputFormatters: [UpperCaseTextFormatter()],
                      decoration: InputDecoration(
                        hintText: l10n.teamAlias,
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
                          return l10n.enterTeamAlias;
                        }
                        if (value.trim().length < 3) {
                          return l10n.teamAliasExactChars(3);
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
                        hintText: l10n.teamDescription,
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
                      child: DropdownButtonFormField<int>(
                        value: _selectedCity,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: l10n.selectCityHint,
                        ),
                        items: _availableCities
                            .map(
                              (city) => DropdownMenuItem<int>(
                                value: city.id,
                                child: Text(city.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCity = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return l10n.selectTeamCity;
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
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: l10n.visibilityHint,
                        ),
                        items: [
                          DropdownMenuItem(value: true, child: Text(l10n.public)),
                          DropdownMenuItem(value: false, child: Text(l10n.private)),
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
                        backgroundColor: ATLColors.getPrimaryColor(
                          widget.currentSport,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        l10n.createTeamButton,
                        style: const TextStyle(
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
