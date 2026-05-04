import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/company/company_page.dart';
import '../features/dashboard/dashboard_page.dart';
import '../features/education/education_page.dart';
import '../features/finance/finance_page.dart';
import '../features/housing/housing_page.dart';
import '../features/jobs/jobs_page.dart';
import '../features/menu/menu_page.dart';
import '../game/state/game_scope.dart';
import '../shared/widgets/vitals_strip.dart';

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
    final controller = GameScope.of(context);
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 540,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: VitalsStrip(
                      stats: controller.state.player.stats,
                      cash: controller.state.player.cash,
                      month: controller.state.month,
                    ),
                  ),
                  Expanded(
                    child: IndexedStack(index: _index, children: _pages),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          border: Border(top: BorderSide(color: AppTheme.border)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 540,
              child: BottomNavigationBar(
                currentIndex: _index,
                onTap: (value) => setState(() => _index = value),
                elevation: 0,
                backgroundColor: Colors.transparent,
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
          ],
        ),
      ),
    );
  }
}
