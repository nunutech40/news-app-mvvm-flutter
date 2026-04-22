import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_mvvm/features/auth/data/models/user_model.dart';
import 'package:news_app_mvvm/features/auth/domain/entities/user.dart';

/// -------------------------------------------------------------
/// Penjelasan Test: UserModel
/// -------------------------------------------------------------
/// TDD untuk memastikan JSON Map dari API berhasil diubah menjadi
/// objek UserModel, dan memastikan `id` aman dari perubahan tipe data 
/// dari backend (terkadang int, terkadang string).
/// -------------------------------------------------------------

void main() {
  const tUserModel = UserModel(
    id: 1,
    name: 'Budi',
    email: 'budi@test.com',
    avatarUrl: 'https://avatar.com/budi.png',
  );

  test('harus merupakan turunan dari entitas User', () {
    // 3. ASSERT
    expect(tUserModel, isA<User>());
  });

  group('fromJson', () {
    test('harus mengembalikan UserModel yang valid ketika id adalah integer', () {
      // 1. ARRANGE
      final Map<String, dynamic> jsonMap = {
        'id': 1,
        'name': 'Budi',
        'email': 'budi@test.com',
        'avatar_url': 'https://avatar.com/budi.png',
      };

      // 2. ACT
      final result = UserModel.fromJson(jsonMap);

      // 3. ASSERT
      expect(result, tUserModel);
    });

    test('harus mengembalikan UserModel yang valid ketika id adalah string angka', () {
      // 1. ARRANGE (Edge Case Backend ngirim string)
      final Map<String, dynamic> jsonMap = {
        'id': '1',
        'name': 'Budi',
        'email': 'budi@test.com',
        'avatar_url': 'https://avatar.com/budi.png',
      };

      // 2. ACT
      final result = UserModel.fromJson(jsonMap);

      // 3. ASSERT
      expect(result, tUserModel);
    });
  });
}
