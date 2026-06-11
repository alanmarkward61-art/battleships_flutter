import 'coordinate.dart';

enum ShipType { carrier, battleship, cruiser, submarine, destroyer }

class Ship {
  final ShipType type;
  final int length;
  List<Coordinate> coordinates = [];
  int hits = 0;

  bool get isSunk => hits >= length;

  Ship(this.type, this.length);
}
