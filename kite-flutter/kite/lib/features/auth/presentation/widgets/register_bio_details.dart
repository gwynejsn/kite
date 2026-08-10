import 'package:flutter/material.dart';
import 'package:kite/features/auth/presentation/controllers/register_controller.dart';
import 'package:kite/features/auth/presentation/controllers/register_state.dart';

class RegisterBioDetails extends StatefulWidget {
  final RegisterController controller;

  const RegisterBioDetails({
    super.key,
    required this.controller,
  });

  @override
  State<RegisterBioDetails> createState() => _RegisterBioDetailsState();
}

class _RegisterBioDetailsState extends State<RegisterBioDetails> {
  final _formKey = GlobalKey<FormState>();

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      FocusScope.of(context).unfocus();
      widget.controller.register();
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
            'Tell us a bit about yourself:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 18),

          // Bio Label & Input
          const Text(
            'Bio (Optional)',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          TextFormField(
            initialValue: request.bio,
            maxLines: 4,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: 'Share a short bio with your friends on Kite...',
              prefixIcon: const Padding(
                padding: EdgeInsets.only(bottom: 50),
                child: Icon(Icons.info_outline),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onSaved: (value) => widget.controller.updateBio(value?.trim() ?? ''),
          ),
          const SizedBox(height: 28),

          // Back & Complete Registration Buttons
          ValueListenableBuilder<RegisterState>(
            valueListenable: widget.controller,
            builder: (context, state, child) {
              return Row(
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(80, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: state.isLoading ? null : _previousStep,
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
                      onPressed: state.isLoading ? null : _submitForm,
                      child: state.isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Complete Registration',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
