# Spesifikasi Desain Fitur: Authentication (Login)

Dokumen ini menjelaskan rancangan alur fungsional dan teknis untuk fitur **Login** di aplikasi `news-app-mvvm` sesuai dengan *Pragmatic Clean Architecture (MVVM)*.

---

## 1. Flowchart Login (User & Business Flow)
Flowchart ini **murni** menggambarkan alur perjalanan pengguna (User Journey) dan Keputusan Sistem pada interaksi antarmuka (UI). Tidak dicampur dengan istilah teknis (*class/layer*).

```mermaid
graph TD
    A([Start: User Menekan Tombol Login]) --> B{Validasi Input Form?}
    
    B -- Kosong/Format Salah --> C[Sistem Memunculkan Peringatan Validasi]
    
    B -- Format Valid --> D[Sistem Menampilkan Indikator Loading]
    D --> E[Sistem Melakukan Autentikasi ke Server]
    
    E --> F{Status Koneksi & Respon?}
    F -- Mode Pesawat/Timeout --> G[Sistem Memunculkan Alert Gangguan Jaringan]
    F -- Tersambung ke Server --> H{Pengecekan Kredensial}
    
    H -- Salah (401) --> I[Sistem Memunculkan Alert Salah Email/Password]
    H -- Berhasil (200) --> J[Sistem Menyimpan Sesi (Token Lokal)]
    
    C --> O([Flow Selesai])
    G --> O
    I --> O
    
    J --> N[Sistem Mengarahkan User ke Dashboard]
    N --> P([Flow Selesai & Berhasil])
```

---

## 2. Sequence Diagram Login
Diagram ini menggambarkan interaksi langsung antar komponen di setiap layer (4-layer murni) demi mempertahankan *Separation of Concern*.

```mermaid
sequenceDiagram
    autonumber
    actor User
    participant View as LoginPage (UI)
    participant VM as AuthViewModel
    participant Repo as AuthRepository
    participant API as ApiClient (Dio)
    participant DB as LocalStorage (SecurePrefs)

    User->>View: Mengisi Email & Password
    User->>View: Tap "Login"
    View->>VM: login(email, password)
    
    activate VM
    VM->>View: Ubah ke state Loading
    VM->>Repo: loginUser(email, password)
    
    activate Repo
    Repo->>API: POST /api/v1/auth/login
    
    activate API
    alt Server Error / Wrong Password (401)
        API-->>Repo: throw DioException(401)
        Repo-->>VM: return Left(ServerFailure)
        VM->>View: Ubah state ke Error (Muncul Alert)
    else Success (200 OK)
        API-->>Repo: JSON Response {access_token, ...}
        deactivate API
        Repo->>DB: saveTokens()
        activate DB
        DB-->>Repo: void
        deactivate DB
        Repo-->>VM: return Right(AuthTokensModel)
    end
    deactivate Repo
    
    VM->>View: Ubah state ke Success
    deactivate VM
    
    View->>User: Navigasi ke Dashboard (goRouter)
```
