enum TransactionSource{
  prizeWallet,
    personalWallet,
    inviteWallet,
    stripe,
    other;

    String get apiName {
      switch (this) {
        case TransactionSource.prizeWallet:
          return 'PRIZE_WALLET';
        case TransactionSource.personalWallet:
          return 'PERSONAL_WALLET';
        case TransactionSource.inviteWallet:
          return 'INVITE_WALLET';
        case TransactionSource.stripe:
          return 'STRIPE';
        case TransactionSource.other:
          return 'OTHER';
      }
    }
}

extension TransactionSourceExtension on TransactionSource {
  static TransactionSource fromJson(String json) {
    final normalized = json.toUpperCase();
    return TransactionSource.values.firstWhere(
      (e) => e.apiName == normalized,
      orElse: () => throw ArgumentError('Unknown transaction source: $json'),
    );
  }
}