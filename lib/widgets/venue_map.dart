import 'package:flutter/material.dart';

import '../theme.dart';

/// Placeholder seating map built from plain boxes. A real venue would supply
/// its own image or layout from the show server.
class VenueMap extends StatelessWidget {
  const VenueMap({super.key});

  static const _rows = ['A', 'B', 'C', 'D', 'E', 'F'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Playbill.panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Playbill.line),
      ),
      child: Column(
        children: [
          // Stage
          Container(
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Playbill.curtain,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
              border: Border.all(color: Playbill.gold.withOpacity(0.6)),
            ),
            child: const Text('STAGE',
                style: TextStyle(color: Playbill.cream, letterSpacing: 4, fontSize: 12)),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const _Exit(),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  children: [
                    for (final row in _rows)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 16,
                              child: Text(row,
                                  style: const TextStyle(color: Playbill.muted, fontSize: 11)),
                            ),
                            const Expanded(child: _SeatBlock()),
                            const SizedBox(width: 14), // aisle
                            const Expanded(child: _SeatBlock()),
                            SizedBox(
                              width: 16,
                              child: row == 'A'
                                  ? const Icon(Icons.accessible, size: 14, color: Playbill.gold)
                                  : null,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const _Exit(),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: const [
              Expanded(child: _Room(icon: Icons.local_cafe_outlined, label: 'Foyer & bar')),
              SizedBox(width: 8),
              Expanded(child: _Room(icon: Icons.wc_outlined, label: 'Toilets')),
              SizedBox(width: 8),
              Expanded(child: _Room(icon: Icons.door_front_door_outlined, label: 'Entrance')),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Placeholder map',
              style: TextStyle(color: Playbill.muted, fontSize: 11)),
        ],
      ),
    );
  }
}

class _SeatBlock extends StatelessWidget {
  const _SeatBlock();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < 6; i++)
          Expanded(
            child: Container(
              height: 10,
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              decoration: BoxDecoration(
                color: Playbill.line,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
      ],
    );
  }
}

class _Exit extends StatelessWidget {
  const _Exit();

  @override
  Widget build(BuildContext context) {
    return RotatedBox(
      quarterTurns: 3,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        color: const Color(0xFF00A651),
        child: const Text('EXIT',
            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
      ),
    );
  }
}

class _Room extends StatelessWidget {
  const _Room({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Playbill.line),
      ),
      child: Column(
        children: [
          Icon(icon, color: Playbill.gold, size: 20),
          const SizedBox(height: 4),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: Playbill.muted)),
        ],
      ),
    );
  }
}
