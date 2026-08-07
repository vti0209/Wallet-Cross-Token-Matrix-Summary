1) Giải nén ZIP vào thư mục (ví dụ: C:\BTAP)

2) Mở VS Code và mở folder vừa giải nén

3) Mở PowerShell terminal trong VS Code, chạy 3 lệnh sau (copy → paste):

(Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned) ; (& .venv\Scripts\Activate.ps1)
pip install flask mysql-connector-python
python app.py

Server sẽ chạy và lắng nghe cổng 500 (hoặc cổng được cấu hình trong app). Nếu không có thư mục .venv, tạo trước: python -m venv .venv

Dừng server: Ctrl+C
Lên web nhập các thông số cần nhập và kiểm tra là được