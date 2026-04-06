import 'package:flutter/material.dart';
import '../models/game_settings.dart';
import 'game_setup_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 28),
            const Icon(Icons.explore, size: 56, color: Color(0xFF00B4D8)),
            const SizedBox(height: 10),
            const Text(
              'CITY COMPASS',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 4,
              ),
            ),
            const Text(
              'Укажи направление города',
              style: TextStyle(color: Color(0xFF607D8B), fontSize: 14),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Выбери регион',
                style: TextStyle(
                  color: Color(0xFF90A4AE),
                  fontSize: 13,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.fromLTRB(
                  16,
                  0,
                  16,
                  MediaQuery.of(context).padding.bottom + 16,
                ),
                itemCount: GameRegion.values.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _RegionTile(region: GameRegion.values[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RegionTile extends StatelessWidget {
  final GameRegion region;

  const _RegionTile({required this.region});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GameSetupScreen(
              settings: GameSettings(region: region),
            ),
          ),
        );
      },
      child: Container(
        height: 68,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E2D3D), Color(0xFF0D1B2A)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2E3F54), width: 1),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Text(region.emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Text(
              region.label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Color(0xFF2E3F54), size: 24),
          ],
        ),
      ),
    );
  }
}
