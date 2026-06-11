import 'package:flutter/material.dart';
import '../models/board.dart';
import '../models/cell.dart';
import '../models/coordinate.dart';

class GridWidget extends StatelessWidget {
  final Board board;
  final bool isPlayerBoard;
  final Function(Coordinate)? onCellTap;

  const GridWidget({
    Key? key,
    required this.board,
    required this.isPlayerBoard,
    this.onCellTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.greenAccent, width: 2),
          color: const Color(0xFF001100), // Very dark green background
        ),
        child: Column(
          children: List.generate(board.size, (r) {
            return Expanded(
              child: Row(
                children: List.generate(board.size, (c) {
                  return Expanded(
                    child: GestureDetector(
                      onTap: onCellTap != null ? () => onCellTap!(Coordinate(r, c)) : null,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.greenAccent.withOpacity(0.3), width: 1),
                          color: _getCellColor(board.grid[r][c]),
                        ),
                        child: Center(
                          child: _getCellChild(board.grid[r][c]),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        ),
      ),
    );
  }

  Color _getCellColor(Cell cell) {
    if (cell.isTargeted) return Colors.yellowAccent.withOpacity(0.8);
    if (isPlayerBoard && cell.state == CellState.ship) {
      return Colors.green.withOpacity(0.5);
    }
    return Colors.transparent;
  }

  Widget? _getCellChild(Cell cell) {
    if (cell.isTargeted) {
      return const Icon(Icons.my_location, color: Colors.black, size: 16);
    }
    if (cell.state == CellState.hit) {
      return const Icon(Icons.close, color: Colors.red, size: 16);
    } else if (cell.state == CellState.miss) {
      return Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Colors.white54,
          shape: BoxShape.circle,
        ),
      );
    }
    return null;
  }
}
