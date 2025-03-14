import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'card_model.dart';

/*
 Manages card list, timer, score, game logic.
 - Creates and shuffles cards.
 - Handles card flip/match logic.
 - Manages timer and game score.
 - Notifies listeners when change occurs.
*/
class GameProvider extends ChangeNotifier {
  // List to store all cards
  List<CardModel> _cards = [];
  // List to store indicies of current cards
  List<int> _selectedIndices = [];
  Timer? _timer;
  int _timeElapsed = 0;
  // Game score
  int _score = 0;

  /* For UI access */
  List<CardModel> get cards => _cards;
  int get timeElapsed => _timeElapsed;
  int get score => _score;

\  GameProvider() {
    _initializeGame();
  }

  /* Creates pairs of cards, shuffles, resets timer and score */
  void _initializeGame() {
    // Example: Create 8 pairs for a 4x4 grid
    List<String> contents = List.generate(8, (index) => 'Item $index');
    // Duplicate each item for a pair
    List<String> pairedContents = List.from(contents)..addAll(contents);
    pairedContents.shuffle();

    _cards = pairedContents
        .asMap()
        .entries
        .map((entry) => CardModel(id: entry.key, content: entry.value))
        .toList();

    // Clear indices 
    _selectedIndices = [];
    // Reset timer and score
    _timeElapsed = 0;
    _score = 0;

    _startTimer();
    notifyListeners();
  }

  /* Starts timer */
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _timeElapsed++;
      notifyListeners();
    });
  }

  /* Stops timer, called when game restarts/ends */
  void stopTimer() {
    _timer?.cancel();
  }

  /* Flips card at provided index */
  void flipCard(int index) {
    // No tapping face-up or matched card
    if (_cards[index].isFaceUp || _cards[index].isMatched) return;

    // Flip card to face-up
    _cards[index].isFaceUp = true;
    _selectedIndices.add(index);
    notifyListeners();

    // If two cards selected, check match
    if (_selectedIndices.length == 2) {
      Future.delayed(Duration(milliseconds: 800), () {
        _checkForMatch();
      });
    }
  }

  /* Checks if two cards are matches */
  void _checkForMatch() {
    int firstIndex = _selectedIndices[0];
    int secondIndex = _selectedIndices[1];

    // If card contents equal, match
    if (_cards[firstIndex].content == _cards[secondIndex].content) {
      // Match found
      _cards[firstIndex].isMatched = true;
      _cards[secondIndex].isMatched = true;
      _score += 10; // Award points for matching
    } else {
      // Mismatch, flip cards back
      _cards[firstIndex].isFaceUp = false;
      _cards[secondIndex].isFaceUp = false;
      _score -= 2;
    }

    // Clear selection for next turn
    _selectedIndices.clear();

    // Check if game is won (all cards matched)
    if (_cards.every((card) => card.isMatched)) {
      stopTimer();
    }
    notifyListeners();
  }

  /* Restarts game */
  void restartGame() {
    stopTimer();
    _initializeGame();
  }
}
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => GameProvider(),
      child: const MyApp(),
    ),
  );
}

/* Root widget */
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Card Matching Game',
      home: const GameScreen(),
    );
  }
}

/* Main screen */
class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Matching Game'),
        actions: [
          // Restart button to restart the game
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              gameProvider.restartGame();
            },
          )
        ],
      ),
      body: Column(
        children: [
          // Display timer and score
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('Time: ${gameProvider.timeElapsed} sec'),
                Text('Score: ${gameProvider.score}'),
              ],
            ),
          ),
          // Grid expanded to fill screen
          Expanded(
            // Grid of cards
            child: GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: gameProvider.cards.length,
              itemBuilder: (context, index) {
                return CardWidget(index: index);
              },
            ),
          ),
        ],
      ),
    );
  }
}

/* Represents each individual card */
class CardWidget extends StatelessWidget {
  final int index; // Index of the card in the list
  const CardWidget({super.key, required this.index});

}