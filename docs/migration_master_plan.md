# Master Plan Migrasi: News App (BLoC) ➡️ News App MVVM (Provider)

Dokumen ini berisi peta jalan (*roadmap*) eksekusi bertahap untuk memigrasikan seluruh fitur dari `news-app` (arsitektur BLoC) ke `news-app-mvvm` (arsitektur MVVM + Provider), dengan mematuhi prinsip **TDD Workflow**.

## Perbedaan Utama (BLoC vs MVVM)
- **State Management**: Tidak ada lagi `Cubit`, `Bloc`, `BlocBuilder`, atau `BlocListener`. Semua diganti dengan `ChangeNotifier`, `notifyListeners()`, `context.watch()`, dan `Consumer()`.
- **Data Fetching**: *Error handling* tidak lagi mengandalkan transisi state *Loading -> Error -> Loaded*. ViewModel akan memanggil fungsi secara linear menggunakan `Either.fold()`, lalu merubah variabel *state* internal dan memanggil `notifyListeners()`.
- **Dependency Injection**: ViewModel untuk halaman spesifik (seperti NewsFeed, DetailArticle) diregistrasi sebagai `Factory` agar tereset saat keluar halaman. Hanya *Global State* (seperti `AuthViewModel`) yang diregistrasi sebagai `LazySingleton`.

---

## 🗺️ Fase Eksekusi

### Fase 1: Penyelesaian Modul Dasar (Auth & Splash)
*Saat ini Login sudah selesai. Kita perlu menyelesaikan fondasi gerbang masuk aplikasi.*
- [ ] **Langkah 1: Modul Register (TDD)**
  - Buat `RegisterUseCase`.
  - Tambahkan method `register()` di `AuthViewModel`.
  - Buat `RegisterPage` UI (copas dari *news-app* dan ubah ke Consumer).
- [ ] **Langkah 2: Modul Splash**
  - Buat `SplashPage` UI.
  - Tambahkan logika inisialisasi di `AuthViewModel` (mengecek apakah *token* masih valid di *local storage*).
  - Sesuaikan `GoRouter` untuk menangani status *Splash -> Login / Dashboard*.

### Fase 2: Kerangka Dashboard & Profil
*Membuat rumah utama aplikasi sebelum diisi berita.*
- [ ] **Langkah 3: Dashboard Shell**
  - Buat `DashboardPage` sejati yang memiliki `BottomNavigationBar` (Tab: Home, Explore, Bookmark, Profile).
  - Integrasikan pergantian halaman menggunakan `StatefulWidget` atau *ViewModel* kecil khusus navigasi.
- [ ] **Langkah 4: Modul Profile**
  - Buat `ProfilePage` UI (mengambil data dari `context.watch<AuthViewModel>().currentUser`).
  - Pindahkan tombol **Logout** dari AppBar sementara ke halaman ini.

### Fase 3: Mesin Utama Berita (Data & Domain Layer)
*Mengerjakan jantung aplikasi dengan TDD murni tanpa UI.*
- [ ] **Langkah 5: News Data Layer (TDD)**
  - Buat `ArticleModel` dan `CategoryModel`.
  - Buat `NewsRemoteDataSource` (fetch dari API).
  - Buat `NewsRepositoryImpl`.
- [ ] **Langkah 6: News Domain Layer (TDD)**
  - Buat UseCase esensial: `GetNewsFeedUseCase`, `GetCategoriesUseCase`, dan `GetArticleUseCase`.
  - Lakukan *Unit Testing* untuk memastikan parsing JSON dan `Either<Failure, T>` berjalan sempurna.

### Fase 4: Tampilan Berita (News Feed & Explore)
*Mengubah Cubit menjadi ViewModel dan merakit UI-nya.*
- [ ] **Langkah 7: News Feed**
  - Buat `TrendingViewModel` (khusus carousel berita trending) dan `NewsFeedViewModel` (khusus list berita terbaru).
  - Rakit `NewsFeedPage` UI dengan *pull-to-refresh*. Gunakan `ChangeNotifierProvider` di level halaman, bukan Global.
- [ ] **Langkah 8: Explore & Search**
  - Buat `CategoryViewModel` (mengambil daftar kategori), `ExploreViewModel` (menampilkan berita per kategori), dan `SearchViewModel` (mengambil *query* teks).
  - Rakit `ExplorePage` dan `NewsSearchPage` UI.

### Fase 5: Artikel Detail & Sistem Bookmark
*Penyelesaian fitur interaktif.*
- [ ] **Langkah 9: Bookmark Data & Domain (TDD)**
  - Buat `BookmarkLocalDataSource` (pakai *SharedPreferences* atau *Hive*).
  - Buat UseCase: `ToggleBookmarkUseCase`, `GetBookmarksUseCase`, `CheckBookmarkStatusUseCase`.
- [ ] **Langkah 10: Article Detail**
  - Buat `ArticleDetailViewModel`.
  - Rakit `ArticleDetailPage` UI (menampilkan konten penuh dan tombol *save*).
- [ ] **Langkah 11: Bookmark UI**
  - Buat `BookmarkViewModel`.
  - Rakit `BookmarkPage` UI untuk menampilkan daftar berita yang disimpan.

---

## 🚦 Aturan Main (Rule of Engagement)
Setiap kali memulai satu Langkah di atas, kita WAJIB mematuhi prosedur `/tdd_workflow`:
1. Bikin/Sesuaikan **Model**.
2. Bikin/Sesuaikan **DataSource & Repository** (+ Test).
3. Bikin **ViewModel** (+ Test).
4. Rakit **UI** & Sambungkan kabelnya di `injection_container.dart`.
