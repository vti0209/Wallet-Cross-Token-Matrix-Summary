# Cross-Token Pivot Matrix

## Giới thiệu

**Cross-Token Pivot Matrix** là công cụ phân tích luồng dòng tiền giữa các Token trong một ví. Thay vì phải tra cứu từng token một cách thủ công, công cụ này tự động:

- Lấy tất cả token xuất hiện trong giao dịch của ví
- Với mỗi token, tính toán **OUT** (gửi đi) và **IN** (nhận về) với tất cả các token khác
- Hiển thị dưới dạng **Ma trận xoay chiều** (Pivot Matrix) trực quan

###  Tính năng

| Tính năng | Mô tả |
|-----------|-------|
| **Ma trận Cross-Token** | Mỗi hàng là 1 token, mỗi cột là 1 token, mỗi ô hiển thị OUT/IN |
| **Lọc Stablecoin/Wrapped** | Tự động ẩn các hàng stablecoin, wrapped, chain native để tập trung vào token chính |
| **Xuất CSV** | Xuất dữ liệu ma trận ra file CSV để phân tích thêm |
| **Lọc theo thời gian** | Chọn khoảng thời gian giao dịch cần phân tích |

---



## Hướng dẫn cài đặt và chạy

### Giải nén và mở project

- Giải nén file ZIP vào thư mục, ví dụ: `C:\BTAP`
- Mở **VS Code** và mở folder vừa giải nén

### Tạo môi trường ảo (nếu chưa có)

```powershell
python -m venv .venv
```

### Kích hoạt môi trường ảo và cài dependencies

Chạy lần lượt các lệnh sau trong **PowerShell**:

```powershell
# Kích hoạt môi trường ảo
.\.venv\Scripts\Activate.ps1

# Cài các thư viện cần thiết
pip install flask mysql-connector-python python-dotenv
```

> **Lưu ý:** Nếu gặp lỗi về Execution Policy, chạy lệnh này trước:
> ```powershell
> Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned
> ```

### Cấu hình kết nối Database

Tạo file `.env` trong thư mục gốc với nội dung:

```env
ENV=server
SERVER_DB_HOST=123.19.254.158
SERVER_DB_USER=apebond
SERVER_DB_PASS=it.d@2025
SERVER_DB_NAME=apebond
SERVER_DB_PORT=3307
```

> Hoặc nếu chạy local, đổi `ENV=local` và cấu hình trong `db_config.py`

### Chạy server

```powershell
python app.py
```

Server sẽ chạy tại: **http://localhost:5000**

### Dừng server

Nhấn `Ctrl + C` trong terminal để dừng server.

---

## Hướng dẫn sử dụng

### Bước 1: Nhập thông tin

| Trường | Mô tả | Ví dụ |
|--------|-------|-------|
| **Wallet Address** | Địa chỉ ví cần tra cứu | `vd: 0x88DE2AB4735277...` |
| **Chain** | Blockchain (sol, eth, bsc, bas...) | `vd: bas` |
| **From Date** | Ngày bắt đầu | `vd: 08/08/2026` |
| **To Date** | Ngày kết thúc (mặc định = hôm nay) | `vd: 09/08/2026` |

### Bước 2: Nhấn nút **Search**

Hệ thống sẽ truy vấn database và hiển thị ma trận.

### Bước 3: Xem kết quả

**Ma trận hiển thị:**

| TOKEN / POOL | AERO | USDC | WETH |
|--------------|------|------|------|
| **PUMP**     | `-1.0264`<br>`+1.0264` | `-267.7928`<br>`+158.5527` | `-` |
| **AERO**     | `-97,353.5612`<br>`+20.518` | `-` | `-61,337.327`<br>`+766.8989` |

- 🔴 **OUT** (gửi đi): màu đỏ, có dấu trừ `-`
- 🟢 **IN** (nhận về): màu xanh, có dấu cộng `+`
- **`-`**: Không có giao dịch chung

### Bước 4: Xuất CSV

Nhấn nút **CSV** để tải file `matrix_<wallet>.csv` về máy.

---

## Chạy test nhanh

```powershell
python test_matrix.py
```

Script này sẽ:

1. Chạy với ví mẫu `0x88DE2AB47352779494547CaCCB31eE1A133dd334` trên chain `BAS`
2. Tạo file CSV và JSON trong thư mục hiện tại
3. In kết quả tóm tắt ra console

---

## Dữ liệu trả về

API `/api/pool-token-summary` trả về JSON với cấu trúc:

```json
{
  "status": "success",
  "query": {
    "wallet": "...",
    "chain": "...",
    "from_date": "...",
    "to_date": "..."
  },
  "data": {
    "tokens": [...],
    "matrix": {...},
    "flow": [...]
  }
}
```

| Field | Mô tả |
|-------|-------|
| `tokens` | Danh sách tất cả token (cột) |
| `matrix` | Ma trận chi tiết: `{row_key: {col_key: {sent, received, has_relation}}}` |
| `flow` | Tổng OUT/IN của từng token |

---

## Các file chính

| File | Vai trò |
|------|---------|
| `wallet_matrix.py` | Truy vấn DB, tính toán ma trận cross-token |
| `pool_token_summary.py` | Format dữ liệu trả về cho API và UI |
| `app.py` | Flask server, xử lý request |
| `templates/pool_token_summary.html` | Giao diện web |

---

## Xử lý lỗi thường gặp

### Lỗi: `ModuleNotFoundError: No module named 'mysql'`

```powershell
pip install mysql-connector-python
```

### Lỗi: `Connection refused` (không kết nối được DB)

- Kiểm tra file `.env` đã cấu hình đúng chưa
- Kiểm tra kết nối internet đến server DB

### Lỗi: `Address already in use` (cổng 5000 đã được dùng)

```powershell
# Tìm process đang dùng cổng 5000
netstat -ano | findstr :5000

# Kill process (thay PID bằng số tìm được)
taskkill /PID <PID> /F
```

### Lỗi: Không hiển thị dữ liệu

- Kiểm tra wallet address có đúng không
- Kiểm tra chain có đúng với ví không (BAS, ETH, SOL...)
- Kiểm tra khoảng thời gian có giao dịch không

---

## Ghi chú

- **Stablecoin/Wrapped** (USDC, USDT, WETH, ETH, BNB, SOL...) tự động bị ẩn khỏi hàng để tập trung vào token chính
- Các hàng **không có quan hệ** với bất kỳ token nào sẽ tự động bị ẩn
- **To Date** mặc định là ngày hiện tại nếu không nhập

---

## Btap

Ho Van Tiet

---

