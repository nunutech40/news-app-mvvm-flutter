import 'package:news_app_mvvm/features/auth/domain/entities/user.dart';

/// -------------------------------------------------------------
/// Penjelasan Implementasi: UserModel
/// -------------------------------------------------------------
/// Jembatan JSON Map menuju Entity (bahasa Domain).
/// -------------------------------------------------------------
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    super.avatarUrl = '',
    super.bio = '',
    super.phone = '',
    super.preferences = '',
    super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: _parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      avatarUrl: json['avatar_url']?.toString() ?? '',
      bio: json['bio']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      preferences: json['preferences']?.toString() ?? '',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar_url': avatarUrl,
      'bio': bio,
      'phone': phone,
      'preferences': preferences,
    };
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
