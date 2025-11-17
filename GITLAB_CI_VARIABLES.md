# GitLab CI/CD Variables Configuration

## Biến Cần Thiết (Required Variables)

### 1. Android Signing Variables (Bắt buộc cho build Android)

Vào **Settings > CI/CD > Variables** trên GitLab và thêm các biến sau:

#### `KEYSTORE_BASE64`
- **Type:** Variable (Protected)
- **Description:** File keystore được mã hóa Base64
- **Cách tạo:**
  ```bash
  # Trên Windows (PowerShell)
  [Convert]::ToBase64String([IO.File]::ReadAllBytes("path/to/your/upload-keystore.jks"))
  
  # Trên Linux/Mac
  base64 -i upload-keystore.jks -o keystore.txt
  # Copy nội dung file keystore.txt
  ```
- **Protected:** ✅ Yes
- **Masked:** ❌ No (quá dài để mask)

#### `KEYSTORE_PASSWORD`
- **Type:** Variable (Protected, Masked)
- **Description:** Mật khẩu của keystore
- **Example:** `your_keystore_password`
- **Protected:** ✅ Yes
- **Masked:** ✅ Yes

#### `KEY_PASSWORD`
- **Type:** Variable (Protected, Masked)
- **Description:** Mật khẩu của key trong keystore
- **Example:** `your_key_password`
- **Protected:** ✅ Yes
- **Masked:** ✅ Yes

#### `KEY_ALIAS`
- **Type:** Variable (Protected)
- **Description:** Alias của key trong keystore
- **Example:** `upload` hoặc `key0`
- **Protected:** ✅ Yes
- **Masked:** ❌ No

---

## Biến Tùy Chọn (Optional Variables)

### 2. Deployment Variables (Nếu triển khai lên Play Store/App Store)

#### `PLAY_STORE_CREDENTIALS`
- **Type:** File
- **Description:** File JSON service account từ Google Play Console
- **Protected:** ✅ Yes
- **Usage:** Dùng để upload AAB lên Play Store tự động

#### `FIREBASE_TOKEN`
- **Type:** Variable (Protected, Masked)
- **Description:** Token để deploy lên Firebase App Distribution
- **Cách lấy:** `firebase login:ci`
- **Protected:** ✅ Yes
- **Masked:** ✅ Yes

---

## Cấu Hình Keystore Android

### Cách tạo Keystore (nếu chưa có)

```bash
keytool -genkey -v -keystore upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Lưu thông tin:
- Store password: [Lưu vào `KEYSTORE_PASSWORD`]
- Key password: [Lưu vào `KEY_PASSWORD`]
- Alias: [Lưu vào `KEY_ALIAS`]

### Cấu hình trong `android/app/build.gradle.kts`

Đảm bảo file có cấu hình signing:

```kotlin
android {
    ...
    signingConfigs {
        create("release") {
            val keystorePropertiesFile = rootProject.file("key.properties")
            if (keystorePropertiesFile.exists()) {
                val keystoreProperties = Properties()
                keystoreProperties.load(FileInputStream(keystorePropertiesFile))
                
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
            }
        }
    }
    
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}
```

---

## GitLab Runner Tags

### Cho iOS Build
Bạn cần có GitLab Runner với tag `macos` để build iOS. Nếu không có:
- Tắt job `build_ios` bằng cách comment hoặc
- Sử dụng shared runner có hỗ trợ macOS (nếu có)

---

## Checklist Triển Khai

- [ ] Tạo keystore file (nếu chưa có)
- [ ] Upload `KEYSTORE_BASE64` lên GitLab Variables
- [ ] Thêm `KEYSTORE_PASSWORD` vào GitLab Variables
- [ ] Thêm `KEY_PASSWORD` vào GitLab Variables
- [ ] Thêm `KEY_ALIAS` vào GitLab Variables
- [ ] Xác nhận cấu hình signing trong `android/app/build.gradle.kts`
- [ ] Test CI pipeline với commit mới
- [ ] (Optional) Cấu hình deployment credentials

---

## Commands Hữu Ích

### Test Pipeline Locally
```bash
# Kiểm tra cú pháp
cat .gitlab-ci.yml

# Test Flutter build
flutter build apk --release
flutter build appbundle --release
```

### Verify Keystore
```bash
keytool -list -v -keystore upload-keystore.jks -alias upload
```

### View GitLab Variables
Settings > CI/CD > Variables (trên GitLab web interface)

---

## Bảo Mật

⚠️ **QUAN TRỌNG:**
1. ❌ KHÔNG commit keystore file vào Git
2. ❌ KHÔNG commit `key.properties` vào Git
3. ✅ Thêm vào `.gitignore`:
   ```
   android/key.properties
   android/upload-keystore.jks
   android/*.jks
   ```
4. ✅ Chỉ bật "Protected" cho các biến sensitive
5. ✅ Bật "Masked" cho passwords

---

## Troubleshooting

### Lỗi: "Keystore file not found"
- Kiểm tra biến `KEYSTORE_BASE64` đã được set chưa
- Verify base64 encoding đúng format

### Lỗi: "Wrong password"
- Kiểm tra `KEYSTORE_PASSWORD` và `KEY_PASSWORD`
- Verify không có khoảng trắng thừa

### Build thành công nhưng không signed
- Kiểm tra `android/app/build.gradle.kts` có cấu hình `signingConfigs`
- Verify file `key.properties` được tạo trong before_script

---

## Next Steps

Sau khi cấu hình xong variables:
1. Push code lên branch `main` hoặc `develop`
2. Kiểm tra pipeline tại: **CI/CD > Pipelines**
3. Download APK/AAB từ artifacts nếu build thành công
4. Cấu hình deployment (optional)
