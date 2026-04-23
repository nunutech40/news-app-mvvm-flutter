import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_mvvm/core/error/failures.dart';

/// -------------------------------------------------------------
/// Penjelasan Test: Failure Classes Murni
/// -------------------------------------------------------------
/// File ini bertugas untuk mengamankan fondasi *Error Handling* lintas layer.
/// 
/// Kebutuhan (Requirements):
/// 1. [Value Equality]: Class `Failure` dan turunannya HARUS memakai `Equatable`.
///    Kenapa? Karena dalam TDD `Repository`, jika kita mau *assert* kecocokan hasil
///    seperti `expect(result, Left(ServerFailure('A')))`, Flutter akan menganggap 
///    mereka **Beda** kalau kita tidak pakai Equatable (karena beda ID Memori 
///    meski pesannya sama).
/// -------------------------------------------------------------

void main() {
  group('ServerFailure', () {
    test('harus mereturn true (identik) saat dikomparasi dengan objek lain yang isi property-nya sama', () {
      // 1. ARRANGE
      // Siapkan dua objek yang dicetak/diinstansiasi secara terpisah 
      // tetapi memiliki isi 'message' dan 'statusCode' yang 100% sama.
      const tFailure1 = ServerFailure(message: 'Internal Server Error', statusCode: 500);
      const tFailure2 = ServerFailure(message: 'Internal Server Error', statusCode: 500);

      // 2. ACT
      // Aksi utamanya ada pada operasi pembandingan komparasi `==`.
      final result = tFailure1 == tFailure2;

      // 3. ASSERT
      // Buktikan pengujian bernilai true. Jika ini merah (false), berarti
      // developer lupa me-return props si Equatable di class ServerFailure-nya!
      expect(result, isTrue);
    });
    
    test('harus mereturn false jika properti berbeda', () {
      // 1. ARRANGE
      const tFailure1 = ServerFailure(message: 'Error A', statusCode: 404);
      const tFailure2 = ServerFailure(message: 'Error B', statusCode: 404);

      // 2. ACT
      final result = tFailure1 == tFailure2;

      // 3. ASSERT
      expect(result, isFalse);
    });
  });

  group('NetworkFailure', () {
    test('harus mereturn true (identik) saat dikomparasi dengan NetworkFailure lain berpesan sama', () {
      // 1. ARRANGE
      const tFailure1 = NetworkFailure(message: 'No Internet Connection');
      const tFailure2 = NetworkFailure(message: 'No Internet Connection');

      // 2. ACT
      final result = tFailure1 == tFailure2;

      // 3. ASSERT
      expect(result, isTrue);
    });
  });

  group('CacheFailure', () {
    test('harus mereturn true saat dikomparasi dengan objek CacheFailure yang sama', () {
      // 1. ARRANGE
      const tFailure1 = CacheFailure(message: 'Storage Penuh');
      const tFailure2 = CacheFailure(message: 'Storage Penuh');

      // 2. ACT & 3. ASSERT
      expect(tFailure1, equals(tFailure2));
    });

    test('harus mereturn false saat dikomparasi dengan objek CacheFailure dengan pesan berbeda', () {
      // 1. ARRANGE
      const tFailure1 = CacheFailure(message: 'Storage Penuh');
      const tFailure2 = CacheFailure(message: 'Akses Ditolak');

      // 2. ACT & 3. ASSERT
      expect(tFailure1, isNot(equals(tFailure2)));
    });
  });
}
