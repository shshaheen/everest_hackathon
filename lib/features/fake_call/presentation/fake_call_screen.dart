import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/dependency_injection/di_container.dart';
import '../../../core/theme/color_scheme.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../bloc/fake_call_bloc.dart';
import '../bloc/fake_call_event.dart';
import '../bloc/fake_call_state.dart';
import 'caller_details_screen.dart';
import 'incoming_call_screen.dart';


/// Fake Call screen - Main screen
class FakeCallScreen extends StatelessWidget {
  const FakeCallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<FakeCallBloc>()..add(const FakeCallEvent.initialize()),
      child: const _FakeCallScreenContent(),
    );
  }
}

class _FakeCallScreenContent extends StatelessWidget {
  const _FakeCallScreenContent();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FakeCallBloc, FakeCallState>(
      listener: (context, state) {
        state.maybeWhen(
          incomingCall: (name, number, image) {
            // Navigate to incoming call screen
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<FakeCallBloc>(),
                  child: const IncomingCallScreen(),
                ),
                fullscreenDialog: true,
              ),
            );
          },
          callEnded: () {
            // Navigate back to main screen
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
            // Reset the bloc
            context.read<FakeCallBloc>().add(const FakeCallEvent.reset());
          },
          error: (message) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: Colors.red,
              ),
            );
          },
          orElse: () {},
        );
      },
      builder: (context, state) {
        return Scaffold(
          appBar: const CustomAppBar(),
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    'Fake Call',
                    style: TextStyle(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black.withAlpha(180),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Place a fake phone call and pretend you are talking to someone.',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 32.h),

                  // Caller Details Card
                  _buildCallerDetailsCard(context, state),

                  const Spacer(),

                  // Get a call button
                  _buildGetCallButton(context, state),
                  
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCallerDetailsCard(BuildContext context, FakeCallState state) {
    // Get saved details
    String? savedName;
    String? savedNumber;
    
    state.maybeWhen(
      detailsSaved: (name, number, image, timer) {
        savedName = name;
        savedNumber = number;
      },
      waiting: (name, number, image, remaining) {
        savedName = name;
        savedNumber = number;
      },
      orElse: () {},
    );

    final hasDetails = savedName != null && savedName!.isNotEmpty;

    return GestureDetector(
      onTap: () async {
        // Navigate to caller details screen
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<FakeCallBloc>(),
              child: const CallerDetailsScreen(),
            ),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasDetails ? savedName! : 'Caller Details',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    hasDetails ? savedNumber ?? '' : 'Set caller details',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.edit,
              color: AppColorScheme.primaryColor,
              size: 24.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGetCallButton(BuildContext context, FakeCallState state) {
    final canStartCall = state.maybeWhen(
      detailsSaved: (name, number, image, timer) => true,
      orElse: () => false,
    );

    final isWaiting = state.maybeWhen(
      waiting: (name, number, image, remaining) => true,
      orElse: () => false,
    );

    return Center(
      child: Container(
        width: 200.w,
        height: 52.h,
        decoration: BoxDecoration(
          color: AppColorScheme.primaryColor,
          borderRadius: BorderRadius.circular(28.r),
          boxShadow: canStartCall
              ? [
                  BoxShadow(
                    color: AppColorScheme.primaryColor.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: canStartCall && !isWaiting
                ? () {
                    context.read<FakeCallBloc>().add(
                          const FakeCallEvent.startFakeCall(),
                        );
                  }
                : null,
            borderRadius: BorderRadius.circular(28.r),
            child: Center(
              child: isWaiting
                  ? state.maybeWhen(
                      waiting: (name, number, image, remaining) => Text(
                        'Calling in ${remaining}s...',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      orElse: () => const SizedBox(),
                    )
                  : Text(
                      'Get a call',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
