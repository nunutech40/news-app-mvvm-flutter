import 'package:equatable/equatable.dart';

/// -------------------------------------------------------------
/// Penjelasan Implementasi: User Entity
/// -------------------------------------------------------------
/// Ini adalah inti dari Clean Architecture Domain Layer!
/// -------------------------------------------------------------
class User extends Equatable {
  final int id;
  final String name;
  final String email;
  final String avatarUrl;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl = '',
  });

  @override
  List<Object?> get props => [id, name, email, avatarUrl];
}
