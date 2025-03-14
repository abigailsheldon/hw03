import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'card_model.dart';

/*
* Manages card list, timer, score, game logic.
* - Creates and shuffles cards.
* - Handles card flip/match logic.
* - Manages timer and game score.
* - Notifies listeners when change occurs.
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

  // For UI access
  List<CardModel> get cards => _cards;
  int get timeElapsed => _timeElapsed;
  int get score => _score;

  // Constructor
  GameProvider() {
    _initializeGame();
  }

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

    _selectedIndices = [];
    _timeElapsed = 0;
    _score = 0;

    _startTimer();
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _timeElapsed++;
      notifyListeners();
    });
  }

  void stopTimer() {
    _timer?.cancel();
  }

  void flipCard(int index) {
    // Prevent tapping an already face-up or matched card
    if (_cards[index].isFaceUp || _cards[index].isMatched) return;

    _cards[index].isFaceUp = true;
    _selectedIndices.add(index);
    notifyListeners();

    if (_selectedIndices.length == 2) {
      Future.delayed(Duration(milliseconds: 800), () {
        _checkForMatch();
      });
    }
  }

  void _checkForMatch() {
    int firstIndex = _selectedIndices[0];
    int secondIndex = _selectedIndices[1];

    if (_cards[firstIndex].content == _cards[secondIndex].content) {
      // Match found
      _cards[firstIndex].isMatched = true;
      _cards[secondIndex].isMatched = true;
      _score += 10; // Award points for matching
    } else {
      // Mismatch: flip back
      _cards[firstIndex].isFaceUp = false;
      _cards[secondIndex].isFaceUp = false;
      _score -= 2; // Deduct points for mismatch
    }

    _selectedIndices.clear();

    // Check if game is won
    if (_cards.every((card) => card.isMatched)) {
      stopTimer();
      // Optionally show a victory message here (via dialog, snackbar, etc.)
    }
    notifyListeners();
  }

  void restartGame() {
    stopTimer();
    _initializeGame();
  }
}