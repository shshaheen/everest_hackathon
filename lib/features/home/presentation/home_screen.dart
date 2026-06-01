import 'package:everest_hackathon/features/contacts/presentation/contacts_screen.dart';
import 'package:everest_hackathon/features/track/presentation/track_screen.dart';
import 'package:everest_hackathon/routes/app_routes.dart';
import 'package:everest_hackathon/features/helpline/helpline_screen.dart';
import 'package:everest_hackathon/features/fake_call/presentation/fake_call_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/color_scheme.dart';
import '../../../core/dependency_injection/di_container.dart' as di;
import '../../../data/datasources/remote/sos_remote_source.dart';
import '../../../core/services/app_preferences_service.dart';

/// Home screen with SOS button and main features
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// Bottom navigation item model
class _NavItem {
  final IconData icon;
  final String label;

  _NavItem({required this.icon, required this.label});
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Navigation items (without SOS which will be in the middle)
  final List<_NavItem> _navItems = [
    _NavItem(icon: Icons.my_location, label: 'Track Me'),
    _NavItem(icon: Icons.contacts, label: 'Contacts'),
    _NavItem(icon: Icons.call, label: 'FakeCall'),
    _NavItem(icon: Icons.headset_mic, label: 'Helpline'),
  ];

  // Create persistent screen instances to avoid recreation
  late final Widget _trackScreen;
  late final Widget _contactsScreen;
  late final Widget _sosScreen;
  late final Widget _fakeCallScreen;
  late final Widget _helplineScreen;

