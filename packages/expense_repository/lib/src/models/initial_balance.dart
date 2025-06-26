import '../entities/initial_balance_entity.dart';

/// Model để quản lý số dư ban đầu của người dùng
class InitialBalance {
  String balanceId; // Fixed: "initial"
  int amount; // Số dư ban đầu (VND)
  DateTime setDate; // Ngày thiết lập số dư ban đầu
  String? note; // Ghi chú về số dư ban đầu (optional)
  DateTime lastUpdated; // Lần cập nhật cuối

  InitialBalance({
    required this.balanceId,
    required this.amount,
    required this.setDate,
    this.note,
    required this.lastUpdated,
  });

  /// Instance rỗng mặc định
  static final empty = InitialBalance(
    balanceId: 'initial',
    amount: 0,
    setDate: DateTime.now(),
    note: null,
    lastUpdated: DateTime.now(),
  );

  /// Tạo ID cố định cho initial balance
  static String generateId() => 'initial';

  /// Kiểm tra xem đã có số dư ban đầu chưa
  bool get hasInitialBalance => amount != 0;

  /// Copy với các giá trị mới
  InitialBalance copyWith({
    String? balanceId,
    int? amount,
    DateTime? setDate,
    String? note,
    DateTime? lastUpdated,
  }) {
    return InitialBalance(
      balanceId: balanceId ?? this.balanceId,
      amount: amount ?? this.amount,
      setDate: setDate ?? this.setDate,
      note: note ?? this.note,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Chuyển đổi sang Entity để lưu Firebase
  InitialBalanceEntity toEntity() {
    return InitialBalanceEntity(
      balanceId: balanceId,
      amount: amount,
      setDate: setDate,
      note: note ?? '',
      lastUpdated: lastUpdated,
    );
  }

  /// Tạo từ Entity
  static InitialBalance fromEntity(InitialBalanceEntity entity) {
    return InitialBalance(
      balanceId: entity.balanceId,
      amount: entity.amount,
      setDate: entity.setDate,
      note: entity.note.isEmpty ? null : entity.note,
      lastUpdated: entity.lastUpdated,
    );
  }

  /// Tạo initial balance mới với số tiền cụ thể
  static InitialBalance create({
    required int amount,
    String? note,
  }) {
    final now = DateTime.now();
    return InitialBalance(
      balanceId: generateId(),
      amount: amount,
      setDate: now,
      note: note,
      lastUpdated: now,
    );
  }

  @override
  String toString() {
    return 'InitialBalance(amount: $amount, setDate: $setDate, note: $note)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InitialBalance &&
        other.balanceId == balanceId &&
        other.amount == amount &&
        other.setDate == setDate &&
        other.note == note;
  }

  @override
  int get hashCode {
    return balanceId.hashCode ^
        amount.hashCode ^
        setDate.hashCode ^
        note.hashCode;
  }
}
