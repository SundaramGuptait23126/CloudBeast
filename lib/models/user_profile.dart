class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final bool isDemo;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    this.isDemo = false,
  });

  factory UserProfile.demo() {
    return const UserProfile(
      id: 'demo_user',
      name: 'Google Drive User',
      email: 'my_drive@gmail.com',
      photoUrl: null,
      isDemo: true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'photoUrl': photoUrl,
        'isDemo': isDemo,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        photoUrl: json['photoUrl'] as String?,
        isDemo: (json['isDemo'] as bool?) ?? false,
      );
}
