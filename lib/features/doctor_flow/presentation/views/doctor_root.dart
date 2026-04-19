import 'package:flutter/material.dart';
import 'package:doctor_appointment/features/doctor_flow/presentation/views/doctor_dashboard_view.dart';
import 'package:doctor_appointment/features/doctor_flow/presentation/views/doctor_schedule_view.dart';
import 'package:doctor_appointment/features/doctor_flow/presentation/views/doctor_patients_view.dart';
import 'package:doctor_appointment/features/doctor_flow/presentation/views/doctor_profile_view.dart';

class DoctorRoot extends StatefulWidget {
  const DoctorRoot({super.key});

  @override
  State<DoctorRoot> createState() => _DoctorRootState();
}

class _DoctorRootState extends State<DoctorRoot> {
  int _currentIndex = 0;
  
  static const List<Widget> _widgetOptions = [
    DoctorDashboardView(),
    DoctorScheduleView(),
    DoctorPatientsView(),
    DoctorProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _widgetOptions),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_rounded),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_rounded),
            label: 'Patients',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            label: 'Profile',
          ),
        ],
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xff226CEB),
        // ignore: deprecated_member_use
        unselectedItemColor: const Color(0xff226CEB).withValues(alpha: 0.2),
        onTap: _changeItem,
        unselectedIconTheme: const IconThemeData(color: Color(0x33226CEB)),
      ),
    );
  }

  void _changeItem(int value) {
    setState(() {
      _currentIndex = value;
    });
  }
}
