import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../home/home_screen.dart';
import '../create_event/create_event_screen.dart';
import '../profile/profile_screen.dart';
import '../map/map_screen.dart';
import '../favorites/favorites_screen.dart';

class MainLayoutController extends GetxController {
  final RxInt currentIndex = 0.obs;

  List<Widget> get screens {
    return [
      const HomeScreen(),
      const MapScreen(),
      const CreateEventScreen(),
      const FavoritesScreen(),
      const ProfileScreen(),
    ];
  }

  void changeTabIndex(int index) {
    currentIndex.value = index;
  }
}
