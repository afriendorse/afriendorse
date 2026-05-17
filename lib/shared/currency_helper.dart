import 'package:cloud_firestore/cloud_firestore.dart';

class Currency {
  static String symbol = '\$'; // Default

  static void init() {
    FirebaseFirestore.instance
        .collection('currency_options')
        .doc('active')
        .snapshots()
        .listen((snap) {
          if (snap.exists) {
            symbol = snap.data()?['symbol'] ?? '\$';
          }
        });
  }
}
