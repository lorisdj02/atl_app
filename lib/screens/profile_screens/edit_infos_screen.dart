import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../database/db_controller.dart';
import '../../models/sport_category.dart';
import '../../models/user.dart';
import '../../models/player.dart';
import '../../utils/atl_colors.dart';
import '../../widgets/atl_textfield.dart';
import '../../widgets/atl_button.dart';
import '../../widgets/info_row_widget.dart';

class EditInfosScreen extends StatefulWidget {
  final SportCategory currentSport;

  const EditInfosScreen({
    super.key,
    required this.currentSport,
  });

  @override
  State<EditInfosScreen> createState() => _EditInfosScreenState();
}

class _EditInfosScreenState extends State<EditInfosScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _usernameController;
  late TextEditingController _phoneController;
  late TextEditingController _oldPasswordController;
  late TextEditingController _newPasswordController;
  
  bool _isLoading = false;
  bool _hasChanges = false;
  bool _showPasswordFields = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).activeUser;
    
    _usernameController = TextEditingController(text: user?.username ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _oldPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    
    // Add listeners to detect changes
    _usernameController.addListener(_onFieldChanged);
    _phoneController.addListener(_onFieldChanged);
    _oldPasswordController.addListener(_onFieldChanged);
    _newPasswordController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.activeUser;
    if (user == null) return;
    
    // Validate password fields if changing password
    if (_oldPasswordController.text.isNotEmpty || _newPasswordController.text.isNotEmpty) {
      if (_oldPasswordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter your current password'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      if (_newPasswordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a new password'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      if (_newPasswordController.text.length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('New password must be at least 6 characters'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      // Check if old password matches
      if (user.passwordMD5 != _oldPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Current password is incorrect'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }
    
    setState(() => _isLoading = true);
    
    try {
      // Update user info through repository
      final bool success = await DB.Users.updateUserInfo(
        id: user.id,
        username: _usernameController.text != user.username 
            ? _usernameController.text 
            : null,
        phone: _phoneController.text != user.phone 
            ? _phoneController.text 
            : null,
        oldPasswordMD5: _oldPasswordController.text.isNotEmpty 
            ? _oldPasswordController.text 
            : null,
        newPasswordMD5: _newPasswordController.text.isNotEmpty 
            ? _newPasswordController.text 
            : null,
      );
      
      if (!success) {
        throw Exception('Failed to update user info');
      }
      
      // Retrieve updated user from repository
      final updatedUser = await DB.Users.getById(user.id);
      if (updatedUser == null) {
        throw Exception('Failed to retrieve updated user');
      }
      
      // Update UserProvider
      await userProvider.updateUser(updatedUser);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        
        setState(() {
          _hasChanges = false;
          _oldPasswordController.clear();
          _newPasswordController.clear();
          _showPasswordFields = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
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
    final user = Provider.of<UserProvider>(context).activeUser;
    final isPlayer = user is Player;

    return Scaffold(
      backgroundColor: ATLColors.background,
      appBar: AppBar(
        backgroundColor: ATLColors.darkBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'EDIT PROFILE',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Picture
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: ATLColors.getPrimaryColor(widget.currentSport).withOpacity(0.2),
                      backgroundImage: user?.imageUrl != null 
                          ? NetworkImage(user!.imageUrl!) 
                          : null,
                      child: user?.imageUrl == null
                          ? Icon(
                              Icons.person,
                              color: ATLColors.getPrimaryColor(widget.currentSport),
                              size: 60,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          // TODO: Implement image picker
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Photo upload coming soon')),
                          );
                        },
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: ATLColors.getPrimaryColor(widget.currentSport),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Editable Information Section
              const Text(
                'Editable Information',
                style: TextStyle(
                  color: ATLColors.darkBlue,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              _buildLabel('Username'),
              ATLTextField(
                controller: _usernameController,
                hintText: 'Enter username',
              ),
              const SizedBox(height: 16),
              
              _buildLabel('Phone'),
              ATLTextField(
                controller: _phoneController,
                hintText: 'Enter phone number',
                keyboardType: TextInputType.phone,
              ),
              
              const SizedBox(height: 32),
              
              // Change Password Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Change Password',
                    style: TextStyle(
                      color: ATLColors.darkBlue,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _showPasswordFields ? Icons.expand_less : Icons.expand_more,
                      color: ATLColors.darkBlue,
                    ),
                    onPressed: () {
                      setState(() {
                        _showPasswordFields = !_showPasswordFields;
                        if (!_showPasswordFields) {
                          _oldPasswordController.clear();
                          _newPasswordController.clear();
                        }
                      });
                    },
                  ),
                ],
              ),
              
              if (_showPasswordFields) ...[
                const SizedBox(height: 16),
                _buildLabel('Current Password'),
                ATLTextField(
                  controller: _oldPasswordController,
                  hintText: 'Enter current password',
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                _buildLabel('New Password'),
                ATLTextField(
                  controller: _newPasswordController,
                  hintText: 'Enter new password (min 6 characters)',
                  obscureText: true,
                ),
              ],
              
              const SizedBox(height: 32),
              
              // Account Details (Read-only)
              const Text(
                'Account Details',
                style: TextStyle(
                  color: ATLColors.darkBlue,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              InfoRowWidget(label: 'Email', value: user?.email ?? 'N/A'),
              if (isPlayer) ...[
                InfoRowWidget(label: 'Name', value: user.name),
                InfoRowWidget(label: 'Surname', value: user.surname),
                InfoRowWidget(label: 'Birth Date', value: _formatDate(user.birthdate)),
              ],
              InfoRowWidget(label: 'Role', value: user?.roleDisplayName ?? 'N/A'),
              InfoRowWidget(label: 'Member since', value: _formatDate(user?.createdAt)),
              InfoRowWidget(label: 'VIP Status', value: user?.isVip == true ? 'Active' : 'Inactive'),
              
              const SizedBox(height: 32),
              
              // Save Button
              ATLButton(
                text: _isLoading ? 'Saving...' : 'Save Changes',
                size: ATLButtonSize.large,
                isFilled: true,
                color: _hasChanges 
                    ? ATLColors.darkBlue 
                    : ATLColors.subtext,
                fullWidth: true,
                onPressed: _hasChanges && !_isLoading ? _saveChanges : () {},
              ),
              

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: ATLColors.darkBlue,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }
}
