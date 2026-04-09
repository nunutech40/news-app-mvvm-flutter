# Panduan Praktis Belajar TDD di Flutter (Clean Arch + MVVM)

Inti dari TDD adalah **menulis test BUKAN untuk mengecek apakah kodemu jalan, tapi untuk *mendesain* bagaimana kodemu nanti dipanggil dan bekerja.** 

Siklusnya selalu: 
1. 🔴 **Red:** Tulis file `_test.dart` dulu sampai merah (error syntax atau logic fail).
2. 🟢 **Green:** Buat file aslinya (.dart) sesederhana mungkin **hanya** untuk membuat error merah tadi jadi ijo nge-pass.
3. 🟡 **Refactor:** Rapikan kodemu tanpa merubah `_test.dart`-nya.

---

## Urutan Wajib Pengerjaan (Step-by-Step)
Dalam Clean Architecture + MVVM, mulailah dari layer yang paling "dalam" (tidak butuh depedency file lain sama sekali).

### Langkah 1: Model & Entity (Data & Domain Layer)
*Tujuan: Memastikan parsing JSON dari API / database ke objek di aplikasi itu valid.*

1. **[RED]** Buat file `test/features/nama_fitur/data/models/mymodel_test.dart`.
   - Bikin string dummy JSON (contoh result dari API POSTman).
   - Test pemanggilan `MyModel.fromJson()`. (IDE pasti merah karena `MyModel` belum ada kelasnya).
2. **[GREEN]** Buat `lib/features/nama_fitur/domain/entities/myentity.dart`.
   - Isinya cuma class polos dengan field data (String title, dll) pakai `Equatable`.
3. **[GREEN]** Buat `lib/features/nama_fitur/data/models/mymodel.dart`.
   - `class MyModel extends MyEntity`.
   - Tulis logika map JSON-nya `fromJson` dan `toJson`.
   - Run Test! Jika pass, lanjut ke tahap berikutnya.

---

### Langkah 2: Data Source & Repository (Data & Domain Layer)
*Tujuan: Memastikan method get/post HTTP dan handling logic datanya bekerja.*

1. **[RED]** Buat `test/features/nama_fitur/data/datasources/remote_datasource_test.dart`.
   - Mocking package Http/Dio.
   - Test "What if response 200?"
   - Test "What if response 404?" (Harus lempar exception `ServerException`).
2. **[GREEN]** Buat Interface Repository di folder Domain (`my_repository.dart`). 
3. **[GREEN]** Buat File RemoteDataSource dan RemoteDataSourceImpl. 
   - Tulis script `Dio().get()` nya untuk membuat test di atas jadi Pass hijau.

**Lakukan hal yang sama untuk RepositoryImpl:**
1. **[RED]** Buat RepositoryImpl Test. (Test kalo internet mati (Left(Failure)), test kalau nyambung).
2. **[GREEN]** Bikin file Impl-nya di folder data.

*(Catatan: Langkah 2 bisa lumayan panjang, sabar-sabar lewatinnya)*

---

### Langkah 3: ViewModel (Presentation Layer)
*Tujuan: Memastikan UI logic berjalan sesuai (Loading -> Load Data -> Tampil Data / Muncul Alert).*

1. **[RED]** Buat `test/features/nama_fitur/presentation/viewmodels/my_viewmodel_test.dart`.
   - Mocking `MyRepository` pakai package `mockito` / `mocktail`.
   - **Tulis Test Skenerio**: Awalnya `state = loading`. Setelah manggil fungsi `getData()`, kalau success jadinya `state = loaded` + daftar datanya, kalau gagal jadinya `state = error` + message.
2. **[GREEN]** Buat `lib/features/nama_fitur/presentation/viewmodels/my_viewmodel.dart`.
   - Bikin class `extends ChangeNotifier`.
   - Bikin fungsi `getData()`.
   - Ganti properti state dan panggil `notifyListeners()`.
   - Run ulang MyViewModel_test, pastikan Pass!

---

### Langkah 4: View / UI Part
*Bagian ini biasanya tidak wajib ditenik TDD, kamu bisa melukis UI secara normal seperti biasa.*
1. Buat Screen Widget (.dart).
2. Gunakan `ChangeNotifierProvider` untuk inject ViewModel.
3. Tarik data (consumer/context.watch) dari state yang ada. 
4. Jika loading -> tampilkan indikator muter. Jika error -> tampilkan snackbar merah. Jika sukses -> *list view data*.

---
### Checklist Harian 📝
Setiap mau ngetik kode di file normal (`.dart`), tanyakan pada dirimu:
*"Apakah saya sudah nulis apa maunya fungsi ini di dalam file test?"*
Kalau belum, stop coding normalnya! Buka folder `test/` dan tulis maunya dulu di situ. 
