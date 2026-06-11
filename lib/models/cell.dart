import 'coordinate.dart';
import 'ship.dart';

enum CellState { empty, ship, miss, hit }

class Cell {
  final Coordinate coordinate;
  CellState state = CellState.empty;
  Ship? ship;
  bool isTargeted = false;

  Cell(this.coordinate);
}
