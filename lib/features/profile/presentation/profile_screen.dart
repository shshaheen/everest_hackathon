import 'package:everest_hackathon/core/theme/color_scheme.dart';
import 'package:everest_hackathon/routes/app_routes.dart';
import 'package:everest_hackathon/core/dependency_injection/di_container.dart';
import 'package:everest_hackathon/core/services/app_preferences_service.dart';
import 'package:everest_hackathon/core/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:everest_hackathon/features/auth/bloc/auth_bloc.dart';
import 'package:everest_hackathon/features/auth/bloc/auth_event.dart';
import 'package:everest_hackathon/features/auth/bloc/auth_state.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children:[ SingleChildScrollView(
          child: Column(
            children: [
              // Load phone number from preferences; fall back to the hardcoded number
              FutureBuilder<String?>(
                future: DIContainer.instance
                    .get<AppPreferencesService>()
                    .getUserPhoneNumber(),
                builder: (context, snapshot) {
                  final phone = snapshot.connectionState == ConnectionState.done
                      ? (snapshot.data ?? '+919392235952')
                      : '+919392235952';
                // Format phone like +91 9392235952 -> +91 93922 35952 or keep your original formatting:
                final displayPhone = phone.length > 3
                    ? "${phone.substring(0, 3)} ${phone.substring(3)}"
                    : phone;
                  return ProfileHeader(
                    phoneNumber: displayPhone,
                  );
                        },
              ),
              const SizedBox(height: 20),
              const ProfileActionButtons(),
              const SizedBox(height: 20),
              const SettingsCard(),
              const SizedBox(height: 250),
              const AppVersionFooter(),
              const SizedBox(height: 20),
            ],
          ),
        ),

        //floating action button for back

        Positioned(
        top: 40,      // adjust if needed for safe area
        left: 16,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 40,
            height: 40,
            child: const Icon(Icons.arrow_back, size: 22, color: Colors.black),
          ),
        ),
      ),
        ]
      ),
    );
  }
}

// ---------- IMPROVED WIDGETS (dark mode tuned) ----------

// Reusable Header Widget
class ProfileHeader extends StatelessWidget {
  final String phoneNumber;

  const ProfileHeader({super.key, required this.phoneNumber});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cs = theme.colorScheme;

