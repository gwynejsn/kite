import 'package:flutter/material.dart';
import 'package:kite/features/auth/presentation/controllers/register_controller.dart';
import 'package:kite/shared/enums/gender.dart';

class RegisterProfileDetails extends StatefulWidget {
  final RegisterController controller;

  const RegisterProfileDetails({super.key, required this.controller});

  @override
  State<RegisterProfileDetails> createState() => _RegisterProfileDetailsState();
}

class _RegisterProfileDetailsState extends State<RegisterProfileDetails> {
  final _formKey = GlobalKey<FormState>();

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
    final request = widget.controller.value.request;

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
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 18),

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
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
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
  }
}
