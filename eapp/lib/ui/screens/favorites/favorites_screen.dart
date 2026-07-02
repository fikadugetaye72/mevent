import 'package:flutter/material.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('የተወደዱ ዝግጅቶች (Saved Events)'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border_rounded,
              size: 72,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            const Text(
              'ተወዳጅ ዝግጅቶች (Favorites)',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'ያስቀመጧቸው ወይም የወደዷቸው ዝግጅቶች እዚህ ይገኛሉ\n(Your liked or saved events will appear here)',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
