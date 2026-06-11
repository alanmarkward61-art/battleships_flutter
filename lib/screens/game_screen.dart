import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/game_state.dart';
import '../widgets/grid_widget.dart';
import '../widgets/fleet_status_widget.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Mini-Battleships', style: TextStyle(color: Colors.greenAccent, fontFamily: 'Courier')),
        actions: [
          Consumer<GameState>(
            builder: (context, gameState, child) {
              return PopupMenuButton<Difficulty>(
                icon: const Icon(Icons.psychology, color: Colors.greenAccent),
                onSelected: (Difficulty diff) {
                  gameState.setDifficulty(diff);
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<Difficulty>>[
                  const PopupMenuItem<Difficulty>(value: Difficulty.easy, child: Text('Easy Mode')),
                  const PopupMenuItem<Difficulty>(value: Difficulty.standard, child: Text('Standard Mode')),
                  const PopupMenuItem<Difficulty>(value: Difficulty.hard, child: Text('Hard Mode')),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<GameState>(
        builder: (context, gameState, child) {
          return Stack(
            children: [
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      _buildHeader(gameState.phase),
                      const SizedBox(height: 10),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          switchInCurve: Curves.easeIn,
                          switchOutCurve: Curves.easeOut,
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            return FadeTransition(opacity: animation, child: child);
                          },
                          child: gameState.activeTab == 0
                              ? _buildEnemyWaters(gameState)
                              : _buildYourWaters(gameState),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (gameState.phase == GamePhase.gameOver)
                _buildCelebrationOverlay(context, gameState.playerWon),
            ],
          );
        },
      ),
      bottomNavigationBar: Consumer<GameState>(
        builder: (context, gameState, child) {
          return BottomNavigationBar(
            backgroundColor: Colors.black,
            selectedItemColor: Colors.greenAccent,
            unselectedItemColor: Colors.green.withOpacity(0.4),
            currentIndex: gameState.activeTab,
            onTap: (index) {
              gameState.setActiveTab(index);
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.my_location),
                label: 'Enemy Waters',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shield),
                label: 'Your Waters',
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEnemyWaters(GameState gameState) {
    return Column(
      key: const ValueKey('enemy'),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('ENEMY WATERS', style: TextStyle(color: Colors.redAccent, fontFamily: 'Courier')),
            Text('SUNK: ${gameState.computerBoard.sunkShipsCount}/5', style: const TextStyle(color: Colors.redAccent, fontFamily: 'Courier')),
          ],
        ),
        const SizedBox(height: 10),
        FleetStatusWidget(board: gameState.computerBoard),
        const SizedBox(height: 10),
        Expanded(
          child: InteractiveViewer(
            minScale: 1.0,
            maxScale: 3.0,
            child: GridWidget(
              board: gameState.computerBoard,
              isPlayerBoard: false,
              onCellTap: gameState.phase == GamePhase.playerTurn
                  ? (coord) => gameState.fireAtComputer(coord)
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildYourWaters(GameState gameState) {
    return Column(
      key: const ValueKey('you'),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('YOUR WATERS', style: TextStyle(color: Colors.greenAccent, fontFamily: 'Courier')),
            Text('SUNK: ${gameState.playerBoard.sunkShipsCount}/5', style: const TextStyle(color: Colors.greenAccent, fontFamily: 'Courier')),
          ],
        ),
        const SizedBox(height: 10),
        FleetStatusWidget(board: gameState.playerBoard),
        const SizedBox(height: 10),
        Expanded(
          child: InteractiveViewer(
            minScale: 1.0,
            maxScale: 3.0,
            child: GridWidget(
              board: gameState.playerBoard,
              isPlayerBoard: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(GamePhase phase) {
    String text = 'PREPARING BATTLE...';
    if (phase == GamePhase.playerTurn) text = 'YOUR TURN - FIRE!';
    if (phase == GamePhase.computerTurn) text = 'ENEMY IS TARGETING...';
    if (phase == GamePhase.gameOver) text = 'BATTLE FINISHED';

    return Text(
      text,
      style: const TextStyle(color: Colors.greenAccent, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Courier'),
    );
  }

  Widget _buildCelebrationOverlay(BuildContext context, bool playerWon) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.8),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                playerWon ? 'VICTORY SECURED' : 'FLEET DESTROYED',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: playerWon ? Colors.greenAccent : Colors.redAccent,
                  fontFamily: 'Courier',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  side: const BorderSide(color: Colors.greenAccent, width: 2),
                ),
                onPressed: () => context.read<GameState>().resetGame(),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text('DEPLOY NEW FLEET', style: TextStyle(color: Colors.greenAccent, fontSize: 20, fontFamily: 'Courier')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
