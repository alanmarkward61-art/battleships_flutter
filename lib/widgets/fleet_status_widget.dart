import 'package:flutter/material.dart';
import '../models/board.dart';
import '../models/ship.dart';

class FleetStatusWidget extends StatelessWidget {
  final Board board;

  const FleetStatusWidget({Key? key, required this.board}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (board.ships.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: const Color(0xFF001100),
        border: Border.all(color: Colors.greenAccent.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 10,
        alignment: WrapAlignment.center,
        children: board.ships.map((ship) {
          return _buildShipIndicator(ship);
        }).toList(),
      ),
    );
  }

  Widget _buildShipIndicator(Ship ship) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          ship.type.name.toUpperCase(),
          style: TextStyle(
            color: ship.isSunk ? Colors.redAccent : Colors.greenAccent,
            fontSize: 10,
            fontFamily: 'Courier',
            fontWeight: FontWeight.bold,
            decoration: ship.isSunk ? TextDecoration.lineThrough : null,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(ship.length, (index) {
            bool hit = index < ship.hits;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: hit ? Colors.red : Colors.green.withOpacity(0.3),
                border: Border.all(color: hit ? Colors.redAccent : Colors.greenAccent),
              ),
              child: hit ? const Icon(Icons.close, size: 10, color: Colors.white) : null,
            );
          }),
        ),
      ],
    );
  }
}
