import 'package:flutter/material.dart';

class DashboardBottomBar extends StatelessWidget {
  final VoidCallback onDashboard;
  final VoidCallback onLogout;

  const DashboardBottomBar({
    super.key,
    required this.onDashboard,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 10,
      elevation: 15,
      color: Colors.white,
      child: SizedBox(
        height: 68,
        child: Row(
          children: [

            Expanded(
              child: InkWell(
                onTap: onDashboard,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.space_dashboard_rounded,
                      color: Color(0xFF2E7D32),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Dashboard",
                      style: TextStyle(
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 70),

            Expanded(
              child: InkWell(
                onTap: onLogout,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.logout_rounded,
                      color: Colors.red,
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Keluar",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}