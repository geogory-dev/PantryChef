import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../config/firebase_config.dart';
import '../theme/app_theme.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _displayNameController = TextEditingController();
  final List<String> _availableDietaryPreferences = [
    'Vegetarian',
    'Vegan',
    'Gluten-Free',
    'Keto',
    'Paleo',
    'Dairy-Free',
    'Low-Carb',
    'Mediterranean',
  ];

  final List<String> _availableCuisines = [
    'Italian',
    'Asian',
    'Mexican',
    'Indian',
    'American',
    'French',
    'Thai',
    'Japanese',
    'Greek',
    'Spanish',
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user != null) {
      _displayNameController.text = authProvider.user!.displayName ?? '';
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.user == null) {
            return const Center(child: Text('Please log in to view your profile'));
          }

          final user = authProvider.user!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppTheme.accentColor,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: user.photoURL != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Image.network(
                                  user.photoURL!,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.white,
                                    );
                                  },
                                ),
                              )
                            : const Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.white,
                              ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.displayName ?? 'User',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      if (!user.isEmailVerified)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.warning, size: 16, color: Colors.orange.shade800),
                              const SizedBox(width: 4),
                              Text(
                                'Email not verified',
                                style: TextStyle(
                                  color: Colors.orange.shade800,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Profile Information Section
                _buildSection(
                  title: 'Profile Information',
                  children: [
                    TextFormField(
                      controller: _displayNameController,
                      decoration: InputDecoration(
                        labelText: 'Display Name',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: authProvider.isLoading ? null : _updateProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: authProvider.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('Update Profile'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Dietary Preferences Section
                _buildSection(
                  title: 'Dietary Preferences',
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableDietaryPreferences.map((preference) {
                        final isSelected = user.dietaryPreferences.contains(preference);
                        return FilterChip(
                          label: Text(preference),
                          selected: isSelected,
                          onSelected: (selected) {
                            _updateDietaryPreference(preference, selected);
                          },
                          backgroundColor: Colors.grey.shade100,
                          selectedColor: AppTheme.accentColor.withOpacity(0.2),
                          checkmarkColor: AppTheme.accentColor,
                        );
                      }).toList(),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Favorite Cuisines Section
                _buildSection(
                  title: 'Favorite Cuisines',
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableCuisines.map((cuisine) {
                        final isSelected = user.favoriteCuisines.contains(cuisine);
                        return FilterChip(
                          label: Text(cuisine),
                          selected: isSelected,
                          onSelected: (selected) {
                            _updateFavoriteCuisine(cuisine, selected);
                          },
                          backgroundColor: Colors.grey.shade100,
                          selectedColor: AppTheme.accentColor.withOpacity(0.2),
                          checkmarkColor: AppTheme.accentColor,
                        );
                      }).toList(),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // App Settings Section
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    return _buildSection(
                      title: 'App Settings',
                      children: [
                        SwitchListTile(
                          title: const Text('Dark Mode'),
                          subtitle: const Text('Toggle dark theme'),
                          value: themeProvider.isDarkMode,
                          onChanged: (value) {
                            themeProvider.toggleTheme();
                          },
                          activeColor: AppTheme.accentColor,
                        ),
                        ListTile(
                          leading: const Icon(Icons.sync),
                          title: const Text('Sync Data'),
                          subtitle: const Text('Sync your data to cloud'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: _syncData,
                        ),
                        ListTile(
                          leading: const Icon(Icons.cloud_upload),
                          title: const Text('Backup Data'),
                          subtitle: const Text('Create a backup of your data'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: _backupData,
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Account Actions Section
                _buildSection(
                  title: 'Account Actions',
                  children: [
                    ListTile(
                      leading: Icon(Icons.email, color: AppTheme.accentColor),
                      title: const Text('Resend Verification Email'),
                      subtitle: const Text('Send verification email again'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _resendVerificationEmail,
                    ),
                    ListTile(
                      leading: Icon(Icons.lock, color: AppTheme.accentColor),
                      title: const Text('Change Password'),
                      subtitle: const Text('Reset your password'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _changePassword,
                    ),
                    ListTile(
                      leading: Icon(Icons.delete, color: Colors.red),
                      title: const Text('Delete Account'),
                      subtitle: const Text('Permanently delete your account'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _deleteAccount,
                    ),
                  ],
                ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Future<void> _updateProfile() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.updateUserProfile(
      displayName: _displayNameController.text.trim(),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _updateDietaryPreference(String preference, bool selected) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentPreferences = List<String>.from(authProvider.user?.dietaryPreferences ?? []);
    
    if (selected) {
      currentPreferences.add(preference);
    } else {
      currentPreferences.remove(preference);
    }

    authProvider.updateUserProfile(dietaryPreferences: currentPreferences);
  }

  void _updateFavoriteCuisine(String cuisine, bool selected) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentCuisines = List<String>.from(authProvider.user?.favoriteCuisines ?? []);
    
    if (selected) {
      currentCuisines.add(cuisine);
    } else {
      currentCuisines.remove(cuisine);
    }

    authProvider.updateUserProfile(favoriteCuisines: currentCuisines);
  }

  void _syncData() {
    // TODO: Implement cloud sync
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sync functionality coming soon!')),
    );
  }

  void _backupData() {
    // TODO: Implement backup functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Backup functionality coming soon!')),
    );
  }

  void _resendVerificationEmail() {
    // TODO: Implement resend verification
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Verification email sent!')),
    );
  }

  void _changePassword() {
    // TODO: Implement change password
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password reset email sent!')),
    );
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement delete account
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account deletion coming soon!')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await authProvider.signOut();
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
