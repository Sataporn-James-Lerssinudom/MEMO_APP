import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final int selectedIndex;
  const AppDrawer({super.key, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        // Important: Remove any padding from the ListView
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(
            height: 80.0,
            child: DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.purple,
              ),
              child: Text(
                'My Application',
                style: TextStyle(
                  fontSize: 24.0,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          buildDrawerItem(context, 'Memos', 0, DrawerIndex.page0.route),
          buildDrawerItem(context, 'Files', 1, DrawerIndex.page1.route),
        ],
      ),
    );
  }

  ListTile buildDrawerItem(BuildContext context, String title, int index, String route) {
    return ListTile(
      title: Text(title),
      selected: selectedIndex == index,
      onTap: () {
        Navigator.pop(context); // Close the drawer
        if (selectedIndex != index) {
          Navigator.pushNamed(context, route);
        }
      },
    );
  }
}

enum DrawerIndex {
  page0('/pageMemo'),
  page1('/pageFile');

  const DrawerIndex(this.route);
  final String route;
}