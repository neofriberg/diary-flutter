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
}
