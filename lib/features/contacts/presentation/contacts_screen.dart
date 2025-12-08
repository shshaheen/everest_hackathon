import 'package:everest_hackathon/domain/entities/contact.dart';
import 'package:everest_hackathon/shared/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/color_scheme.dart';
import '../../../core/dependency_injection/di_container.dart';

import '../bloc/contacts_bloc.dart';
import '../widgets/add_contact_bottom_sheet.dart';
import '../widgets/contact_card.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final TextEditingController _searchController = TextEditingController();
  late ContactsBloc _contactsBloc;
  bool _hasContacts = false;

  @override
  void initState() {
    super.initState();
    print('[ContactsScreen] Initializing ContactsScreen');
    _contactsBloc = sl<ContactsBloc>();
    print('[ContactsScreen] ContactsBloc created, adding LoadContactsEvent');
    _contactsBloc.add(const LoadContactsEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _contactsBloc.close();
    super.dispose();
  }

  void _showSnackbar(String message, {bool isSuccess = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isSuccess ? Colors.green : Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _contactsBloc,
      child: _buildContactsContent(),
    );
  }

  Widget _buildContactsContent() {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Show search bar only when there is at least one contact
            BlocBuilder<ContactsBloc, ContactsState>(
              bloc: _contactsBloc,
              builder: (context, state) {
                // maintain _hasContacts flag based on states
                if (state is ContactsLoaded) {
                  if (_searchController.text.isEmpty &&
                      state.contacts.isNotEmpty) {
                    _hasContacts = true;
                  } else if (_searchController.text.isEmpty &&
                      state.contacts.isEmpty) {
                    _hasContacts = false;
                  }
                } else if (state is ContactsSuccess) {
                  if (_searchController.text.isEmpty &&
                      state.contacts.isNotEmpty) {
                    _hasContacts = true;
                  } else if (_searchController.text.isEmpty &&
                      state.contacts.isEmpty) {
                    _hasContacts = false;
                  }
                } else if (state is ContactsWarning) {
                  if (_searchController.text.isEmpty &&
                      state.contacts.isNotEmpty) {
                    _hasContacts = true;
                  } else if (_searchController.text.isEmpty &&
                      state.contacts.isEmpty) {
                    _hasContacts = false;
                  }
                  // Reset flag if all contacts are deleted (list is empty and not searching)
                  else if (_searchController.text.isEmpty &&
                      state.contacts.isEmpty) {
                    _hasContacts = false;
                  }
                } else if (state is ContactsSuccess) {
                  // Handle success state similarly
                  if (_searchController.text.isEmpty &&
                      state.contacts.isNotEmpty) {
                    _hasContacts = true;
                  } else if (_searchController.text.isEmpty &&
                      state.contacts.isEmpty) {
                    _hasContacts = false;
                  }
                } else if (state is ContactsWarning) {
                  // Handle warning state similarly
                  if (_searchController.text.isEmpty &&
                      state.contacts.isNotEmpty) {
                    _hasContacts = true;
                  } else if (_searchController.text.isEmpty &&
                      state.contacts.isEmpty) {
                    _hasContacts = false;
                  }
                }

                return _hasContacts
                    ? Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 20.0,
                        ),
                        child: Builder(
                          builder: (context) {
                            final theme = Theme.of(context);
                            final colorScheme = theme.colorScheme;
                            final isDark =
                                theme.brightness == Brightness.dark;

                            return TextField(
                              controller: _searchController,
                              onChanged: (query) => _contactsBloc
                                  .add(SearchContactsEvent(query)),
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontSize: 14.sp,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search contacts...',
                                hintStyle: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 14.sp,
                                ),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: colorScheme.onSurfaceVariant,
                                  size: 20.sp,
                                ),

                                filled: true,
                                fillColor: isDark
                                    ? colorScheme.surface
                                        .withOpacity(0.06) // subtle card
                                    : colorScheme.surface, // light surface

                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 12.h,
                                ),

                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide: BorderSide(
                                    color: isDark
                                        ? colorScheme.onSurface
                                            .withOpacity(0.06)
                                        : Colors.grey.shade200,
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide: BorderSide(
                                    color: isDark
                                        ? colorScheme.secondary
                                        : colorScheme.primary,
                                    width: 1.2,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : const SizedBox.shrink();
              },
            ),

            SizedBox(height: 20.h),

            // Contacts List
            Expanded(child: _buildContactsList()),

            Padding(
              padding: EdgeInsets.all(20.w),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _showAddContactBottomSheet,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Emergency Contact'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColorScheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactsList() {
    return BlocListener<ContactsBloc, ContactsState>(
      bloc: _contactsBloc,
      listener: (context, state) {
        if (state is ContactsWarning) {
          _showSnackbar(state.message, isSuccess: false);
        } else if (state is ContactsSuccess) {
          _showSnackbar(state.message, isSuccess: true);
        }
      },
      child: BlocBuilder<ContactsBloc, ContactsState>(
        bloc: _contactsBloc,
        builder: (context, state) {
          print(
            '[ContactsScreen] Building contacts list with state: ${state.runtimeType}',
          );
          final theme = Theme.of(context);
          final cs = theme.colorScheme;

          if (state is ContactsInitial || state is ContactsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ContactsLoaded ||
              state is ContactsSuccess ||
              state is ContactsWarning) {
            final contacts = state is ContactsLoaded
                ? state.contacts
                : state is ContactsSuccess
                    ? state.contacts
                    : (state as ContactsWarning).contacts;

            if (contacts.isEmpty) {
              final searching = _searchController.text.isNotEmpty;
              return _buildEmptyState(searching: searching);
            }

            return ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];
                return ContactCard(
                  contact: contact,
                  onCall: () => _callContact(contact),
                  onMessage: () => _messageContact(contact),
                  onEdit: () => _editContact(contact),
                  onDelete: () => _deleteContact(contact),
                );
              },
            );
          } else if (state is ContactsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64.sp, color: cs.error),
                  SizedBox(height: 16.h),
                  Text(
                    'Error loading contacts',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    state.message,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: cs.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24.h),
                  ElevatedButton(
                    onPressed: () {
                      _contactsBloc.add(const LoadContactsEvent());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyState({bool searching = false}) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 120.h),
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: AppColorScheme.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.contacts_outlined,
              size: 48.sp,
              color: AppColorScheme.primaryColor,
            ),
          ),
          SizedBox(height: 35.h),
          Text(
            searching
                ? 'No emergency contact with this name'
                : 'No Emergency Contacts',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
          SizedBox(height: 8.h),
          if (!searching)
            Text(
              'Add trusted contacts who will receive\nSOS alerts in emergency situations',
              style: TextStyle(
                fontSize: 14.sp,
                color: cs.onSurfaceVariant,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  void _showAddContactBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddContactBottomSheet(
        onContactAdded: (contact) {
          _contactsBloc.add(AddContactEvent(contact));
        },
      ),
    );
  }

  void _editContact(Contact contact) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddContactBottomSheet(
        contact: contact,
        onContactAdded: (updatedContact) {
          _contactsBloc.add(UpdateContactEvent(updatedContact));
        },
      ),
    );
  }

  void _deleteContact(Contact contact) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: cs.surface,
        elevation: 12,
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
        contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        title: Text(
          'Delete Contact',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: cs.onSurface,
          ),
        ),
        content: Text(
          'Are you sure you want to delete ${contact.name}?',
          style: TextStyle(
            fontSize: 16,
            color: cs.onSurfaceVariant,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Row(
            children: [
              SizedBox(
                width: 120.w,
                height: 50.h,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: cs.onSurface.withOpacity(0.12),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    foregroundColor: cs.onSurface,
                    textStyle: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 120.w,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: () {
                    _contactsBloc.add(DeleteContactEvent(contact.id));
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: Colors.redAccent.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  child: const Text('Delete'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _callContact(Contact contact) async {
    final uri = Uri(scheme: 'tel', path: contact.phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not call ${contact.name}')),
        );
      }
    }
  }

  Future<void> _messageContact(Contact contact) async {
    final uri = Uri(scheme: 'sms', path: contact.phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not message ${contact.name}')),
        );
      }
    }
  }
}