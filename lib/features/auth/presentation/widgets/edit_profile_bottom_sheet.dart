import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:news_app_mvvm/core/theme/app_theme.dart';
import 'package:news_app_mvvm/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:news_app_mvvm/features/news/presentation/viewmodels/news_feed_viewmodel.dart';
import 'package:news_app_mvvm/features/auth/domain/entities/user.dart';
import 'package:news_app_mvvm/injection_container.dart';

class EditProfileBottomSheet extends StatefulWidget {
  const EditProfileBottomSheet({super.key});

  /// Helper to show this bottom sheet globally
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: context.read<AuthViewModel>()),
          ChangeNotifierProvider(create: (_) => sl<NewsFeedViewModel>()..fetchCategories()),
        ],
        child: const EditProfileBottomSheet(),
      ),
    );
  }

  @override
  State<EditProfileBottomSheet> createState() => _EditProfileBottomSheetState();
}

class _EditProfileBottomSheetState extends State<EditProfileBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _phoneController;
  
  Set<String> _selectedPreferences = {};
  
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthViewModel>().currentUser;
    
    _nameController = TextEditingController(text: user?.name ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    
    // Parse 'technology,sports' into a Set
    if (user != null && user.preferences.isNotEmpty && user.preferences != '{}') {
      _selectedPreferences = user.preferences.split(',').map((e) => e.trim()).toSet();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final authViewModel = context.read<AuthViewModel>();
      final currentUser = authViewModel.currentUser;
      if (currentUser == null) return;

      final updatedUser = User(
        id: currentUser.id,
        name: _nameController.text.trim(),
        email: currentUser.email, // email usually cannot be changed easily
        avatarUrl: currentUser.avatarUrl, // Mock: We don't upload file in this simplified MVVM
        bio: _bioController.text.trim(),
        phone: _phoneController.text.trim(),
        preferences: _selectedPreferences.join(','),
      );

      await authViewModel.updateProfile(updatedUser);

      if (mounted) {
        if (authViewModel.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authViewModel.errorMessage!),
              backgroundColor: Colors.redAccent,
            ),
          );
        } else {
          Navigator.pop(context); // Close the sheet
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully! ✨'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // We need to shift up the bottom sheet if the keyboard appears
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        final isLoading = authViewModel.isLoading;
        final user = authViewModel.currentUser;
        final currentAvatarUrl = user?.avatarUrl;

        return Container(
          margin: EdgeInsets.only(top: 60, bottom: keyboardHeight),
          decoration: const BoxDecoration(
            color: AppTheme.backgroundDark,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Grabber
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 20),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Edit Profil',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white24),
              
              // Scrollable Form Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Avatar Picker
                        Center(
                          child: GestureDetector(
                            onTap: isLoading ? null : _pickImage,
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.grey[200],
                                  backgroundImage: _selectedImage != null
                                      ? FileImage(_selectedImage!) as ImageProvider
                                      : (currentAvatarUrl != null && currentAvatarUrl.isNotEmpty
                                          ? CachedNetworkImageProvider(currentAvatarUrl)
                                          : null),
                                  child: (_selectedImage == null && (currentAvatarUrl == null || currentAvatarUrl.isEmpty))
                                      ? const Icon(Icons.person, size: 40, color: Colors.grey)
                                      : null,
                                ),
                                Container(
                                  decoration: const BoxDecoration(
                                    color: AppTheme.primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(8),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Form Fields
                        const Text(
                          'Info Personal',
                          style: TextStyle(color: AppTheme.textMuted, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        
                        TextFormField(
                          controller: _nameController,
                          enabled: !isLoading,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration('Nama Lengkap', Icons.person_outline),
                          validator: (val) => (val == null || val.isEmpty) ? 'Nama wajib diisi' : null,
                        ),
                        const SizedBox(height: 16),
                        
                        TextFormField(
                          controller: _bioController,
                          enabled: !isLoading,
                          maxLines: 3,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration('Bio / Tentang saya', Icons.info_outline),
                        ),
                        const SizedBox(height: 16),
                        
                        TextFormField(
                          controller: _phoneController,
                          enabled: !isLoading,
                          keyboardType: TextInputType.phone,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration('Nomor Telepon', Icons.phone_outlined),
                        ),
                        const SizedBox(height: 24),
                        
                        const Text(
                          'Topik Pilihan',
                          style: TextStyle(color: AppTheme.textMuted, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        
                        // Category Chips for Preferences
                        Consumer<NewsFeedViewModel>(
                          builder: (context, newsFeedVm, _) {
                            final catState = newsFeedVm.categoryState;
                            if (catState.isLoading) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (catState.isSuccess && catState.data != null) {
                              return Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: catState.data!.map((cat) {
                                  final isSelected = _selectedPreferences.contains(cat.slug);
                                  return FilterChip(
                                    label: Text(
                                      cat.name,
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : AppTheme.textSecondary,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                    selected: isSelected,
                                    selectedColor: AppTheme.primaryColor,
                                    backgroundColor: AppTheme.surfaceElevated,
                                    side: BorderSide.none,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    onSelected: (selected) {
                                      setState(() {
                                        if (selected) {
                                          _selectedPreferences.add(cat.slug);
                                        } else {
                                          _selectedPreferences.remove(cat.slug);
                                        }
                                      });
                                    },
                                  );
                                }).toList(),
                              );
                            }
                            return const Text('Gagal memuat kategori', style: TextStyle(color: Colors.red));
                          },
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Submit Button
                        ElevatedButton(
                          onPressed: isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Simpan Profil',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppTheme.textMuted),
      filled: true,
      fillColor: AppTheme.surfaceElevated,
      labelStyle: const TextStyle(color: AppTheme.textMuted),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
      ),
    );
  }
}
