import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/board.dart';
import '../models/coordinate.dart';
import '../models/ship.dart';
import '../models/cell.dart';
import 'audio_service.dart';

enum GamePhase { setup, playerTurn, computerTurn, gameOver }
enum Difficulty { easy, standard, hard }

class GameState extends ChangeNotifier {
  int gridSize = 10;
  late Board playerBoard;
  late Board computerBoard;
  GamePhase phase = GamePhase.setup;
  bool playerWon = false;
  bool isProcessing = false;
  int activeTab = 0; // 0 for Enemy Waters, 1 for Your Waters
  Difficulty difficulty = Difficulty.standard;

  // AI State
  GameState() {
    _initGame();
  }

  void setGridSize(int size) {
    // Locked to 10x10 for mobile
  }

  void setDifficulty(Difficulty diff) {
    difficulty = diff;
    notifyListeners();
  }

  void setActiveTab(int index) {
    if (activeTab != index && !isProcessing) {
      activeTab = index;
      notifyListeners();
    }
  }

  void _initGame() {
    playerBoard = Board(gridSize);
    computerBoard = Board(gridSize);
    phase = GamePhase.setup;

    computerBoard.placeShipsRandomly(_createFleet());
    playerBoard.placeShipsRandomly(_createFleet());
    
    isProcessing = false;
    phase = GamePhase.playerTurn;
    notifyListeners();
  }

  void resetGame() {
    _initGame();
  }

  List<Ship> _createFleet() {
    return [
      Ship(ShipType.carrier, 5),
      Ship(ShipType.battleship, 4),
      Ship(ShipType.cruiser, 3),
      Ship(ShipType.submarine, 3),
      Ship(ShipType.destroyer, 2),
    ];
  }

  Future<void> fireAtComputer(Coordinate coord) async {
    if (phase != GamePhase.playerTurn || isProcessing) return;

    Cell cell = computerBoard.grid[coord.row][coord.col];
    if (cell.state == CellState.hit || cell.state == CellState.miss) return;

    // Disable input while resolving shot and audio
    isProcessing = true;
    notifyListeners();

    if (cell.state == CellState.ship) {
      cell.state = CellState.hit;
      cell.ship!.hits++;
      notifyListeners(); // Show hit before playing audio
      await AudioService.playHit();
      
      if (computerBoard.allShipsSunk) {
        phase = GamePhase.gameOver;
        playerWon = true;
        isProcessing = false;
        notifyListeners();
        return;
      }
    } else {
      cell.state = CellState.miss;
      notifyListeners(); // Show miss before playing audio
      await AudioService.playMiss();
    }
    
    // Now switch phase to computer turn so the text changes
    phase = GamePhase.computerTurn;
    activeTab = 1; // Auto-swap to Your Waters
    notifyListeners();
    await _computerTurn();
  }

