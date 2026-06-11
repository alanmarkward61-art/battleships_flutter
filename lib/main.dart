import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'logic/game_state.dart';
import 'screens/game_screen.dart';

void main() {
  runApp(const BattleshipsApp());
}

class BattleshipsApp extends StatelessWidget {
  const BattleshipsApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameState(),
      child: MaterialApp(
        title: 'Mini-Battleships',
        theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.green,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const GameScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
