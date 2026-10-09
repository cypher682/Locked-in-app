import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/checkin_provider.dart';
import '../../../../core/services/checkin/checkin_service.dart';
import '../../../goals/presentation/providers/goal_provider.dart';

class CreateCheckinScreen extends ConsumerStatefulWidget {
  const CreateCheckinScreen({super.key});

  @override
  ConsumerState<CreateCheckinScreen> createState() => _CreateCheckinScreenState();
}

class _CreateCheckinScreenState extends ConsumerState<CreateCheckinScreen> {
  final _formKey = GlobalKey<FormState>();
  final _noteController = TextEditingController();
  final CheckinService _checkinService = CheckinService();
  
  String? _selectedGoalId;
  File? _selectedPhoto;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    // Load user's active goals
    Future.microtask(() => ref.read(goalProvider.notifier).loadGoals());
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(bool fromCamera) async {
    final photo = await _checkinService.pickPhoto(fromCamera: fromCamera);
    if (photo != null) {
      setState(() {
        _selectedPhoto = photo;
      });
    }
  }

  void _showPhotoSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickPhoto(true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickPhoto(false);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedGoalId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a goal')),
        );
        return;
      }

      setState(() => _isUploading = true);

      final checkinData = <String, dynamic>{
        'goal_id': _selectedGoalId,
      };

      // Add note if provided
      if (_noteController.text.trim().isNotEmpty) {
        checkinData['note'] = _noteController.text.trim();
      }

      // Convert photo to base64 if selected
      if (_selectedPhoto != null) {
        final base64Photo = await _checkinService.fileToBase64(_selectedPhoto!);
        if (base64Photo != null) {
          checkinData['photo_base64'] = base64Photo;
        }
      }

      final success = await ref.read(checkinProvider.notifier).createCheckin(checkinData);

      setState(() => _isUploading = false);

      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Check-in created successfully!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final goalState = ref.watch(goalProvider);
    final checkinState = ref.watch(checkinProvider);
    final activeGoals = goalState.goals.where((g) => g['status'] == 'active').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Check-in'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Goal Selector
              DropdownButtonFormField<String>(
                value: _selectedGoalId,
                decoration: const InputDecoration(
                  labelText: 'Goal *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.flag),
                ),
                items: activeGoals.map<DropdownMenuItem<String>>((goal) {
                  return DropdownMenuItem(
                    value: goal['id'],
                    child: Text(goal['title'] ?? 'Untitled'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGoalId = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a goal';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Note
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Note (optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                maxLength: 500,
              ),
              const SizedBox(height: 16),

              // Photo Section
              if (_selectedPhoto != null) ...[
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        _selectedPhoto!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black54,
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedPhoto = null;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // Add Photo Button
              OutlinedButton.icon(
                onPressed: _showPhotoSourceDialog,
                icon: const Icon(Icons.add_photo_alternate),
                label: Text(_selectedPhoto == null ? 'Add Photo' : 'Change Photo'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: 24),

              // Error message
              if (checkinState.error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[300]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          checkinState.error!,
                          style: TextStyle(color: Colors.red[700]),
                        ),
                      ),
                    ],
                  ),
                ),

              // Submit Button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isUploading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: _isUploading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Create Check-in'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
