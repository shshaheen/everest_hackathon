import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../bloc/fake_call_bloc.dart';
import '../bloc/fake_call_event.dart';
import '../bloc/fake_call_state.dart';

/// In Call Screen - Shows ongoing call UI
class InCallScreen extends StatelessWidget {
  const InCallScreen({super.key});

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          // Prevent back button, user must end call
          context.read<FakeCallBloc>().add(const FakeCallEvent.endCall());
        }
      },
      child: BlocListener<FakeCallBloc, FakeCallState>(
        listener: (context, state) {
          state.maybeWhen(
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
          backgroundColor: Colors.white,
          body: BlocBuilder<FakeCallBloc, FakeCallState>(
            builder: (context, state) {
              // Extract name and number from state
              String callerName = 'Unknown';
              String callerNumber = '';
              int callDuration = 0;
              String? imagePath;
              
              state.maybeWhen(
                inCall: (name, number, image, duration) {
                  callerName = name.isNotEmpty ? name : 'Unknown';
                  callerNumber = number.isNotEmpty ? number : '';
                  callDuration = duration;
                  imagePath = image;
                },
                orElse: () {},
              );
              
              return SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 
                  0.w, vertical: 0.h),
                  child: Column(
                    children: [
                      SizedBox(height: 20.h),

                      // Call duration
                      Text(
                        _formatDuration(callDuration),
                        style: TextStyle(
                          fontSize: 18.sp,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 30.h),

                      // Caller name
                      Text(
                        callerName,
                        style: TextStyle(
                          fontSize: 32.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8.h),

                      // Caller number
                      if (callerNumber.isNotEmpty)
                        Text(
                          'Phone $callerNumber',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      SizedBox(height: 60.h),

                      // Avatar
                      Container(
                        width: 140.w,
                        height: 140.w,
                        decoration: BoxDecoration(
                          color: const Color(0xFF80DEEA),
                          shape: BoxShape.circle,
                        ),
                        child: imagePath != null && imagePath!.isNotEmpty && File(imagePath!).existsSync()
                            ? ClipOval(
                                child: Image.file(
                                  File(imagePath!),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Center(
                                      child: Text(
                                        callerName[0].toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 64.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              )
                            : Center(
                                child: Text(
                                  callerName[0].toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 64.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                      ),

                      const Spacer(),

                      // Call control buttons container
                      Container(

                        // margin: EdgeInsets.symmetric(horizontal: 10.w),
                        padding: EdgeInsets.symmetric(vertical: 35.h, horizontal: 20.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F0F6),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildCallControls(context),
                            SizedBox(height: 30.h),
                            // End call button
                            _buildEndCallButton(context),
                          ],
                        ),
                      ),
                      // SizedBox(height: 30.h),
                      
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

  Widget _buildCallControls(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildControlButton(
          icon: Icons.dialpad,
          label: 'Keypad',
          isActive: false,
          onTap: () {},
        ),
        _buildControlButton(
          icon: Icons.mic,
          label: 'Mute',
          isActive: false,
          onTap: () {},
        ),
        _buildControlButton(
          icon: Icons.volume_up,
          label: 'Speaker',
          isActive: false,
          onTap: () {},
        ),
        _buildControlButton(
          icon: Icons.more_vert,
          label: 'More',
          isActive: false,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            width: 65.w,
            height: 65.w,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF263238) : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.white : Colors.grey[800],
              size: 28.sp,
            ),
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildEndCallButton(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: () {
          context.read<FakeCallBloc>().add(
                const FakeCallEvent.endCall(),
              );
        },
        child: Container(
          width: 160.w,
          height: 56.h,
          decoration: BoxDecoration(
            color: const Color(0xFFD32F2F),
            borderRadius: BorderRadius.circular(32.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD32F2F).withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.call_end,
              color: Colors.white,
              size: 28.sp,
            ),
          ),
        ),
      ),
    );
  }
}
