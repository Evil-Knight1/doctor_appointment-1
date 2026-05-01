import 'package:flutter/material.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:doctor_appointment/features/calendar/presentation/views/calendar_view.dart';

import 'package:doctor_appointment/features/home/presentation/views/home_view.dart';
import 'package:doctor_appointment/features/profile/presentation/views/profile_view.dart';
import 'package:doctor_appointment/features/chatbot/presentation/views/chat_history_view.dart';
import 'package:doctor_appointment/features/search/presentation/views/search_view.dart';

class Root extends StatefulWidget {
  const Root({super.key});

  @override
  State<Root> createState() => _RootState();
}

class _RootState extends State<Root> {
  int _currentIndex = 0;
  static const List<Widget> _widgetOptions = [
    HomeView(),
    ChatHistoryView(),
    SearchView(),
    CalendarView(),
    ProfileView(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: false,
      body: IndexedStack(index: _currentIndex, children: _widgetOptions),
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        backgroundColor: Colors.white,
        color: Theme.of(context).cardColor,
        buttonBackgroundColor: const Color(0xff226CEB),
        animationDuration: const Duration(milliseconds: 300),
        items: [
          CurvedNavigationBarItem(
            child: Icon(
              Icons.home_rounded,
              color: _currentIndex == 0 ? Colors.white : const Color(0xff226CEB),
            ),
            label: 'Home',
            labelStyle: TextStyle(
              color: _currentIndex == 0 ? const Color(0xff226CEB) : const Color(0x80226CEB),
            ),
          ),
          CurvedNavigationBarItem(
            child: Icon(
              Icons.chat_bubble_outline,
              color: _currentIndex == 1 ? Colors.white : const Color(0xff226CEB),
            ),
            label: 'Chat',
            labelStyle: TextStyle(
              color: _currentIndex == 1 ? const Color(0xff226CEB) : const Color(0x80226CEB),
            ),
          ),
          CurvedNavigationBarItem(
            child: Icon(
              Icons.search,
              color: _currentIndex == 2 ? Colors.white : const Color(0xff226CEB),
            ),
            label: 'Search',
            labelStyle: TextStyle(
              color: _currentIndex == 2 ? const Color(0xff226CEB) : const Color(0x80226CEB),
            ),
          ),
          CurvedNavigationBarItem(
            child: Icon(
              Icons.calendar_today_outlined,
              color: _currentIndex == 3 ? Colors.white : const Color(0xff226CEB),
            ),
            label: 'Bookings',
            labelStyle: TextStyle(
              color: _currentIndex == 3 ? const Color(0xff226CEB) : const Color(0x80226CEB),
            ),
          ),
          CurvedNavigationBarItem(
            child: Icon(
              Icons.person_outline,
              color: _currentIndex == 4 ? Colors.white : const Color(0xff226CEB),
            ),
            label: 'Profile',
            labelStyle: TextStyle(
              color: _currentIndex == 4 ? const Color(0xff226CEB) : const Color(0x80226CEB),
            ),
          ),
        ],
        onTap: _changeItem,
      ),
    );
  }

  void _changeItem(int value) {
    setState(() {
      _currentIndex = value;
    });
  }
}
