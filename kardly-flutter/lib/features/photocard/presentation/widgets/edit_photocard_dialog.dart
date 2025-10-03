import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/api_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/presentation/widgets/custom_buttons.dart';

class EditPhotocardDialog extends StatefulWidget {
  final String photocardId;
  final String? currentGroupId;
  final String? currentMemberId;
  final String? currentAlbumId;
  final String? currentGroupName;
  final String? currentMemberName;
  final String? currentAlbumName;
  final VoidCallback? onUpdated;

  const EditPhotocardDialog({
    super.key,
    required this.photocardId,
    this.currentGroupId,
    this.currentMemberId,
    this.currentAlbumId,
    this.currentGroupName,
    this.currentMemberName,
    this.currentAlbumName,
    this.onUpdated,
  });

  @override
  State<EditPhotocardDialog> createState() => _EditPhotocardDialogState();
}

class _EditPhotocardDialogState extends State<EditPhotocardDialog> {
  List<Map<String, dynamic>> _groups = [];
  List<Map<String, dynamic>> _members = [];
  List<Map<String, dynamic>> _albums = [];
  
  String? _selectedGroupId;
  String? _selectedMemberId;
  String? _selectedAlbumId;
  
  bool _isLoading = true;
  bool _isUpdating = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedGroupId = widget.currentGroupId;
    _selectedMemberId = widget.currentMemberId;
    _selectedAlbumId = widget.currentAlbumId;
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Load all groups
      _groups = await ApiService.getGroups();

      // If a group is selected, load its members and albums
      if (_selectedGroupId != null) {
        await _loadGroupData(_selectedGroupId!);
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadGroupData(String groupId) async {
    try {
      // Load members for the selected group
      _members = await ApiService.getMembers(groupId: groupId);

      // Load albums for the selected group
      _albums = await ApiService.getAlbums(groupId: groupId);

      setState(() {});
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  bool get _hasChanges {
    return _selectedGroupId != widget.currentGroupId ||
           _selectedMemberId != widget.currentMemberId ||
           _selectedAlbumId != widget.currentAlbumId;
  }

  bool get _canUpdate {
    return _hasChanges && !_isUpdating;
  }

  Future<void> _updatePhotocard() async {
    if (!_canUpdate) return;

    try {
      setState(() {
        _isUpdating = true;
        _error = null;
      });

      await ApiService.updatePhotocard(
        photocardId: widget.photocardId,
        groupId: _selectedGroupId,
        memberId: _selectedMemberId,
        albumId: _selectedAlbumId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photocard updated successfully!'),
            backgroundColor: AppTheme.success,
          ),
        );

        // Call the callback to refresh the parent page
        widget.onUpdated?.call();

        // Close the dialog
        context.pop();
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isUpdating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(
                  Icons.edit,
                  color: AppTheme.primaryPurple,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Edit Photocard',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.charcoal,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_error != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Error loading data',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.error,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _error!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.error,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SecondaryButton(
                      text: 'Retry',
                      onPressed: _loadData,
                    ),
                  ],
                ),
              )
            else
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Current values display
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.lightGray.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Current Information',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.darkGray,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('Group: ${widget.currentGroupName ?? 'Not set'}'),
                            Text('Member: ${widget.currentMemberName ?? 'Not set'}'),
                            Text('Album: ${widget.currentAlbumName ?? 'Not set'}'),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Group dropdown
                      const Text(
                        'Group',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.charcoal,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedGroupId,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        hint: const Text('Select a group'),
                        items: _groups.map((group) {
                          return DropdownMenuItem<String>(
                            value: group['id'],
                            child: Text(group['name']),
                          );
                        }).toList(),
                        onChanged: (value) async {
                          setState(() {
                            _selectedGroupId = value;
                            _selectedMemberId = null;
                            _selectedAlbumId = null;
                            _members = [];
                            _albums = [];
                          });
                          
                          if (value != null) {
                            await _loadGroupData(value);
                          }
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Member dropdown
                      const Text(
                        'Member',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.charcoal,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedMemberId,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        hint: const Text('Select a member'),
                        items: _members.map((member) {
                          return DropdownMenuItem<String>(
                            value: member['id'],
                            child: Text(member['stage_name'] ?? member['name']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedMemberId = value;
                          });
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Album dropdown
                      const Text(
                        'Album',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.charcoal,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedAlbumId,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        hint: const Text('Select an album'),
                        items: _albums.map((album) {
                          return DropdownMenuItem<String>(
                            value: album['id'],
                            child: Text(album['title']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedAlbumId = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            
            const SizedBox(height: 16),

            // No changes message
            if (!_hasChanges && !_isLoading)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.lightGray.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: AppTheme.darkGray.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Make changes to update the photocard',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.darkGray.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    text: 'Cancel',
                    onPressed: () => context.pop(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PrimaryButton(
                    text: _isUpdating ? 'Updating...' : 'Update',
                    onPressed: _canUpdate ? _updatePhotocard : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
