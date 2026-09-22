# Shankara Dev - Aplikasi Mobile (Flutter)

Aplikasi Android untuk Sistem Informasi Perumahan Shankara Dev.
Menggunakan REST API yang sudah tersedia di `C:\xampp\htdocs\shandev\api`.

## Fitur (Core)

- **Login / Logout** — otentikasi via API `/auth/login` (sesi PHPSESSID)
- **Dashboard** — ringkasan transaksi, unit per status, pembayaran bulan ini, transaksi terbaru
- **Transaksi** — daftar + pencarian + detail (konsumen, unit, pembayaran & akad)
- **Unit Rumah** — daftar + filter status (tersedia/booking/terjual) + detail
- **Konsumen** — daftar + pencarian + detail

## Struktur Proyek

```
lib/
  main.dart                 # Entry point + routing
  theme.dart                # Tema global (biru tema website)
  config/app_config.dart    # Base URL server
  services/
    api_client.dart         # HTTP client + sesi cookie
    api_service.dart        # Panggilan endpoint (dashboard, transaksi, unit, konsumen)
    auth_service.dart       # Login/logout + penyimpanan sesi lokal
  models/                   # Model data (dashboard, transaksi, rumah, konsumen, user)
  screens/
    splash_screen.dart
    login/login_screen.dart
    home/home_screen.dart   # Bottom navigation 4 tab
    dashboard/dashboard_screen.dart
    transaksi/transaksi_screen.dart + transaksi_detail_screen.dart
    unit/unit_screen.dart + unit_detail_screen.dart
    konsumen/konsumen_screen.dart + konsumen_detail_screen.dart
  utils/formatters.dart     # Format Rupiah, tanggal, inisial
  widgets/status_chip.dart  # Badge status (PROSES/ACC/BATAL/dll)
```

## Kebutuhan

- Flutter SDK 3.47+ (`D:\flutter`) — tersedia di mesin dev
- JDK 17 (`D:\jdk-17.0.20.1+1`)
- Android SDK (`D:\android\sdk`, platform android-36)
- Server API: XAMPP di `http://<ip-server>/shandev/api`

## Menjalankan

```bash
# Atur env
$env:PATH = "D:\flutter\bin;$env:PATH"
$env:ANDROID_HOME = "D:\android\sdk"
$env:JAVA_HOME = "D:\jdk-17.0.20.1+1"

flutter pub get
flutter analyze       # cek kode
flutter test          # unit test
flutter run           # jalankan (device Android / emulator)
```

## Build APK

```bash
flutter build apk --release
# Hasil: build\app\outputs\flutter-apk\app-release.apk
```

**Alamat server**: sesuaikan di layar Login → tombol `Server:` (default `http://10.10.10.100/shandev/api`). Dari HP yang terhubung ke jaringan yang sama dengan server, ganti IP dengan IP server (mis. IP Tailscale / LAN).

## Catatan Teknis

- **Sesi**: API memakai sesi cookie PHP. Setelah login, `PHPSESSID` disimpan dan dikirim di setiap request. Disimpan persisten via `shared_preferences` sehingga aplikasi tetap login saat dibuka ulang (divalidasi via `/auth/check`).
- **Cleartext HTTP**: `android:usesCleartextTraffic="true"` diaktifkan di AndroidManifest karena server dev memakai HTTP (bukan HTTPS). Untuk produksi publik harus HTTPS.
- **Incremental Kotlin**: dimatikan di `android/gradle.properties` (`kotlin.incremental=false`) karena pub cache di drive C: sedangkan project di D: (bug root beda drive).
- **Deploy APK**: salin `app-release.apk` ke HP Android lalu install (allow unknown sources). App label: "Shankara Dev".