# Spesifikasi Desain Fitur: Authentication (Login)

Dokumen ini menjelaskan rancangan alur fungsional dan teknis untuk fitur **Login** di aplikasi `news-app-mvvm` sesuai dengan *Pragmatic Clean Architecture (MVVM)*.

---

## 1. Flowchart Login
Flowchart ini menggambarkan *decision checking* secara proses fungsional yang dialami oleh fitur Login dari input user hingga selesai.

```mermaid
graph TD
    A([Start: Pencet Tombol Login]) --> B{Validasi Input Form?}
    B -- Kosong/Salah Format --> C[Tampilkan Peringatan UI]
    B -- Valid --> D[Panggil AuthViewModel.login]
    
    D --> E[Set State: isLoading = true]
    E --> F[AuthRepo.login]
    
    F --> G{Koneksi API Berhasil?}
    G -- Gagal Network/Timeout --> H[Return Left: NetworkFailure]
    G -- Sukses Terkirim --> I{Kredensial Benar? 200 OK}
    
    I -- Salah 401 --> J[Return Left: ServerFailure 'Invalid Credential']
    I -- Benar 200 --> K[Save Token ke Local Storage]
    
    K --> L[Return Right: AuthTokens Model]
    
    H --> M(ViewModel Terima Left)
    J --> M
    L --> N(ViewModel Terima Right)
    
    M --> O[Set State: Error + Panggil alert]
    N --> P[Set State: Success + Navigate to Dashboard]
    
    O --> Q([End])
    P --> Q([End])
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
