# Panduan Praktis Belajar TDD di Flutter (Pragmatic MVVM)

Inti dari TDD adalah **menulis test BUKAN untuk mengecek apakah kodemu jalan, tapi untuk *mendesain* bagaimana kodemu nanti dipanggil dan bekerja.** 

Siklusnya selalu: 
1. 🔴 **Red:** Tulis file `_test.dart` dulu sampai merah (error syntax atau logic fail).
2. 🟢 **Green:** Buat file aslinya (.dart) sesederhana mungkin **hanya** untuk membuat error merah tadi jadi ijo nge-pass.
3. 🟡 **Refactor:** Rapikan kodemu tanpa merubah `_test.dart`-nya.

---

## Urutan Wajib Pengerjaan (Step-by-Step 4 File)
Kita memakai pendekatan **Pragmatic Clean Architecture**. Layer di-*trim* menjadi 4 bagian agar tidak terlalu banyak *boilerplate* namun tetap 100% bisa di-test.

### Langkah 1: Model (Satu file untuk Data & Entity)
*Tujuan: Memastikan parsing JSON dari API pke objek berjalan sempurna.*

1. **[RED]** Buat file `test/features/nama_fitur/models/mymodel_test.dart`.
   - Bikin string dummy JSON (contoh result dari API POSTman).
   - Test pemanggilan `MyModel.fromJson()`. (IDE pasti merah karena `MyModel` belum ada kelasnya).
2. **[GREEN]** Buat `lib/features/nama_fitur/models/mymodel.dart`.
   - Buat class `MyModel` (gunakan `Equatable` agar mudah di-Assert di tahap TDD selanjutnya).
   - Lengkapi property & logika map JSON-nya `fromJson` dan `toJson`.
   - Run Test! Jika pass, lanjut.

---

### Langkah 2: Repository (Gabungan DataSource & Repo Interface)
*Tujuan: Memastikan logic pemanggilan API / HTTP berjalan benar.*

1. **[RED]** Buat `test/features/nama_fitur/repositories/my_repository_test.dart`.
   - Mocking class `Dio` bawaan.
   - Test "Nembak API return 200".
   - Test "Nembak API return Error Server".
2. **[GREEN]** Buat file `lib/features/nama_fitur/repositories/my_repository.dart`. 
   - Langsung tulis class `MyRepository` yang isinya fungsi `Dio().get(...)` untuk meluluskan test di atas.
   - Kembalikan ke dalam *Functional Form* pakai `Either<Failure, MyModel>`.

---

### Langkah 3: ViewModel (Logic Layar)
*Tujuan: Memastikan urutan perubahan state (Loading -> Tampil List) sudah sesuai instruksi.*

1. **[RED]** Buat `test/features/nama_fitur/viewmodels/my_viewmodel_test.dart`.
   - Mocking `MyRepository` menggunakan package `mocktail`.
   - **Tulis Test Skenario**: Cek state awal `isLoading == false`. Setelah dipanggil method `getData()`, ubah jadi respon API bohong-bohongan. Cek apakah properti data sukses tersimpan ke *list* di dalam ViewModel.
2. **[GREEN]** Buat `lib/features/nama_fitur/viewmodels/my_viewmodel.dart`.
   - Bikin class `extends ChangeNotifier`.
   - Buat fungsi `getData()`.
   - Panggil `MyRepository` di dalamnya. Atur ubah state (Loading = true/false) dan jalankan `notifyListeners()`.
   - Run ulang test-nya, pastikan Pass!

---

### Langkah 4: View / UI Part
1. Buat Screen Widget (.dart).
2. Tembak `ChangeNotifierProvider` di parent Widget.
3. Gunakan `context.read()` / `context.watch()` dari ViewModel yang udah jadi otaknya.
4. (Selesai).

---
### Checklist Harian 📝
*"Apakah saya sudah nulis apa maunya fungsi ini di file test?"*
Kalau belum, stop coding .dart nya! Buka folder `test/` dan corat-coret duluan di situ.
