/**
 * Add Photocard Page
 * 
 * Allows users to upload a new photocard to the database.
 * Users can select an image from their device and optionally provide
 * metadata such as group, member, and album information.
 */

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/presentation/widgets/custom_buttons.dart';
import '../../../../shared/presentation/widgets/custom_card.dart';
import '../providers/add_photocard_provider.dart';

class AddPhotocardPage extends StatefulWidget {
  const AddPhotocardPage({super.key});

  @override
  State<AddPhotocardPage> createState() => _AddPhotocardPageState();
}

class _AddPhotocardPageState extends State<AddPhotocardPage> {
  final _formKey = GlobalKey<FormState>();
  final _groupIdController = TextEditingController();
  final _memberIdController = TextEditingController();
  final _albumIdController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  
  File? _selectedImage;
  String? _imagePath;

  @override
  void dispose() {
    _groupIdController.dispose();
    _memberIdController.dispose();
    _albumIdController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _imagePath = image.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: ${e.toString()}'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppTheme.primaryPurple),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppTheme.primaryPurple),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (_imagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an image'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      final provider = context.read<AddPhotocardProvider>();
      
      final success = await provider.addPhotocard(
        imagePath: _imagePath!,
        groupId: _groupIdController.text.trim().isEmpty 
            ? null 
            : _groupIdController.text.trim(),
        memberId: _memberIdController.text.trim().isEmpty 
            ? null 
            : _memberIdController.text.trim(),
        albumId: _albumIdController.text.trim().isEmpty 
            ? null 
            : _albumIdController.text.trim(),
      );

      if (success && mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.successMessage ?? 'Photocard added successfully!'),
            backgroundColor: AppTheme.success,
          ),
        );
        
        // Navigate back after a short delay
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            context.pop();
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Add Photocard'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildImagePicker(),
                const SizedBox(height: 24),
                _buildMetadataForm(),
                const SizedBox(height: 32),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload Photocard',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Add a new photocard to the collection',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppTheme.darkGray,
          ),
        ),
      ],
    );
  }

  Widget _buildImagePicker() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.image, color: AppTheme.primaryPurple),
              const SizedBox(width: 8),
              Text(
                'Photocard Image',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Text(' *', style: TextStyle(color: AppTheme.error)),
            ],
          ),
          const SizedBox(height: 16),
          
          if (_selectedImage != null)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    _selectedImage!,
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _selectedImage = null;
                        _imagePath = null;
                      });
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.white,
                      foregroundColor: AppTheme.charcoal,
                    ),
                  ),
                ),
              ],
            )
          else
            InkWell(
              onTap: _showImageSourceDialog,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: AppTheme.lightPurple.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.primaryPurple.withValues(alpha: 0.5),
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate,
                      size: 64,
                      color: AppTheme.primaryPurple,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Tap to select image',
                      style: TextStyle(
                        color: AppTheme.darkGray,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'JPG, PNG, or WEBP (max 5MB)',
                      style: TextStyle(
                        color: AppTheme.darkGray,
                        fontSize: 12,
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

  Widget _buildMetadataForm() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: AppTheme.primaryPurple),
              const SizedBox(width: 8),
              Text(
                'Metadata (Optional)',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Provide additional information about the photocard',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.darkGray,
            ),
          ),
          const SizedBox(height: 16),
          
          // Group ID
          TextFormField(
            controller: _groupIdController,
            decoration: const InputDecoration(
              labelText: 'Group ID',
              hintText: 'Enter K-pop group UUID',
              prefixIcon: Icon(Icons.group),
            ),
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                // Basic UUID format validation
                final uuidRegex = RegExp(
                  r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
                  caseSensitive: false,
                );
                if (!uuidRegex.hasMatch(value)) {
                  return 'Please enter a valid UUID';
                }
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // Member ID
          TextFormField(
            controller: _memberIdController,
            decoration: const InputDecoration(
              labelText: 'Member ID',
              hintText: 'Enter member UUID',
              prefixIcon: Icon(Icons.person),
            ),
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final uuidRegex = RegExp(
                  r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
                  caseSensitive: false,
                );
                if (!uuidRegex.hasMatch(value)) {
                  return 'Please enter a valid UUID';
                }
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // Album ID
          TextFormField(
            controller: _albumIdController,
            decoration: const InputDecoration(
              labelText: 'Album ID',
              hintText: 'Enter album UUID',
              prefixIcon: Icon(Icons.album),
            ),
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final uuidRegex = RegExp(
                  r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
                  caseSensitive: false,
                );
                if (!uuidRegex.hasMatch(value)) {
                  return 'Please enter a valid UUID';
                }
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Consumer<AddPhotocardProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            // Error Message
            if (provider.error != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppTheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.error.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppTheme.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        provider.error!,
                        style: const TextStyle(
                          color: AppTheme.error,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
            // Submit Button
            PrimaryButton(
              text: 'Upload Photocard',
              icon: Icons.cloud_upload,
              isLoading: provider.isLoading,
              onPressed: _handleSubmit,
            ),
          ],
        );
      },
    );
  }
}

