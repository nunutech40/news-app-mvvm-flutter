# Panduan Memulai TDD (Fondasi Awal)

Catatan langkah pertama yang harus dieksekusi saat melanjutkan pengerjaan ("coding") untuk proyek `news-app-mvvm`.

Meskipun target terdekat adalah fitur **Auth**, mengawali pembuatan fitur tersebut menggunakan TDD tidak bisa langsung diketik. TDD pada *layer* ViewModel/Repository membutuhkan fondasi kokoh (alat bantu) dari *layer Core*. Jika langsung memaksa membuat *Test* pada `AuthRepository` sekarang, kita akan terhenti karena belum definisikan konvensi Error (`Failure`) dan antarmuka (*Interface*) pemanggil API (`ApiClient`) untuk dijadikan bahan *mocking*.

Berikut adalah 3 langkah fundamental berurut yang WAJIB diselesaikan terlebih dahulu **sebelum** mulai merangkai *Test Case* pada level fitur:

### Langkah 1: Menginstal Amunisi Persenjataan (`pubspec.yaml`)
Sesuai rancangan `TRD.md`, siapkan *package* yang menopang lalu lintas data antar-*layer* dan sarana *testing*.
```yaml
dependencies:
  provider: ^6.1.5
  get_it: ^9.2.1
  equatable: ^2.0.8
  dartz: ^0.10.1
  dio: ^5.9.2

dev_dependencies:
  mocktail: ^1.0.4
```

### Langkah 2: Membangun Core Error (`core/error/`)
Karena semua fungsi `Repository` akan mengembalikan kondisi `<Either, Failure, T>`, kerangka *error* ini amat genting:
- **`lib/core/error/failures.dart`**: Deklarasikan `Failure` beserta percabangannya (`ServerFailure`, `NetworkFailure`, dll).
- **`lib/core/error/exceptions.dart`**: Deklarasikan *Exception* sistem (`ServerException`) yang nanti akan dikonversi menjadi *Failure*.

### Langkah 3: Merekayasa Core Network (`core/network/api_client.dart`)
Anda belum perlu menulis struktur detail `Dio` atau *Interceptor* kompleks. Cukup rumuskan bentuk antarmuka (Interface / Skeleton) dari `ApiClient`.
```dart
abstract class ApiClient {
  Future<Map<String, dynamic>> request(
    String method,
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  });
}
```
**Alasan:** Kerangka kosong ini akan disuntik (*Inject*) ke dalam tes `AuthRepository` dan di-*mocking* balasan JSON-nya menggunakan `mocktail`.

---

**Next Action (Sesudah 3 Langkah di Atas Selesai):**
Barulah kita sah masuk ke folder `features/auth/` dan menyusun berkas uji perdana: `auth_repository_impl_test.dart` (lalu disusul `auth_view_model_test.dart`) untuk memulai siklus **Red - Green - Refactor**.
