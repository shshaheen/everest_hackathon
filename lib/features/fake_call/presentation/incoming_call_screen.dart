import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../bloc/fake_call_bloc.dart';
import '../bloc/fake_call_event.dart';
import '../bloc/fake_call_state.dart';
import 'in_call_screen.dart';

/// Incoming Call Screen - Shows fake incoming call
class IncomingCallScreen extends StatelessWidget {
  const IncomingCallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          // Prevent back button, user must use decline or answer
          context.read<FakeCallBloc>().add(const FakeCallEvent.declineCall());
        }
      },
      child: BlocListener<FakeCallBloc, FakeCallState>(
        listener: (context, state) {
          state.maybeWhen(
            inCall: (name, number, image, duration) {
              // Navigate to in-call screen
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<FakeCallBloc>(),
                    child: const InCallScreen(),
                  ),
                ),
              );
            },
            callEnded: () {
              // Navigate back to home
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
            orElse: () {},
          );
        },
        child: Scaffold(
          backgroundColor: Colors.grey[100],
          body: BlocBuilder<FakeCallBloc, FakeCallState>(
            builder: (context, state) {
              // Extract name and number from state
              String callerName = 'Unknown';
              String callerNumber = '';
              
              state.maybeWhen(
                incomingCall: (name, number, image) {
                  callerName = name.isNotEmpty ? name : 'Unknown';
                  callerNumber = number.isNotEmpty ? number : '';
                },
                orElse: () {},
              );
              
              return SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 40.h),
                  child: Column(
                    children: [
                      SizedBox(height: 60.h),

                      // Caller name
                      Text(
                        callerName,
                        style: TextStyle(
                          fontSize: 36.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 12.h),

                      // Caller number
                      Text(
                        callerNumber.isNotEmpty ? 'Phone $callerNumber' : '',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const Spacer(),

                      // Message button
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 28.w,
                          vertical: 14.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.message_outlined,
                              size: 20.sp,
                              color: Colors.grey[700],
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Message',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 60.h),

                      // Call action buttons
                      _buildCallActions(context),
                      SizedBox(height: 50.h),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
  Widget _buildCallActions(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 30.w),
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFE8E8E8),
        borderRadius: BorderRadius.circular(50.r),
      ),
      child: Stack(
        children: [
          // Background hint text
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Decline',
                  style: TextStyle(
                    color: const Color(0xFFD32F2F),
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20.w),
                child: Text(
                  'Answer',
                  style: TextStyle(
                    color: const Color(0xFF4CAF50),
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          // Center swipeable button
          Center(
            child: GestureDetector(
              onHorizontalDragEnd: (details) {
                // Swipe left to decline
                if (details.primaryVelocity! < 0) {
                  context.read<FakeCallBloc>().add(
                        const FakeCallEvent.declineCall(),
                      );
                }
                // Swipe right to answer
                else if (details.primaryVelocity! > 0) {
                  context.read<FakeCallBloc>().add(
                        const FakeCallEvent.answerCall(),
                      );
                }
              },
              onTap: () {
                // Default tap action - answer
                context.read<FakeCallBloc>().add(
                      const FakeCallEvent.answerCall(),
                    );
              },
              child: Container(
                width: 55.w,
                height: 55.w,
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4CAF50).withOpacity(0.1),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.call,
                  color: Colors.white,
                  size: 30.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}
