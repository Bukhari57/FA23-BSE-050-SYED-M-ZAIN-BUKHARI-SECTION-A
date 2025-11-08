class UserProfile {
  final String name;
  final String bio;
  final String? profileImagePath; // For future image support

  UserProfile({
    required this.name,
    required this.bio,
    this.profileImagePath,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'bio': bio,
      'profileImagePath': profileImagePath,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String? ?? 'User',
      bio: json['bio'] as String? ?? '',
      profileImagePath: json['profileImagePath'] as String?,
    );
  }

  UserProfile copyWith({
    String? name,
    String? bio,
    String? profileImagePath,
  }) {
    return UserProfile(
      name: name ?? this.name,
      bio: bio ?? this.bio,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }
}

