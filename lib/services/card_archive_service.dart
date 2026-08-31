import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedCard {
  const SavedCard({
    required this.id,
    required this.message,
    required this.backgroundPath,
    required this.textColorValue,
    required this.borderColorValue,
    required this.fontSize,
    required this.createdAt,
  });

  final String id;
  final String message;
  final String backgroundPath;
  final int textColorValue;
  final int? borderColorValue;
  final double fontSize;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'message': message,
    'backgroundPath': backgroundPath,
    'textColorValue': textColorValue,
    'borderColorValue': borderColorValue,
    'fontSize': fontSize,
    'createdAt': createdAt.toIso8601String(),
  };

  factory SavedCard.fromJson(Map<String, dynamic> json) => SavedCard(
    id: json['id'] as String,
    message: json['message'] as String,
    backgroundPath: json['backgroundPath'] as String,
    textColorValue: json['textColorValue'] as int,
    borderColorValue: json['borderColorValue'] as int?,
    fontSize: (json['fontSize'] as num).toDouble(),
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}

class CardArchiveService {
  static final CardArchiveService _instance = CardArchiveService._internal();
  factory CardArchiveService() => _instance;
  CardArchiveService._internal();

  static const _storageKey = 'saved_cards';
  static const _maxCards = 30;

  final ValueNotifier<List<SavedCard>> savedCardsNotifier = ValueNotifier<List<SavedCard>>([]);

  Future<void> init() async {
    savedCardsNotifier.value = await loadCards();
  }

  Future<List<SavedCard>> loadCards() async {
    final prefs = await SharedPreferences.getInstance();
    final rawCards = prefs.getStringList(_storageKey) ?? [];
    return rawCards
        .map(
          (raw) => SavedCard.fromJson(jsonDecode(raw) as Map<String, dynamic>),
        )
        .toList();
  }

  Future<void> saveCard(SavedCard card) async {
    final cards = await loadCards();
    cards.removeWhere(
      (saved) =>
          saved.message == card.message &&
          saved.backgroundPath == card.backgroundPath,
    );
    cards.insert(0, card);
    final updatedList = cards.take(_maxCards).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _storageKey,
      updatedList.map((saved) => jsonEncode(saved.toJson())).toList(),
    );
    savedCardsNotifier.value = updatedList;
  }

  Future<void> deleteCard(String id) async {
    final cards = await loadCards();
    cards.removeWhere((card) => card.id == id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _storageKey,
      cards.map((card) => jsonEncode(card.toJson())).toList(),
    );
    savedCardsNotifier.value = cards;
  }
}
