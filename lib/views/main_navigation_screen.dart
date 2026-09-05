import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/app_flow_provider.dart';
import '../providers/jobs_provider.dart';
import 'tabs/home/home_screen.dart';
import 'tabs/search/search_screen.dart';
import 'tabs/saved/saved_screen.dart';
import 'tabs/notifications/notifications_screen.dart';
import 'tabs/profile/profile_screen.dart';

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  static const List<Widget> _tabs = [
    HomeScreen(),
    SearchScreen(),
    SavedScreen(),
    NotificationsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final flow = Provider.of<AppFlowProvider>(context);
    final jobsProv = Provider.of<JobsProvider>(context);
    final unreadNotifs = jobsProv.unreadNotifications;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: flow.currentTabIndex,
        children: _tabs,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: flow.currentTabIndex,
        onDestinationSelected: (index) => flow.setTabIndex(index),
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        elevation: 0,
        indicatorColor: const Color(0xFF1E3A8A).withOpacity(isDark ? 0.25 : 0.12),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded, color: Color(0xFF1E3A8A)),
            label: l10n.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.search_rounded),
            selectedIcon: const Icon(Icons.search_rounded, color: Color(0xFF1E3A8A)),
            label: l10n.navSearch,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bookmark_outline_rounded),
            selectedIcon: const Icon(Icons.bookmark_rounded, color: Color(0xFF1E3A8A)),
            label: l10n.navSaved,
          ),
          NavigationDestination(
            icon: unreadNotifs > 0
                ? Badge.count(
                    count: unreadNotifs,
                    backgroundColor: const Color(0xFFE11D48),
                    child: const Icon(Icons.notifications_none_rounded),
                  )
                : const Icon(Icons.notifications_none_rounded),
            selectedIcon: unreadNotifs > 0
                ? Badge.count(
                    count: unreadNotifs,
                    backgroundColor: const Color(0xFFE11D48),
                    child: const Icon(Icons.notifications_rounded, color: Color(0xFF1E3A8A)),
                  )
                : const Icon(Icons.notifications_rounded, color: Color(0xFF1E3A8A)),
            label: l10n.navNotifications,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline_rounded),
            selectedIcon: const Icon(Icons.person_rounded, color: Color(0xFF1E3A8A)),
            label: l10n.navProfile,
          ),
        ],
      ),
    );
  }
}
