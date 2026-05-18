import 'package:doctor_appointment/core/theme/app_theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:doctor_appointment/features/calendar/presentation/views/calendar_view.dart';

import 'package:doctor_appointment/features/home/presentation/views/home_view.dart';
import 'package:doctor_appointment/features/profile/presentation/views/profile_view.dart';
import 'package:doctor_appointment/features/chat/ui/screens/conversations_screen.dart';
import 'package:doctor_appointment/features/search/presentation/views/search_view.dart';

class Root extends StatefulWidget {
  const Root({super.key});

  @override
  State<Root> createState() => RootState();
}

class RootState extends State<Root> {
  int _currentIndex = 0;
  late final PageController _pageController;

  static const List<Widget> _widgetOptions = [
    HomeView(),
    ConversationsScreen(),
    SearchView(),
    CalendarView(),
    ProfileView(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void changePage(int index) {
    if (index >= 0 && index < _widgetOptions.length) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _changeItem(int value) {
    setState(() {
      _currentIndex = value;
    });
    _pageController.animateToPage(
      value,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      extendBody: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _widgetOptions,
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        backgroundColor: Colors.transparent,
        color: colorScheme.surface,
        buttonBackgroundColor: colorScheme.primary,
        animationDuration: const Duration(milliseconds: 300),
        items: [
          CurvedNavigationBarItem(
            child: Icon(
              Icons.home_rounded,
              color: _currentIndex == 0
                  ? colorScheme.onPrimary
                  : colorScheme.primary.withValues(alpha: 0.6),
              size: 26.sp,
            ),
            label: 'Home',
            labelStyle: context.styleMedium14.copyWith(
              color: _currentIndex == 0
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
              fontSize: 11.sp,
            ),
          ),
          CurvedNavigationBarItem(
            child: Icon(
              Icons.chat_bubble_rounded,
              color: _currentIndex == 1
                  ? colorScheme.onPrimary
                  : colorScheme.primary.withValues(alpha: 0.6),
              size: 26.sp,
            ),
            label: 'Chat',
            labelStyle: context.styleMedium14.copyWith(
              color: _currentIndex == 1
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
              fontSize: 11.sp,
            ),
          ),
          CurvedNavigationBarItem(
            child: Icon(
              Icons.search_rounded,
              color: _currentIndex == 2
                  ? colorScheme.onPrimary
                  : colorScheme.primary.withValues(alpha: 0.6),
              size: 26.sp,
            ),
            label: 'Search',
            labelStyle: context.styleMedium14.copyWith(
              color: _currentIndex == 2
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
              fontSize: 11.sp,
            ),
          ),
          CurvedNavigationBarItem(
            child: Icon(
              Icons.calendar_month_rounded,
              color: _currentIndex == 3
                  ? colorScheme.onPrimary
                  : colorScheme.primary.withValues(alpha: 0.6),
              size: 26.sp,
            ),
            label: 'Bookings',
            labelStyle: context.styleMedium14.copyWith(
              color: _currentIndex == 3
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
              fontSize: 11.sp,
            ),
          ),
          CurvedNavigationBarItem(
            child: Icon(
              Icons.person_rounded,
              color: _currentIndex == 4
                  ? colorScheme.onPrimary
                  : colorScheme.primary.withValues(alpha: 0.6),
              size: 26.sp,
            ),
            label: 'Profile',
            labelStyle: context.styleMedium14.copyWith(
              color: _currentIndex == 4
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
              fontSize: 11.sp,
            ),
          ),
        ],
        onTap: _changeItem,
      ),
    );
  }
}
