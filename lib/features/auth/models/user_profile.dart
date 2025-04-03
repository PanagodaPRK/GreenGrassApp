class UserProfile {
  final String id;
  final String fullName;
  final String email;
  final String mobile;
  String? profileImage;

  UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.mobile,
    this.profileImage,
  });

  // Convert to and from Firebase
  factory UserProfile.fromMap(Map<String, dynamic> map, String id) {
    return UserProfile(
      id: id,
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      mobile: map['mobile'] ?? '',
      profileImage: map['profileImage'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'mobile': mobile,
      'profileImage': profileImage,
    };
  }
}
