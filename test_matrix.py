import json
import time
from datetime import datetime
from pool_token_summary import get_pool_token_summary

def run_test():
    # Thông số test - thay đổi theo nhu cầu
    wallet = '0x88DE2AB47352779494547CaCCB31eE1A133dd334'
    chain = 'BAS'
    from_date = '2026-08-08'
    to_date = '2026-08-09'

    print("=" * 100)
    print("ĐANG TÍNH MA TRẬN CROSS-TOKEN...")
    print(f"Wallet   : {wallet}")
    print(f"Chain    : {chain.upper()}")
    print(f"From-To  : {from_date} -> {to_date}")
    print("=" * 100 + "\n")

    start_time = time.time()

    try:
        payload = get_pool_token_summary(wallet, chain, from_date, to_date)
        execution_time = round((time.time() - start_time) * 1000, 2)

        print(f"SUCCESS! ({execution_time} ms)\n")
        
        tokens = payload.get('tokens', [])
        matrix = payload.get('matrix', {})
        flow = payload.get('flow', [])
        
        print(f"TỔNG SỐ TOKEN: {len(tokens)}")
        print("-" * 100)
        
        # === 1. KIỂM TRA CÓ DỮ LIỆU KHÔNG ===
        has_data = any(f['out'] > 0 or f['in'] > 0 for f in flow)
        if not has_data:
            print("KHÔNG CÓ DỮ LIỆU GIAO DỊCH TRONG KHOẢNG THỜI GIAN NÀY!")
            print("   Thử kiểm tra với khoảng thời gian khác hoặc bỏ trống from_date/to_date")
        
        # === 2. IN MA TRẬN DẠNG BẢNG ===
        print("\nMA TRẬN CROSS-TOKEN:")
        print("-" * 100)
        
        # In header - chỉ in 15 token đầu để dễ nhìn
        display_tokens = tokens[:15] if len(tokens) > 15 else tokens
        header = f"{'TOKEN':<14}"
        for t in display_tokens:
            header += f" | {t['symbol']:>10}"
        if len(tokens) > 15:
            header += " | ..."
        print(header)
        print("-" * 100)
        
        # In từng hàng - chỉ in 15 hàng đầu
        display_rows = tokens[:15] if len(tokens) > 15 else tokens
        for row_token in display_rows:
            row_key = row_token['key']
            row_cells = matrix.get(row_key, {})
            
            row_str = f"{row_token['symbol']:<14}"
            for col_token in display_tokens:
                col_key = col_token['key']
                cell = row_cells.get(col_key, {})
                
                if cell.get('has_relation', False):
                    sent = cell.get('sent', 0)
                    received = cell.get('received', 0)
                    if sent == 0 and received == 0:
                        row_str += f" | {'0|0':>10}"
                    elif sent < 0 and received > 0:
                        row_str += f" | {sent:>6.2f}|{received:>4.2f}"
                    elif sent < 0 and received == 0:
                        row_str += f" | {sent:>8.2f}|0"
                    elif sent == 0 and received > 0:
                        row_str += f" | 0|{received:>7.2f}"
                else:
                    row_str += f" | {'-':>10}"
            
            if len(tokens) > 15:
                row_str += " | ..."
            print(row_str)
        
        if len(tokens) > 15:
            print(f"... (còn {len(tokens) - 15} hàng nữa)")
        
        print("-" * 100)
        
        # === LƯU KẾT QUẢ RA FILE JSON ===
        with open('matrix_result.json', 'w', encoding='utf-8') as f:
            json.dump(payload, f, indent=2, ensure_ascii=False, default=str)
        print("\nĐã lưu kết quả chi tiết ra file: matrix_result.json")

    except Exception as e:
        print("ERROR!")
        print(e)
        import traceback
        traceback.print_exc()

if __name__ == '__main__':
    # Chạy test đầy đủ
    run_test()
    
    # Hoặc chạy test nhanh chỉ AERO
    # check_aero_only()