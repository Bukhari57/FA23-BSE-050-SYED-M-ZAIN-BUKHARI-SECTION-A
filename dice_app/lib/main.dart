// 🎲 Simple Dice Game (Beginner-Friendly, <200 lines)
// Developed with simplicity + comments for understanding

import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const DiceApp());

class DiceApp extends StatelessWidget {
  const DiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '🎲 Dice Game',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const DiceGame(),
    );
  }
}

class DiceGame extends StatefulWidget {
  const DiceGame({super.key});
  @override
  State<DiceGame> createState() => _DiceGameState();
}

class _DiceGameState extends State<DiceGame> {
  // Controllers for player name text fields
  final List<TextEditingController> _controllers =
  List.generate(4, (_) => TextEditingController());

  int _playerCount = 2; // default players = 2
  int _dice = 1; // current dice number
  int _round = 1; // current round number
  int _currentPlayer = 0; // whose turn
  final int _maxRounds = 5; // total rounds
  bool _gameOver = false; // flag for end of game
  Map<String, int> _scores = {}; // store player scores

  // 🔹 Start or reset game
  void _startGame() {
    setState(() {
      _scores.clear();
      for (int i = 0; i < _playerCount; i++) {
        String name = _controllers[i].text.isEmpty
            ? "Player ${i + 1}"
            : _controllers[i].text;
        _scores[name] = 0;
      }
      _round = 1;
      _currentPlayer = 0;
      _dice = 1;
      _gameOver = false;
    });
  }

  // 🎲 Roll dice and update scores
  void _rollDice() {
    if (_scores.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please start the game first!")),
      );
      return;
    }
    if (_gameOver) return;

    setState(() {
      _dice = Random().nextInt(6) + 1; // random 1–6
      String current = _scores.keys.elementAt(_currentPlayer);
      _scores[current] = _scores[current]! + _dice;

      // Next player or next round
      if (_currentPlayer == _scores.length - 1) {
        if (_round < _maxRounds) {
          _round++;
          _currentPlayer = 0;
        } else {
          _gameOver = true;
        }
      } else {
        _currentPlayer++;
      }
    });
  }

  // 🏆 Get winner name and score
  String _getWinner() {
    if (_scores.isEmpty) return "";
    var winner = _scores.entries.reduce((a, b) => a.value > b.value ? a : b);
    return "${winner.key} (${winner.value} pts)";
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.teal,
      appBar: AppBar(
        title: const Text("🎲 Dice Game By Zain",
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.normal)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // 🔹 Player name inputs
          const Text("Enter Player Names",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          for (int i = 0; i < _playerCount; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: TextField(
                controller: _controllers[i],
                decoration: InputDecoration(
                  labelText: "Player ${i + 1}",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50)),
                ),
              ),
            ),

          const SizedBox(height: 10),
          // 🔹 Dropdown to choose players (2–4)
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text("Players: "),
            DropdownButton<int>(
              value: _playerCount,
              items: [2, 3, 4]
                  .map((n) => DropdownMenuItem(value: n, child: Text("$n")))
                  .toList(),
              onChanged: (v) => setState(() {
                _playerCount = v!;
                _startGame();
              }),
            ),
          ]),

          const SizedBox(height: 10),
          // 🔹 Start / Reset Button
          ElevatedButton.icon(
            onPressed: _startGame,
            icon: const Icon(Icons.play_arrow_outlined),
            label: const Text("Start / Reset Game"),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 10)),
          ),

          const SizedBox(height: 20),
          // 🔹 Show Round info
          Text("Round $_round / $_maxRounds",
              style:
              const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          if (!_gameOver && _scores.isNotEmpty)
            Text("Turn: ${_scores.keys.elementAt(_currentPlayer)}",
                style: const TextStyle(color: Colors.black)),

          const SizedBox(height: 20),
          // 🎲 Dice image
          GestureDetector(
            onTap: _rollDice,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: w * 0.2,
              height: w * 0.2,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: const [
                    BoxShadow(blurRadius: 10, offset: Offset(5, 5))
                  ]),
              child: Image.asset("assets/images/dice$_dice.png"),
            ),
          ),

          const SizedBox(height: 10),
          if (!_gameOver)
            ElevatedButton.icon(
              onPressed: _rollDice,
              icon: const Icon(Icons.casino),
              label: const Text("Roll Dice"),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 20)),
            ),

          const SizedBox(height: 25),
          // 🧾 Scoreboard
          const Text("Scoreboard",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 1),
          for (var entry in _scores.entries)
            Card(
              child: ListTile(
                title: Text(entry.key),
                trailing: Text("${entry.value}",
                    style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold)),
              ),
            ),

          const SizedBox(height: 20),
          // 🏁 Game Over + Winner
          if (_gameOver)
            Column(children: [
              const Text("🎉 Game Over!",
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
              Text("🏆 Winner: ${_getWinner()}",
                  style: const TextStyle(fontSize: 18)),
            ]),
        ]),
      ),
    );
  }
}