    // subtle gradient: darker at top in dark mode; softer in light mode
    final gradientColors = isDark
        ? [
            cs.surface.withOpacity(0.98),
            cs.surfaceVariant.withOpacity(0.9),
          ]
        : [
            cs.primary.withOpacity(0.12),
            cs.surface,
          ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradientColors,
        ),
        // subtle bottom shadow to separate header from body
        boxShadow: [
          BoxShadow(
            color: (cs.shadow ?? Colors.black).withOpacity(isDark ? 0.12 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // make avatar pop in dark mode using a slightly lighter container
          CircleAvatar(
            radius: 40,
            backgroundColor: isDark ? cs.surfaceVariant : Colors.white,
            child: Icon(
              Icons.person,
              size: 50,
              color: isDark ? cs.onSurface : Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Your Account',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            phoneNumber,
            style: TextStyle(fontSize: 16, color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

// Reusable Action Buttons Widget
class ProfileActionButtons extends StatelessWidget {
  const ProfileActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ActionButton(
            icon: Icons.edit,
            label: 'Edit Profile',
            color: Colors.pink,
            onTap: () {
              context.push(
                AppRoutes.profileSetup,
                extra: {'isEditMode': true, 'useProfileBloc': true},
              );
            },
          ),
          ActionButton(
            icon: Icons.contacts,
            label: 'Contacts',
            color: Colors.purple,
            onTap: () {
              context.push(AppRoutes.emergencyContacts);
            },
          ),
          ActionButton(
            icon: Icons.headset_mic,
            label: 'Help',
            color: Colors.deepOrange,
            onTap: () {
              context.push(AppRoutes.helpSupport);
            },
          ),
        ],
      ),
    );
  }
}

// Reusable Action Button Widget
class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 100,
        height: 90,
        decoration: BoxDecoration(
          // use surfaceVariant but slightly more visible in dark mode
          color: cs.surfaceVariant.withOpacity(isDark ? 0.06 : 0.08),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: (cs.shadow ?? Colors.black).withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(2, 3),
              )
            else
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // icon inside a tiny circle to keep contrast consistent across icons
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Settings Card Widget
class SettingsCard extends StatelessWidget {
  const SettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (cs.shadow ?? Colors.black).withOpacity(isDark ? 0.12 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: cs.onSurface.withOpacity(isDark ? 0.06 : 0.02)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SettingItem(
            icon: Icons.logout_outlined,
            title: 'Logout',
            iconColor: const Color(0xFF4B2E83),
            onTap: () => _showLogoutDialog(context),
          ),
          const DottedDivider(),
          SettingItem(
            icon: Icons.delete_forever_outlined,
            title: 'Delete account',
            iconColor: Colors.redAccent,
            onTap: () => _showDeleteAccountDialog(context),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    _showConfirmationDialog(
      context: context,
      title: 'Logout',
      content: 'Are you sure you want to logout?',
      confirmText: 'Logout',
      confirmColor: Colors.red,
      onConfirm: () => _performLogout(context),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    _showConfirmationDialog(
      context: context,
      title: 'Delete account',
      content:
          'Your account will be deleted permanently. Are you sure you want to proceed?',
      confirmText: 'Ok',
      confirmColor: Colors.red,
      onConfirm: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your account will be deleted within 7 working days'),
          ),
        );
      },
    );
  }

  void _showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String content,
    required String confirmText,
    Color? confirmColor,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) => ConfirmationDialog(
        title: title,
        content: content,
        confirmText: confirmText,
        confirmColor: confirmColor,
        onConfirm: onConfirm,
      ),
    );
  }

  void _performLogout(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final appPreferences = DIContainer.instance.get<AppPreferencesService>();
    final authBloc = BlocProvider.of<AuthBloc>(context);

    appPreferences
        .clearAuthData()
        .then((_) {
          Logger.info('User ID and session data cleared from app preferences');
          authBloc.add(const AuthEvent.logout());

          authBloc.stream.listen((state) {
            state.maybeWhen(
              unauthenticated: () {
                Navigator.of(context, rootNavigator: true).pop();
                context.go(AppRoutes.login);
              },
              orElse: () {},
            );
          });
        })
        .catchError((error) {
          Logger.error('Error during logout', error: error);
          Navigator.of(context, rootNavigator: true).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Logout failed. Please try again.')),
          );
        });
  }
}

// Reusable Setting Item Widget
class SettingItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color iconColor;
  final VoidCallback onTap;

  const SettingItem({
    super.key,
    required this.icon,
    required this.title,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            // small colored icon background for consistency
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface, // ensure readability in both modes
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: cs.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

// Reusable Dotted Divider Widget
class DottedDivider extends StatelessWidget {
  const DottedDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lineColor = Theme.of(context).colorScheme.onSurface.withOpacity(isDark ? 0.06 : 0.04);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const dashWidth = 6.0;
          const dashSpace = 6.0;
          final dashCount =
              (constraints.constrainWidth() / (dashWidth + dashSpace)).floor().clamp(1, 100);
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(dashCount, (_) {
              return SizedBox(
                width: dashWidth,
                height: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: lineColor),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

// Reusable Confirmation Dialog Widget
class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmText;
  final Color? confirmColor;
  final VoidCallback onConfirm;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.content,
    required this.confirmText,
    this.confirmColor,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AlertDialog(
      backgroundColor: cs.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(title, style: TextStyle(color: cs.onSurface)),
      content: Text(content, style: TextStyle(color: cs.onSurfaceVariant)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel', style: TextStyle(color: cs.primary)),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          child: Text(confirmText, style: TextStyle(color: confirmColor ?? cs.error)),
        ),
      ],
    );
  }
}

// Reusable App Version Footer Widget
class AppVersionFooter extends StatelessWidget {
  final String version;

  const AppVersionFooter({super.key, this.version = '1.0.0'});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(
        'App version $version',
        style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
      ),
    );
  }
}