  Future<void> _computerTurn() async {
    Coordinate target = _getComputerTarget();
    Cell cell = playerBoard.grid[target.row][target.col];

    AudioService.playSonar();
    
    // Flash targeted cell 3 times
    for (int i = 0; i < 3; i++) {
      cell.isTargeted = true;
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 250));
      cell.isTargeted = false;
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 250));
    }
    
    AudioService.stopSonar();

    if (cell.state == CellState.ship) {
      cell.state = CellState.hit;
      cell.ship!.hits++;

      notifyListeners(); // Show hit before playing audio
      await AudioService.playComputerHit();
      
      if (playerBoard.allShipsSunk) {
        phase = GamePhase.gameOver;
        playerWon = false;
        isProcessing = false;
        notifyListeners();
        return;
      }
    } else {
      cell.state = CellState.miss;
      notifyListeners(); // Show miss before playing audio
      await AudioService.playComputerMiss();
    }
    
    // Switch back to player turn so the text changes
    phase = GamePhase.playerTurn;
    activeTab = 0; // Auto-swap to Enemy Waters
    isProcessing = false;
    notifyListeners();
  }

  Coordinate _getComputerTarget() {
    final random = Random();
    
    // Smart Hunt Logic (Standard & Hard)
    if (difficulty != Difficulty.easy) {
      Coordinate? huntTarget = _getSmartHuntTarget();
      if (huntTarget != null) return huntTarget;
    }

    List<Coordinate> validTargets = [];
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        Coordinate coord = Coordinate(r, c);
        if (_isValidTarget(coord, isLattice: true)) {
          validTargets.add(coord);
        }
      }
    }

    if (validTargets.isEmpty && difficulty == Difficulty.hard) {
      for (int r = 0; r < gridSize; r++) {
        for (int c = 0; c < gridSize; c++) {
          Coordinate coord = Coordinate(r, c);
          if (_isValidTarget(coord, isLattice: false)) {
            validTargets.add(coord);
          }
        }
      }
    }

    return validTargets[random.nextInt(validTargets.length)];
  }

  Coordinate? _getSmartHuntTarget() {
    // Group active hits by ship
    Map<Ship, List<Coordinate>> activeShipHits = {};
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        Cell cell = playerBoard.grid[r][c];
        if (cell.state == CellState.hit && cell.ship != null && !cell.ship!.isSunk) {
          activeShipHits.putIfAbsent(cell.ship!, () => []).add(Coordinate(r, c));
        }
      }
    }

    if (activeShipHits.isEmpty) return null;

    List<Coordinate> possibleTargets = [];
    
    for (var hits in activeShipHits.values) {
      if (hits.length == 1) {
        // Single hit: try all 4 orthogonal neighbors
        Coordinate h = hits.first;
        List<Coordinate> neighbors = [
          Coordinate(h.row - 1, h.col),
          Coordinate(h.row + 1, h.col),
          Coordinate(h.row, h.col - 1),
          Coordinate(h.row, h.col + 1),
        ];
        for (var n in neighbors) {
          if (_isValidTarget(n, isLattice: false)) {
            possibleTargets.add(n);
          }
        }
      } else {
        // Multiple hits: determine axis (horizontal or vertical)
        bool sameRow = hits.every((c) => c.row == hits.first.row);
        bool sameCol = hits.every((c) => c.col == hits.first.col);
        
        if (sameRow && !sameCol) {
          hits.sort((a, b) => a.col.compareTo(b.col));
          Coordinate minH = hits.first;
          Coordinate maxH = hits.last;
          if (_isValidTarget(Coordinate(minH.row, minH.col - 1), isLattice: false)) possibleTargets.add(Coordinate(minH.row, minH.col - 1));
          if (_isValidTarget(Coordinate(maxH.row, maxH.col + 1), isLattice: false)) possibleTargets.add(Coordinate(maxH.row, maxH.col + 1));
        } else if (!sameRow && sameCol) {
          hits.sort((a, b) => a.row.compareTo(b.row));
          Coordinate minH = hits.first;
          Coordinate maxH = hits.last;
          if (_isValidTarget(Coordinate(minH.row - 1, minH.col), isLattice: false)) possibleTargets.add(Coordinate(minH.row - 1, minH.col));
          if (_isValidTarget(Coordinate(maxH.row + 1, maxH.col), isLattice: false)) possibleTargets.add(Coordinate(maxH.row + 1, maxH.col));
        }
      }
    }

    if (possibleTargets.isEmpty) return null;
    possibleTargets.shuffle();
    return possibleTargets.first;
  }

  bool _isValidTarget(Coordinate c, {required bool isLattice}) {
    if (c.row < 0 || c.row >= gridSize || c.col < 0 || c.col >= gridSize) return false;
    Cell cell = playerBoard.grid[c.row][c.col];
    
    if (cell.state == CellState.hit || cell.state == CellState.miss) return false;

    if (difficulty != Difficulty.easy) {
      if (_isAdjacentToSunkShip(c)) return false;
    }

    if (isLattice && difficulty == Difficulty.hard) {
      if ((c.row + c.col) % 2 != 0) return false;
    }

    return true;
  }

  bool _isAdjacentToSunkShip(Coordinate c) {
    if (c.row > 0 && _isCellSunkShip(c.row - 1, c.col)) return true;
    if (c.row < gridSize - 1 && _isCellSunkShip(c.row + 1, c.col)) return true;
    if (c.col > 0 && _isCellSunkShip(c.row, c.col - 1)) return true;
    if (c.col < gridSize - 1 && _isCellSunkShip(c.row, c.col + 1)) return true;
    return false;
  }

  bool _isCellSunkShip(int r, int c) {
    Cell cell = playerBoard.grid[r][c];
    return cell.state == CellState.hit && cell.ship != null && cell.ship!.isSunk;
  }
}
