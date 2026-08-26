import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kite/features/auth/presentation/controllers/register_controller.dart';
import 'package:kite/features/auth/presentation/controllers/register_state.dart';
import 'package:kite/shared/enums/gender.dart';

class RegisterProfileDetails extends StatefulWidget {
  final RegisterController controller;

  const RegisterProfileDetails({super.key, required this.controller});

  @override
  State<RegisterProfileDetails> createState() => _RegisterProfileDetailsState();
}

class _RegisterProfileDetailsState extends State<RegisterProfileDetails> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 80,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        widget.controller.updateProfileImage(bytes, image.name);
      }
    } catch (e) {
      debugPrint('Error picking profile image: $e');
    }
  }

  void _showImagePickerModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: Colors.blue),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded, color: Colors.green),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      FocusScope.of(context).unfocus();
      widget.controller.nextStep();
    }
  }

  void _previousStep() {
    _formKey.currentState?.save();
    widget.controller.previousStep();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ValueListenableBuilder<RegisterState>(
      valueListenable: widget.controller,
      builder: (context, state, child) {
        final request = state.request;
        final profileImageBytes = state.profileImageBytes;

        return Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter your personal details:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 18),

              // Profile Picture Avatar Picker
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 46,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      backgroundImage: profileImageBytes != null
                          ? MemoryImage(profileImageBytes)
                          : null,
                      child: profileImageBytes == null
                          ? Icon(
                              Icons.person_rounded,
                              size: 48,
                              color: theme.colorScheme.onPrimaryContainer,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: _showImagePickerModal,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.colorScheme.surface,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: TextButton(
                  onPressed: _showImagePickerModal,
                  child: const Text('Add Profile Photo'),
                ),
              ),
              const SizedBox(height: 12),

              // First Name Label & Input
              const Text(
                'First Name',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              TextFormField(
                initialValue: request.firstName,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: 'First Name',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'First name is required';
                  }
                  return null;
                },
                onSaved: (value) =>
                    widget.controller.updateFirstName(value?.trim() ?? ''),
              ),
              const SizedBox(height: 16),

              // Last Name Label & Input
              const Text(
                'Last Name',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              TextFormField(
                initialValue: request.lastName,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: 'Last Name',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Last name is required';
                  }
                  return null;
                },
                onSaved: (value) =>
                    widget.controller.updateLastName(value?.trim() ?? ''),
              ),
              const SizedBox(height: 16),

              // Gender Label & Dropdown
              const Text(
                'Gender',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<Gender>(
                initialValue: request.gender,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.wc_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: Gender.values.map((gender) {
                  return DropdownMenuItem<Gender>(
                    value: gender,
                    child: Text(
                      gender.name[0].toUpperCase() + gender.name.substring(1),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    widget.controller.updateGender(value);
                  }
                },
                onSaved: (value) {
                  if (value != null) {
                    widget.controller.updateGender(value);
                  }
                },
              ),
              const SizedBox(height: 28),

              // Back & Continue Row Buttons
              Row(
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(80, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _previousStep,
                    child: const Row(
                      children: [
                        Icon(Icons.arrow_back_rounded, size: 18),
                        SizedBox(width: 4),
                        Text('Back'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52),
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _submitForm,
                      child: const Text(
                        'Continue',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}
