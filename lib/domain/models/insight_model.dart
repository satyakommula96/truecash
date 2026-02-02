// import 'package:flutter/material.dart'; // Removed

enum InsightType { warning, success, info, prediction }

enum InsightPriority { high, medium, low }

class AIInsight {
  final String id;
  final String title;
  final String body;
  final InsightType type;
  final InsightPriority priority;
  final String value;
  final num? currencyValue;
  final double confidence;
  final int cooldownDays;

  AIInsight({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.priority,
    required this.value,
    this.currencyValue,
    this.confidence = 0.85,
    this.cooldownDays = 7, // Default 1 week
  });
}