  @override
  void initState() {
    super.initState();
    // Initialize screens once to prevent recreation
    _trackScreen = const TrackScreen();
    _contactsScreen = const ContactsScreen();
    _sosScreen = const Center(child: Text('SOS Content'));
    _fakeCallScreen = const FakeCallScreen();
    _helplineScreen = const HelplineScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _trackScreen,
          _contactsScreen,
          _sosScreen,
          _fakeCallScreen,
          _helplineScreen,
        ],
      ),
      bottomNavigationBar: _buildCustomBottomNavBar(),
    );
  }

  Widget _buildCustomBottomNavBar() {
    return Container(
      height: 80.h,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // First two items
          _buildNavItem(0, 0),
          _buildNavItem(1, 1),

          // SOS button in the middle
          _buildNavSosButton(),

          // Last two items (index 2 and 3 in navItems, but 3 and 4 in screen stack)
          _buildNavItem(2, 3),
          _buildNavItem(3, 4),
        ],
      ),
    );
  }

  // Build individual nav item
  Widget _buildNavItem(int navIndex, int screenIndex) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  final isSelected = _selectedIndex == screenIndex;
  final gradient = AppColorScheme.getPrimaryGradient(isDark);

  return InkWell(
    onTap: () => setState(() => _selectedIndex = screenIndex),
    child: SizedBox(
      width: 70.w,
      height: 70.h,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon: gradient when selected, grey otherwise
          if (isSelected)
            ShaderMask(
              shaderCallback: (bounds) => gradient.createShader(bounds),
              blendMode: BlendMode.srcIn,
              child: Icon(
                _navItems[navIndex].icon,
                size: 24.sp,
                color: Colors.white, // color is replaced by shader
              ),
            )
          else
            Icon(
              _navItems[navIndex].icon,
              size: 24.sp,
              color: Colors.grey,
            ),

          SizedBox(height: 4.h),

          // Label: gradient when selected, grey otherwise
          if (isSelected)
            ShaderMask(
              shaderCallback: (bounds) => gradient.createShader(bounds),
              blendMode: BlendMode.srcIn,
              child: Text(
                _navItems[navIndex].label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white, // replaced by shader
                ),
              ),
            )
          else
            Text(
              _navItems[navIndex].label,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey,
              ),
            ),
        ],
      ),
    ),
  );
}


  // Build SOS button for the nav bar
  // Handle SOS button tap with emergency contacts check
  Future<void> _handleSosButtonTap() async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    
    try {
      // Get user ID and check for emergency contacts
      final preferencesService = di.sl<AppPreferencesService>();
      final userId = await preferencesService.getUserId();
      
      if (userId == null) {
        Navigator.of(context).pop(); // Close loading dialog
        _showErrorDialog('User not authenticated. Please login again.');
        return;
      }
      
      // Check if user has emergency contacts
      final sosRemoteSource = di.sl<SosRemoteSource>();
      final contactsResponse = await sosRemoteSource.getEmergencyContacts(userId);
      
      Navigator.of(context).pop(); // Close loading dialog
      
      if (!contactsResponse.success || contactsResponse.data.isEmpty) {
        // Show popup to add emergency contacts
        _showEmergencyContactsDialog();
      } else {
        // Navigate to SOS screen if contacts exist
        if (mounted) {
          context.push(AppRoutes.sos);
        }
      }
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      _showErrorDialog('Failed to check emergency contacts. Please try again.');
    }
  }
  
  // Show dialog when no emergency contacts are found
  void _showEmergencyContactsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.contacts,
          color: Colors.orange,
          size: 64.sp,
        ),
        title: const Text('No Emergency Contacts'),
        content: const Text('You need to add emergency contacts before using SOS. Please add at least one contact to continue.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to emergency contacts screen
              context.push(AppRoutes.emergencyContacts);
            },
            child: const Text('Add Emergency Contacts'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
  
  // Show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.error,
          color: Colors.red,
          size: 64.sp,
        ),
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }


  // Build SOS button for the nav bar
  // Handle SOS button tap with emergency contacts check
  // Future<void> _handleSosButtonTap() async {
  //   // Show loading dialog
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (context) => const Center(
  //       child: CircularProgressIndicator(),
  //     ),
  //   );
    
  //   try {
  //     // Get user ID and check for emergency contacts
  //     final preferencesService = di.sl<AppPreferencesService>();
  //     final userId = await preferencesService.getUserId();
      
  //     if (userId == null) {
  //       Navigator.of(context).pop(); // Close loading dialog
  //       _showErrorDialog('User not authenticated. Please login again.');
  //       return;
  //     }
      
  //     // Check if user has emergency contacts
  //     final sosRemoteSource = di.sl<SosRemoteSource>();
  //     final contactsResponse = await sosRemoteSource.getEmergencyContacts(userId);
      
  //     Navigator.of(context).pop(); // Close loading dialog
      
  //     if (!contactsResponse.success || contactsResponse.data.isEmpty) {
  //       // Show popup to add emergency contacts
  //       _showEmergencyContactsDialog();
  //     } else {
  //       // Navigate to SOS screen if contacts exist
  //       if (mounted) {
  //         context.push(AppRoutes.sos);
  //       }
  //     }
  //   } catch (e) {
  //     Navigator.of(context).pop(); // Close loading dialog
  //     _showErrorDialog('Failed to check emergency contacts. Please try again.');
  //   }
  // }
  
  // // Show dialog when no emergency contacts are found
  // void _showEmergencyContactsDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       icon: Icon(
  //         Icons.contacts,
  //         color: Colors.orange,
  //         size: 64.sp,
  //       ),
  //       title: const Text('No Emergency Contacts'),
  //       content: const Text('You need to add emergency contacts before using SOS. Please add at least one contact to continue.'),
  //       actions: [
  //         TextButton(
  //           onPressed: () {
  //             Navigator.of(context).pop();
  //             // Navigate to emergency contacts screen
  //             context.push(AppRoutes.emergencyContacts);
  //           },
  //           child: const Text('Add Emergency Contacts'),
  //         ),
  //         TextButton(
  //           onPressed: () {
  //             Navigator.of(context).pop();
  //           },
  //           child: const Text('Cancel'),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  
  // // Show error dialog
  // void _showErrorDialog(String message) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       icon: Icon(
  //         Icons.error,
  //         color: Colors.red,
  //         size: 64.sp,
  //       ),
  //       title: const Text('Error'),
  //       content: Text(message),
  //       actions: [
  //         TextButton(
  //           onPressed: () {
  //             Navigator.of(context).pop();
  //           },
  //           child: const Text('OK'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Build SOS button for the nav bar
  Widget _buildNavSosButton() {
    return SizedBox(
      width: 70.w,
      height: 70.h,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            width: 75.w,
            height: 75.w,
            margin: EdgeInsets.only(bottom: 3.h),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColorScheme.emergencyGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColorScheme.sosRedColor.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: InkWell(
              onTap: () => _handleSosButtonTap(),
              borderRadius: BorderRadius.circular(30.r),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Icon(Icons.sos, size: 36.sp, color: Colors.white)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}