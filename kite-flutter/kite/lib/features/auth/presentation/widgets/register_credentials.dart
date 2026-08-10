import 'package:flutter/material.dart';
import 'package:kite/features/auth/presentation/controllers/register_controller.dart';

class RegisterCredentials extends StatefulWidget {
  final RegisterController controller;

  const RegisterCredentials({
    super.key,
    required this.controller,
  });

  @override
  State<RegisterCredentials> createState() => _RegisterCredentialsState();
}

class _RegisterCredentialsState extends State<RegisterCredentials> {
  final _formKey = GlobalKey<FormState>();
  String _tempPassword = '';
  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      FocusScope.of(context).unfocus();
      widget.controller.nextStep();
    }
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
            'Enter your account credentials:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 18),

          // Email Label & Input
          const Text(
            'Email Address',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          TextFormField(
            initialValue: request.email,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              hintText: 'example@kite.com',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Email is required!';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
            onSaved: (value) => widget.controller.updateEmail(value?.trim() ?? ''),
          ),
          const SizedBox(height: 16),

          // Password Label & Input
          const Text(
            'Password',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          TextFormField(
            initialValue: request.password,
            obscureText: _isPasswordObscured,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              hintText: 'Enter your password',
              prefixIcon: const Icon(Icons.lock_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordObscured
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordObscured = !_isPasswordObscured;
                  });
                },
              ),
            ),
            onChanged: (value) => _tempPassword = value,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password is required!';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters!';
              }
              return null;
            },
            onSaved: (value) => widget.controller.updatePassword(value ?? ''),
          ),
          const SizedBox(height: 16),

          // Confirm Password Label & Input
          const Text(
            'Confirm Password',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          TextFormField(
            initialValue: request.password,
            obscureText: _isConfirmPasswordObscured,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submitForm(),
            decoration: InputDecoration(
              hintText: 'Re-enter your password',
              prefixIcon: const Icon(Icons.lock_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _isConfirmPasswordObscured
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: () {
                  setState(() {
                    _isConfirmPasswordObscured = !_isConfirmPasswordObscured;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password!';
              }
              if (_tempPassword.isNotEmpty && value != _tempPassword) {
                return 'Passwords do not match!';
              }
              return null;
            },
          ),
          const SizedBox(height: 28),

          // Continue Button
          ElevatedButton(
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
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
