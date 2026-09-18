class UserProfile {
  final String name;
  final String upiId;

  const UserProfile({
    required this.name,
    required this.upiId,
  });

  bool get isValid => name.trim().isNotEmpty && upiId.trim().contains('@');

  UserProfile copyWith({String? name, String? upiId}) {
    return UserProfile(
      name: name ?? this.name,
      upiId: upiId ?? this.upiId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfile &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          upiId == other.upiId;

  @override
  int get hashCode => name.hashCode ^ upiId.hashCode;
}
