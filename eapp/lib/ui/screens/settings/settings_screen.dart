import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'settings_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettingsController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('ቅንብሮች (Settings)', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Dark Mode switch
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  children: [
                    Obx(() => SwitchListTile(
                          title: const Text('የጨለማ ገጽታ (Dark Mode)'),
                          secondary: const Icon(Icons.dark_mode_outlined, color: Colors.purple),
                          value: controller.isDarkMode.value,
                          onChanged: controller.toggleTheme,
                        )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Logout card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text('ውጣ (Logout)', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      onTap: () => _confirmLogout(context, controller),
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

  void _confirmLogout(BuildContext context, SettingsController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('ውጣ (Logout)'),
        content: const Text('መተግበሪያውን መልቀቅ ይፈልጋሉ?\n(Are you sure you want to logout?)'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('አይ (Cancel)'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.logout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('ውጣ (Logout)', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
