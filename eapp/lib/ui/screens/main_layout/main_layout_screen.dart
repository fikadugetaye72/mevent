import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'main_layout_controller.dart';
import '../../theme/app_theme.dart';

class MainLayoutScreen extends StatelessWidget {
  const MainLayoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MainLayoutController());

    return Obx(() {
      return Scaffold(
        extendBody: true, // Extends screen content behind the curved bottom bar
        body: IndexedStack(
          index: controller.currentIndex.value,
          children: controller.screens,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => controller.changeTabIndex(2), // Direct index 2 is MyBookings
          shape: const CircleBorder(),
          backgroundColor: controller.currentIndex.value == 2
              ? AppColors.primaryDark
              : AppColors.secondaryBlue,
          elevation: 4,
          child: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 28),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(51),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: BottomAppBar(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            height: 64,
            shape: const AutomaticNotchedShape(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              CircleBorder(),
            ),
            notchMargin: 8.0,
            color: const Color(0xFF1E1E26), // Premium dark slate color
            elevation: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Left Icon 1: Home/Explore
                IconButton(
                  icon: Icon(
                    controller.currentIndex.value == 0
                        ? Icons.explore
                        : Icons.explore_outlined,
                    color: controller.currentIndex.value == 0
                        ? Colors.white
                        : const Color(0xFF8E8E9E),
                    size: 26,
                  ),
                  onPressed: () => controller.changeTabIndex(0),
                ),
                // Left Icon 2: Map/Location
                IconButton(
                  icon: Icon(
                    controller.currentIndex.value == 1
                        ? Icons.location_on
                        : Icons.location_on_outlined,
                    color: controller.currentIndex.value == 1
                        ? Colors.white
                        : const Color(0xFF8E8E9E),
                    size: 26,
                  ),
                  onPressed: () => controller.changeTabIndex(1),
                ),
                const SizedBox(width: 48), // Spacer space for docked FAB
                // Right Icon 1: Favorites
                IconButton(
                  icon: Icon(
                    controller.currentIndex.value == 3
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: controller.currentIndex.value == 3
                        ? Colors.white
                        : const Color(0xFF8E8E9E),
                    size: 26,
                  ),
                  onPressed: () => controller.changeTabIndex(3),
                ),
                // Right Icon 2: Profile
                IconButton(
                  icon: Icon(
                    controller.currentIndex.value == 4
                        ? Icons.person
                        : Icons.person_outline,
                    color: controller.currentIndex.value == 4
                        ? Colors.white
                        : const Color(0xFF8E8E9E),
                    size: 26,
                  ),
                  onPressed: () => controller.changeTabIndex(4),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
