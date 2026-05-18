import 'package:flutter/material.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:doctor_appointment/features/doctor_flow/presentation/views/doctor_dashboard_view.dart';
import 'package:doctor_appointment/features/doctor_flow/presentation/views/doctor_schedule_view.dart';
import 'package:doctor_appointment/features/doctor_flow/presentation/views/doctor_patients_view.dart';
import 'package:doctor_appointment/features/doctor_flow/presentation/views/doctor_profile_view.dart';
import 'package:doctor_appointment/features/chat/ui/screens/conversations_screen.dart';

class DoctorRoot extends StatefulWidget {
  const DoctorRoot({super.key});

  @override
  State<DoctorRoot> createState() => _DoctorRootState();
}

class _DoctorRootState extends State<DoctorRoot> {
  int _currentIndex = 0;
  late final PageController _pageController;
  
  static const List<Widget> _widgetOptions = [
    DoctorDashboardView(),
    DoctorScheduleView(),
    ConversationsScreen(),
    DoctorPatientsView(),
    DoctorProfileView(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
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
        color: Theme.of(context).cardColor,
        buttonBackgroundColor: const Color(0xff226CEB),
        animationDuration: const Duration(milliseconds: 300),
        items: [
          CurvedNavigationBarItem(
            child: Icon(Icons.dashboard_rounded, color: _currentIndex == 0 ? Colors.white : const Color(0xff226CEB)),
            label: 'Dashboard',
            labelStyle: TextStyle(color: _currentIndex == 0 ? const Color(0xff226CEB) : const Color(0x80226CEB)),
          ),
          CurvedNavigationBarItem(
            child: Icon(Icons.calendar_month_rounded, color: _currentIndex == 1 ? Colors.white : const Color(0xff226CEB)),
            label: 'Schedule',
            labelStyle: TextStyle(color: _currentIndex == 1 ? const Color(0xff226CEB) : const Color(0x80226CEB)),
          ),
          CurvedNavigationBarItem(
            child: Icon(Icons.chat_bubble_rounded, color: _currentIndex == 2 ? Colors.white : const Color(0xff226CEB)),
            label: 'Chat',
            labelStyle: TextStyle(color: _currentIndex == 2 ? const Color(0xff226CEB) : const Color(0x80226CEB)),
          ),
          CurvedNavigationBarItem(
            child: Icon(Icons.people_alt_rounded, color: _currentIndex == 3 ? Colors.white : const Color(0xff226CEB)),
            label: 'Patients',
            labelStyle: TextStyle(color: _currentIndex == 3 ? const Color(0xff226CEB) : const Color(0x80226CEB)),
          ),
          CurvedNavigationBarItem(
            child: Icon(Icons.person_outline_rounded, color: _currentIndex == 4 ? Colors.white : const Color(0xff226CEB)),
            label: 'Profile',
            labelStyle: TextStyle(color: _currentIndex == 4 ? const Color(0xff226CEB) : const Color(0x80226CEB)),
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
    _pageController.animateToPage(
      value,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}
