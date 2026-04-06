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
            const SizedBox(height: 14),
            const Icon(Icons.explore, size: 48, color: Color(0xFF00B4D8)),
            const SizedBox(height: 6),
            const Text(
              'CITY COMPASS',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 4,
              ),
            ),
            const Text(
              'Укажи направление города',
              style: TextStyle(color: Color(0xFF607D8B), fontSize: 13),
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Выбери регион',
                style: TextStyle(
                  color: Color(0xFF90A4AE),
                  fontSize: 12,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  0,
                  16,
                  MediaQuery.of(context).padding.bottom + 12,
                ),
                child: Column(
                  children: GameRegion.values
                      .map((r) => Expanded(child: Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _RegionTile(region: r),
                          )))
                      .toList(),
                ),
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
