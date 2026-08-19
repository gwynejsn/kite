import 'package:flutter/material.dart';
import 'package:kite/features/auth/domain/repositories/auth_repository.dart';
import 'package:kite/features/auth/presentation/screens/login_page.dart';
import 'package:kite/features/profile/domain/user_profile.dart';
import 'package:kite/features/profile/presentation/providers/user_profile_provider.dart';
import 'package:kite/shared/di/injection_container.dart';
import 'package:kite/shared/enums/gender.dart';
import 'package:kite/shared/enums/preferred_theme.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _handleLogout(BuildContext context) async {
    await sl<AuthRepository>().logout();
    if (context.mounted) {
      context.read<UserProfileProvider>().clearProfile();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

  void _showEditProfileModal(BuildContext context, UserProfile profile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _EditProfileSheet(profile: profile),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            tooltip: 'Edit Profile',
            onPressed: () {
              final profile = context.read<UserProfileProvider>().userProfile;
              if (profile != null) _showEditProfileModal(context, profile);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: Consumer<UserProfileProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.userProfile == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null && provider.userProfile == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      provider.errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => provider.fetchUserProfile(),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final profile = provider.userProfile;
          if (profile == null) {
            return Center(
              child: ElevatedButton.icon(
                onPressed: () => provider.fetchUserProfile(),
                icon: const Icon(Icons.download_rounded),
                label: const Text('Load Profile'),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const SizedBox(height: 12),
                _ProfileHeader(
                  profile: profile,
                  onEdit: () => _showEditProfileModal(context, profile),
                ),
                const SizedBox(height: 24),
                _AccountInfoCard(
                  profile: profile,
                  onEdit: () => _showEditProfileModal(context, profile),
                ),
                const SizedBox(height: 16),
                _AppPreferencesCard(profile: profile),
                const SizedBox(height: 16),
                _SecurityCard(profile: profile),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.error,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => _handleLogout(context),
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text(
                      'Log Out',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final UserProfile profile;
  final VoidCallback onEdit;

  const _ProfileHeader({required this.profile, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final fullName = '${profile.firstName} ${profile.lastName}'.trim();
    final initials =
        (profile.firstName.isNotEmpty ? profile.firstName[0] : '') +
        (profile.lastName.isNotEmpty ? profile.lastName[0] : '');

    return Column(
      children: [
        GestureDetector(
          onTap: onEdit,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 54,
                backgroundColor:
                    Theme.of(context).colorScheme.primaryContainer,
                backgroundImage: profile.profileImageLink.isNotEmpty
                    ? NetworkImage(profile.profileImageLink)
                    : null,
                child: profile.profileImageLink.isEmpty
                    ? Text(
                        initials.toUpperCase(),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      )
                    : null,
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.surface,
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.edit_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          fullName.isNotEmpty ? fullName : profile.username,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          '@${profile.username}',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _AccountInfoCard extends StatelessWidget {
  final UserProfile profile;
  final VoidCallback onEdit;

  const _AccountInfoCard({required this.profile, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surface.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.primary.withValues(alpha: 0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Personal Information',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('Edit'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _InfoTile(
            icon: Icons.info_outline_rounded,
            label: 'Bio',
            value: profile.bio.isNotEmpty ? profile.bio : 'No bio added yet.',
          ),
          const Divider(height: 24),
          _InfoTile(
            icon: Icons.wc_rounded,
            label: 'Gender',
            value:
                profile.gender.name[0].toUpperCase() +
                profile.gender.name.substring(1),
          ),
        ],
      ),
    );
  }
}

class _AppPreferencesCard extends StatelessWidget {
  final UserProfile profile;

  const _AppPreferencesCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surface.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.primary.withValues(alpha: 0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'App Preferences',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.palette_outlined,
                    size: 22,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    'Theme',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              _ThemeSegmentedToggle(
                currentTheme: profile.preferredTheme,
                profile: profile,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SecurityCard extends StatelessWidget {
  final UserProfile profile;

  const _SecurityCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surface.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.primary.withValues(alpha: 0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Security & Encryption',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.security_rounded,
                size: 22,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'End-to-End Encryption',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'X25519 & AES-256 Active',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.check_circle_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ThemeSegmentedToggle extends StatelessWidget {
  final PreferredTheme currentTheme;
  final UserProfile profile;

  const _ThemeSegmentedToggle({
    required this.currentTheme,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<PreferredTheme>(
      showSelectedIcon: false,
      segments: const [
        ButtonSegment<PreferredTheme>(
          value: PreferredTheme.light,
          label: Text('Light', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          icon: Icon(Icons.light_mode_rounded, size: 14),
        ),
        ButtonSegment<PreferredTheme>(
          value: PreferredTheme.dark,
          label: Text('Dark', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          icon: Icon(Icons.dark_mode_rounded, size: 14),
        ),
      ],
      selected: {currentTheme},
      onSelectionChanged: (Set<PreferredTheme> newSelection) {
        if (newSelection.isNotEmpty) {
          final selectedTheme = newSelection.first;
          if (selectedTheme != currentTheme) {
            context.read<UserProfileProvider>().updateUserProfile(
                  firstName: profile.firstName,
                  lastName: profile.lastName,
                  username: profile.username,
                  profileImageLink: profile.profileImageLink,
                  bio: profile.bio,
                  gender: profile.gender,
                  preferredTheme: selectedTheme,
                );
          }
        }
      },
      style: SegmentedButton.styleFrom(
        selectedBackgroundColor: Theme.of(context).colorScheme.primary,
        selectedForegroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EditProfileSheet extends StatefulWidget {
  final UserProfile profile;

  const _EditProfileSheet({required this.profile});

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _bioController;
  late final TextEditingController _imageLinkController;
  late Gender _gender;
  late PreferredTheme _preferredTheme;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _firstNameController =
        TextEditingController(text: widget.profile.firstName);
    _lastNameController = TextEditingController(text: widget.profile.lastName);
    _usernameController = TextEditingController(text: widget.profile.username);
    _bioController = TextEditingController(text: widget.profile.bio);
    _imageLinkController =
        TextEditingController(text: widget.profile.profileImageLink);
    _gender = widget.profile.gender;
    _preferredTheme = widget.profile.preferredTheme;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _imageLinkController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final success = await context.read<UserProfileProvider>().updateUserProfile(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          username: _usernameController.text.trim(),
          profileImageLink: _imageLinkController.text.trim(),
          bio: _bioController.text.trim(),
          gender: _gender,
          preferredTheme: _preferredTheme,
        );

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: bottomPadding + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Edit Profile',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                        labelText: 'First Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) =>
                          val == null || val.trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                        labelText: 'Last Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) =>
                          val == null || val.trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  prefixText: '@',
                ),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _bioController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _imageLinkController,
                decoration: const InputDecoration(
                  labelText: 'Profile Image URL',
                  border: OutlineInputBorder(),
                  hintText: 'https://...',
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<Gender>(
                      initialValue: _gender,
                      decoration: const InputDecoration(
                        labelText: 'Gender',
                        border: OutlineInputBorder(),
                      ),
                      items: Gender.values
                          .map(
                            (g) => DropdownMenuItem(
                              value: g,
                              child: Text(
                                g.name[0].toUpperCase() + g.name.substring(1),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _gender = val);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<PreferredTheme>(
                      initialValue: _preferredTheme,
                      decoration: const InputDecoration(
                        labelText: 'Theme',
                        border: OutlineInputBorder(),
                      ),
                      items: PreferredTheme.values
                          .map(
                            (t) => DropdownMenuItem(
                              value: t,
                              child: Text(
                                t.name[0].toUpperCase() + t.name.substring(1),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _preferredTheme = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _isSaving ? null : _handleSave,
                  child: _isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
