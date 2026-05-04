import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/company/company_page.dart';
import '../features/dashboard/dashboard_page.dart';
import '../features/education/education_page.dart';
import '../features/finance/finance_page.dart';
import '../features/housing/housing_page.dart';
import '../features/jobs/jobs_page.dart';
import '../features/menu/menu_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  static const _pages = [
    DashboardPage(),
    JobsPage(),
    EducationPage(),
    HousingPage(),
    FinancePage(),
    CompanyPage(),
    MenuPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: IndexedStack(index: _index, children: _pages),
          ),
        ),
      ),
      bottomNavigationBar: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: DecoratedBox(
            decoration: const BoxDecoration(
              color: AppTheme.surface,
              border: Border(top: BorderSide(color: AppTheme.border)),
            ),
            child: BottomNavigationBar(
              currentIndex: _index,
              onTap: (value) => setState(() => _index = value),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_rounded),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.work_rounded),
                  label: 'Career',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.school_rounded),
                  label: 'Education',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_rounded),
                  label: 'Housing',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.account_balance_rounded),
                  label: 'Finance',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.business_center_rounded),
                  label: 'Company',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.tune_rounded),
                  label: 'Menu',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
