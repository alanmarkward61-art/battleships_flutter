import 'dart:math';
import 'coordinate.dart';
import 'cell.dart';
import 'ship.dart';

class Board {
  final int size;
  late List<List<Cell>> grid;
  List<Ship> ships = [];

  Board(this.size) {
    grid = List.generate(size, (r) => List.generate(size, (c) => Cell(Coordinate(r, c))));
  }

  bool get allShipsSunk => ships.isNotEmpty && ships.every((s) => s.isSunk);

  int get sunkShipsCount => ships.where((s) => s.isSunk).length;

  bool canPlaceShip(List<Coordinate> coords) {
    for (var c in coords) {
      if (c.row < 0 || c.row >= size || c.col < 0 || c.col >= size) return false;
      if (grid[c.row][c.col].state == CellState.ship) return false;
      
      // Prevent orthogonal adjacency with previously placed ships
      if (c.row > 0 && grid[c.row - 1][c.col].state == CellState.ship) return false;
      if (c.row < size - 1 && grid[c.row + 1][c.col].state == CellState.ship) return false;
      if (c.col > 0 && grid[c.row][c.col - 1].state == CellState.ship) return false;
      if (c.col < size - 1 && grid[c.row][c.col + 1].state == CellState.ship) return false;
    }
    return true;
  }

  void placeShip(Ship ship, List<Coordinate> coords) {
    ship.coordinates = coords;
    ships.add(ship);
    for (var c in coords) {
      grid[c.row][c.col].state = CellState.ship;
      grid[c.row][c.col].ship = ship;
    }
  }

  void placeShipsRandomly(List<Ship> shipsToPlace) {
    final random = Random();
    for (var ship in shipsToPlace) {
      bool placed = false;
      while (!placed) {
        int r = random.nextInt(size);
        int c = random.nextInt(size);
        bool horizontal = random.nextBool();

        List<Coordinate> coords = [];
        for (int i = 0; i < ship.length; i++) {
          coords.add(Coordinate(horizontal ? r : r + i, horizontal ? c + i : c));
        }

        if (canPlaceShip(coords)) {
          placeShip(ship, coords);
          placed = true;
        }
      }
    }
  }
}
