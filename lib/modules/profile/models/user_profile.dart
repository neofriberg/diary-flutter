/// Basic user profile model.
class UserProfile {
  final String id;
  final String displayName;
  final String? email;
  final String? avatarUrl;

  const UserProfile({
    required this.id,
    required this.displayName,
    this.email,
    this.avatarUrl,
  });

  UserProfile copyWith({
    String? id,
    String? displayName,
    String? email,
    String? avatarUrl,
  }) {
    return UserProfile(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'displayName': displayName,
        'email': email,
        'avatarUrl': avatarUrl,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      email: json['email'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }
}
