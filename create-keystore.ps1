# Script tự động tạo keystore mới cho Android signing
# Chạy script này trong PowerShell tại thư mục gốc project

Write-Host "=== TẠO KEYSTORE MỚI CHO ANDROID APP ===" -ForegroundColor Cyan
Write-Host ""

# Thông tin keystore
$keystorePath = "android\app\upload-keystore.jks"
$alias = "upload"
$validity = 10000 # 10000 ngày (khoảng 27 năm)

# Nhập thông tin
Write-Host "Nhập thông tin cho keystore:" -ForegroundColor Yellow
$storePassword = Read-Host "Keystore Password (KEYSTORE_PASSWORD)" -AsSecureString
$storePasswordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($storePassword))

$keyPassword = Read-Host "Key Password (KEY_PASSWORD) - Enter để dùng password giống keystore" -AsSecureString
$keyPasswordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($keyPassword))
if ([string]::IsNullOrWhiteSpace($keyPasswordPlain)) {
    $keyPasswordPlain = $storePasswordPlain
}

$cn = Read-Host "Tên của bạn (Common Name)"
$ou = Read-Host "Tổ chức/Team (Organization Unit)"
$o = Read-Host "Công ty (Organization)"
$l = Read-Host "Thành phố (Locality)"
$st = Read-Host "Tỉnh/Bang (State)"
$c = Read-Host "Mã quốc gia 2 ký tự (Country Code, VD: VN)"

Write-Host ""
Write-Host "=== BƯỚC 1: Xóa keystore cũ (nếu có) ===" -ForegroundColor Cyan

if (Test-Path $keystorePath) {
    Write-Host "Tìm thấy keystore cũ tại: $keystorePath" -ForegroundColor Yellow
    $confirm = Read-Host "Xóa và tạo mới? (y/n)"
    if ($confirm -eq "y") {
        Remove-Item $keystorePath -Force
        Write-Host "Đã xóa keystore cũ" -ForegroundColor Green
    } else {
        Write-Host "Hủy tạo keystore mới" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "=== BƯỚC 2: Tạo keystore mới ===" -ForegroundColor Cyan

# Tạo thư mục nếu chưa có
$keystoreDir = Split-Path $keystorePath -Parent
if (-not (Test-Path $keystoreDir)) {
    New-Item -ItemType Directory -Path $keystoreDir -Force | Out-Null
}

# Tạo keystore
$dname = "CN=$cn, OU=$ou, O=$o, L=$l, ST=$st, C=$c"

Write-Host "Đang tạo keystore..." -ForegroundColor Yellow
keytool -genkeypair -v `
    -keystore $keystorePath `
    -storetype JKS `
    -keyalg RSA `
    -keysize 2048 `
    -validity $validity `
    -alias $alias `
    -dname $dname `
    -storepass "$storePasswordPlain" `
    -keypass "$keyPasswordPlain"

if ($LASTEXITCODE -ne 0) {
    Write-Host "LỖI: Không thể tạo keystore!" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Tạo keystore thành công!" -ForegroundColor Green
Write-Host ""

Write-Host "=== BƯỚC 3: Xuất thông tin SHA-1 và SHA-256 ===" -ForegroundColor Cyan
Write-Host ""
keytool -list -v -keystore $keystorePath -alias $alias -storepass "$storePasswordPlain" | Select-String "SHA1:|SHA256:"

Write-Host ""
Write-Host "=== BƯỚC 4: Xuất certificate (PEM) để upload lên Play Console ===" -ForegroundColor Cyan

$pemPath = "android\app\upload_certificate.pem"
keytool -export -rfc `
    -keystore $keystorePath `
    -alias $alias `
    -file $pemPath `
    -storepass "$storePasswordPlain"

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Certificate đã được xuất ra: $pemPath" -ForegroundColor Green
} else {
    Write-Host "LỖI: Không thể xuất certificate!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "=== BƯỚC 5: Tạo Base64 string cho GitLab CI/CD ===" -ForegroundColor Cyan

$base64Path = "keystore-base64.txt"
$keystoreBytes = [IO.File]::ReadAllBytes((Resolve-Path $keystorePath))
$base64String = [Convert]::ToBase64String($keystoreBytes)
$base64String | Out-File -Encoding ASCII $base64Path

Write-Host "✓ Base64 string đã được lưu tại: $base64Path" -ForegroundColor Green

Write-Host ""
Write-Host "=== HOÀN THÀNH! ===" -ForegroundColor Green
Write-Host ""
Write-Host "Các file đã tạo:" -ForegroundColor Cyan
Write-Host "  1. Keystore: $keystorePath" -ForegroundColor White
Write-Host "  2. Certificate (PEM): $pemPath" -ForegroundColor White
Write-Host "  3. Base64 string: $base64Path" -ForegroundColor White
Write-Host ""
Write-Host "TIẾP THEO, BẠN CẦN:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. UPLOAD LÊN GOOGLE PLAY CONSOLE:" -ForegroundColor Cyan
Write-Host "   - Vào Play Console → Setup → App integrity" -ForegroundColor White
Write-Host "   - Upload file: $pemPath" -ForegroundColor White
Write-Host ""
Write-Host "2. THÊM VÀO GITLAB CI/CD VARIABLES:" -ForegroundColor Cyan
Write-Host "   Vào Settings → CI/CD → Variables, thêm:" -ForegroundColor White
Write-Host "   - KEYSTORE_BASE64 = nội dung file $base64Path (type: Variable, masked)" -ForegroundColor White
Write-Host "   - KEYSTORE_PASSWORD = $storePasswordPlain" -ForegroundColor White
Write-Host "   - KEY_PASSWORD = $keyPasswordPlain" -ForegroundColor White
Write-Host "   - KEY_ALIAS = $alias" -ForegroundColor White
Write-Host ""
Write-Host "3. LƯU Ý BẢO MẬT:" -ForegroundColor Red
Write-Host "   - KHÔNG commit các file: $keystorePath, $pemPath, $base64Path" -ForegroundColor White
Write-Host "   - File .gitignore đã được cấu hình để ignore các file này" -ForegroundColor White
Write-Host ""
Write-Host "Script hoàn tất! Chúc bạn deploy thành công! 🚀" -ForegroundColor Green
