// lib/feature/sports/services/sports_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:afriendorse/athlete/utils/core_export.dart';

class SportsService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'sports';

  // Default sports to seed if collection is empty
  static const List<Map<String, dynamic>> _defaultSports = [
    {'id': 'football', 'name': 'Football', 'icon': '⚽', 'order': 1},
    {'id': 'basketball', 'name': 'Basketball', 'icon': '🏀', 'order': 2},
    {'id': 'tennis', 'name': 'Tennis', 'icon': '🎾', 'order': 3},
    {'id': 'athletics', 'name': 'Athletics', 'icon': '🏃', 'order': 4},
    {'id': 'swimming', 'name': 'Swimming', 'icon': '🏊', 'order': 5},
  ];

  /// Initialize default sports in Firestore (call this once during app init)
  static Future<void> initializeDefaultSports() async {
    try {
      final snapshot = await _firestore.collection(_collectionName).get();

      if (snapshot.docs.isEmpty) {
        // Seed default sports
        for (var sport in _defaultSports) {
          await _firestore.collection(_collectionName).doc(sport['id']).set({
            ...sport,
            'createdAt': FieldValue.serverTimestamp(),
            'isActive': true,
          });
        }
        if (kDebugMode) {
          print('✅ Default sports initialized in Firestore');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error initializing sports: $e');
      }
    }
  }

  /// Get all active sports from Firestore
  static Stream<List<SportModel>> getSportsStream() {
    return _firestore
        .collection(_collectionName)
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => SportModel.fromFirestore(doc))
              .toList();
        });
  }

  /// Get sports once (for dropdowns)
  static Future<List<SportModel>> getSports() async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('isActive', isEqualTo: true)
          .orderBy('order')
          .get();

      return snapshot.docs.map((doc) => SportModel.fromFirestore(doc)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching sports: $e');
      }
      // Return default sports if Firestore fails
      return _defaultSports
          .map((e) => SportModel(id: e['id'], name: e['name'], icon: e['icon']))
          .toList();
    }
  }
}

// Sport Model
class SportModel {
  final String id;
  final String name;
  final String? icon;
  final bool isActive;

  SportModel({
    required this.id,
    required this.name,
    this.icon,
    this.isActive = true,
  });

  factory SportModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SportModel(
      id: doc.id,
      name: data['name'] ?? '',
      icon: data['icon'],
      isActive: data['isActive'] ?? true,
    );
  }
}
