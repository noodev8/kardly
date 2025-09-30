/// Add Photocard Page
///
/// Allows users to upload a new photocard to the database.
/// Users can select an image from their device and optionally provide
/// metadata such as group, member, and album information.
library;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/api_service.dart';
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
  final _groupSearchController = TextEditingController();
  final _memberSearchController = TextEditingController();
  final _albumSearchController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;
  String? _imagePath;

  // Selected entities
  Map<String, dynamic>? _selectedGroup;
  Map<String, dynamic>? _selectedMember;
  Map<String, dynamic>? _selectedAlbum;

  // Lists for dropdowns
  List<Map<String, dynamic>> _groups = [];
  List<Map<String, dynamic>> _members = [];
  List<Map<String, dynamic>> _albums = [];

  bool _isLoadingGroups = false;
  bool _isLoadingMembers = false;
  bool _isLoadingAlbums = false;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  @override
  void dispose() {
    _groupSearchController.dispose();
    _memberSearchController.dispose();
    _albumSearchController.dispose();
    super.dispose();
  }

  Future<void> _loadGroups({String? search}) async {
    setState(() => _isLoadingGroups = true);
    try {
      final groups = await ApiService.getGroups(search: search);
      setState(() {
        _groups = groups;
        _isLoadingGroups = false;
      });
    } catch (e) {
      setState(() => _isLoadingGroups = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load groups: ${e.toString()}'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  Future<void> _loadMembers({String? search}) async {
    if (_selectedGroup == null) return;

    setState(() => _isLoadingMembers = true);
    try {
      final members = await ApiService.getMembers(
        groupId: _selectedGroup!['id'],
        search: search,
      );
      setState(() {
        _members = members;
        _isLoadingMembers = false;
      });
    } catch (e) {
      setState(() => _isLoadingMembers = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load members: ${e.toString()}'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  Future<void> _loadAlbums({String? search}) async {
    if (_selectedGroup == null) return;

    setState(() => _isLoadingAlbums = true);
    try {
      final albums = await ApiService.getAlbums(
        groupId: _selectedGroup!['id'],
        search: search,
      );
      setState(() {
        _albums = albums;
        _isLoadingAlbums = false;
      });
    } catch (e) {
      setState(() => _isLoadingAlbums = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load albums: ${e.toString()}'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
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
        groupId: _selectedGroup?['id'],
        memberId: _selectedMember?['id'],
        albumId: _selectedAlbum?['id'],
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

  void _showAddGroupDialog() {
    final nameController = TextEditingController();
    final dialogContext = context;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Group'),
        content: SingleChildScrollView(
          child: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Group Name',
              hintText: 'e.g., BTS, BLACKPINK',
            ),
            autofocus: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;

              Navigator.pop(context);

              try {
                final result = await ApiService.createGroup(
                  name: nameController.text.trim(),
                );

                // Reload groups first
                await _loadGroups();

                // Then find and select the created/existing group from the loaded list
                final groupId = result['group_id'];
                final selectedGroup = _groups.firstWhere(
                  (g) => g['id'] == groupId,
                  orElse: () => {'id': groupId, 'name': result['name']},
                );

                setState(() {
                  _selectedGroup = selectedGroup;
                });

                // Load members and albums for the selected group
                await _loadMembers();
                await _loadAlbums();

                if (mounted) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: Text(result['already_exists'] == true
                          ? 'Group already exists'
                          : 'Group created successfully'),
                      backgroundColor: AppTheme.success,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: Text('Failed to create group: ${e.toString()}'),
                      backgroundColor: AppTheme.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddMemberDialog() {
    if (_selectedGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a group first'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    final nameController = TextEditingController();
    final stageNameController = TextEditingController();
    final dialogContext = context;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Member'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Real Name',
                  hintText: 'e.g., Kim Taehyung',
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: stageNameController,
                decoration: const InputDecoration(
                  labelText: 'Stage Name (Optional)',
                  hintText: 'e.g., V',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;

              Navigator.pop(context);

              try {
                final result = await ApiService.createMember(
                  groupId: _selectedGroup!['id'],
                  name: nameController.text.trim(),
                  stageName: stageNameController.text.trim().isEmpty
                      ? null
                      : stageNameController.text.trim(),
                );

                // Reload members first
                await _loadMembers();

                // Then find and select the created/existing member from the loaded list
                final memberId = result['member_id'];
                final selectedMember = _members.firstWhere(
                  (m) => m['id'] == memberId,
                  orElse: () => {
                    'id': memberId,
                    'name': result['name'],
                    'stage_name': result['stage_name'],
                  },
                );

                setState(() {
                  _selectedMember = selectedMember;
                });

                if (mounted) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: Text(result['already_exists'] == true
                          ? 'Member already exists'
                          : 'Member created successfully'),
                      backgroundColor: AppTheme.success,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: Text('Failed to create member: ${e.toString()}'),
                      backgroundColor: AppTheme.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddAlbumDialog() {
    if (_selectedGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a group first'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    final titleController = TextEditingController();
    final dialogContext = context;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Album'),
        content: SingleChildScrollView(
          child: TextField(
            controller: titleController,
            decoration: const InputDecoration(
              labelText: 'Album Title',
              hintText: 'e.g., Love Yourself: Tear',
            ),
            autofocus: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (titleController.text.trim().isEmpty) return;

              Navigator.pop(context);

              try {
                final result = await ApiService.createAlbum(
                  groupId: _selectedGroup!['id'],
                  title: titleController.text.trim(),
                );

                // Reload albums first
                await _loadAlbums();

                // Then find and select the created/existing album from the loaded list
                final albumId = result['album_id'];
                final selectedAlbum = _albums.firstWhere(
                  (a) => a['id'] == albumId,
                  orElse: () => {
                    'id': albumId,
                    'title': result['title'],
                  },
                );

                setState(() {
                  _selectedAlbum = selectedAlbum;
                });

                if (mounted) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: Text(result['already_exists'] == true
                          ? 'Album already exists'
                          : 'Album created successfully'),
                      backgroundColor: AppTheme.success,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: Text('Failed to create album: ${e.toString()}'),
                      backgroundColor: AppTheme.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
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
                'Photocard Details',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Select or add group, member, and album information',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.darkGray,
            ),
          ),
          const SizedBox(height: 16),

          // Group Selector
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<Map<String, dynamic>>(
                  value: _selectedGroup,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'K-pop Group',
                    prefixIcon: Icon(Icons.group),
                    hintText: 'Select a group',
                  ),
                  items: _groups.map((group) {
                    return DropdownMenuItem(
                      value: group,
                      child: Text(
                        group['name'] ?? '',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedGroup = value;
                      _selectedMember = null;
                      _selectedAlbum = null;
                      _members = [];
                      _albums = [];
                    });
                    if (value != null) {
                      _loadMembers();
                      _loadAlbums();
                    }
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle, color: AppTheme.primaryPurple),
                onPressed: _showAddGroupDialog,
                tooltip: 'Add new group',
              ),
            ],
          ),

          if (_isLoadingGroups)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(child: CircularProgressIndicator()),
            ),

          const SizedBox(height: 16),

          // Member Selector
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<Map<String, dynamic>>(
                  value: _selectedMember,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Member',
                    prefixIcon: const Icon(Icons.person),
                    hintText: _selectedGroup == null
                        ? 'Select a group first'
                        : 'Select a member',
                  ),
                  items: _members.map((member) {
                    final displayName = member['stage_name'] != null && member['stage_name'].toString().isNotEmpty
                        ? '${member['stage_name']} (${member['name']})'
                        : member['name'];
                    return DropdownMenuItem(
                      value: member,
                      child: Text(
                        displayName ?? '',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: _selectedGroup == null ? null : (value) {
                    setState(() => _selectedMember = value);
                  },
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.add_circle,
                  color: _selectedGroup == null
                      ? AppTheme.darkGray
                      : AppTheme.primaryPurple,
                ),
                onPressed: _selectedGroup == null ? null : _showAddMemberDialog,
                tooltip: 'Add new member',
              ),
            ],
          ),

          if (_isLoadingMembers)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(child: CircularProgressIndicator()),
            ),

          const SizedBox(height: 16),

          // Album Selector
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<Map<String, dynamic>>(
                  value: _selectedAlbum,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Album',
                    prefixIcon: const Icon(Icons.album),
                    hintText: _selectedGroup == null
                        ? 'Select a group first'
                        : 'Select an album',
                  ),
                  items: _albums.map((album) {
                    return DropdownMenuItem(
                      value: album,
                      child: Text(
                        album['title'] ?? '',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: _selectedGroup == null ? null : (value) {
                    setState(() => _selectedAlbum = value);
                  },
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.add_circle,
                  color: _selectedGroup == null
                      ? AppTheme.darkGray
                      : AppTheme.primaryPurple,
                ),
                onPressed: _selectedGroup == null ? null : _showAddAlbumDialog,
                tooltip: 'Add new album',
              ),
            ],
          ),

          if (_isLoadingAlbums)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Consumer<AddPhotocardProvider>(
      builder: (context, provider, child) {
        return PrimaryButton(
          text: 'Upload Photocard',
          icon: Icons.cloud_upload,
          isLoading: provider.isLoading,
          onPressed: _handleSubmit,
        );
      },
    );
  }
}

