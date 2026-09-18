/// Extracts a 10-digit phone number from a UPI ID's local part (before @).
/// Returns the 10-digit phone string ONLY if the local part matches exactly 10 digits (`^\d{10}$`).
/// Returns null otherwise, degrading gracefully without throwing exceptions.
String? extractPhoneFromUpiId(String upiId) {
  try {
    if (!upiId.contains('@')) return null;
    final parts = upiId.split('@');
    if (parts.length != 2) return null;
    final localPart = parts[0];
    final regex = RegExp(r'^\d{10}$');
    if (regex.hasMatch(localPart)) {
      return localPart;
    }
    return null;
  } catch (_) {
    return null;
  }
}
