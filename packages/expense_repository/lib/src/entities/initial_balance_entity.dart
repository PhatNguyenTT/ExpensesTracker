import 'package:cloud_firestore/cloud_firestore.dart';

class InitialBalanceEntity {
  String balanceId;
  int amount;
  DateTime setDate;
  String note;
  DateTime lastUpdated;

  InitialBalanceEntity({
    required this.balanceId,
    required this.amount,
    required this.setDate,
    required this.note,
    required this.lastUpdated,
  });

  Map<String, Object?> toDocument() {
    return {
      'balanceId': balanceId,
      'amount': amount,
      'setDate': Timestamp.fromDate(setDate),
      'note': note,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  static InitialBalanceEntity fromDocument(Map<String, dynamic> doc) {
    return InitialBalanceEntity(
      balanceId: doc['balanceId'] as String,
      amount: doc['amount'] as int,
      setDate: (doc['setDate'] as Timestamp).toDate(),
      note: doc['note'] as String? ?? '',
      lastUpdated: (doc['lastUpdated'] as Timestamp).toDate(),
    );
  }
}
