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
    print("🚀 ĐANG TÍNH MA TRẬN CROSS-TOKEN...")
    print(f"👉 Wallet   : {wallet}")
    print(f"👉 Chain    : {chain.upper()}")
    print(f"👉 From-To  : {from_date} -> {to_date}")
    print("=" * 100 + "\n")

    start_time = time.time()

    try:
        payload = get_pool_token_summary(wallet, chain, from_date, to_date)
        execution_time = round((time.time() - start_time) * 1000, 2)

        print(f"✅ SUCCESS! ({execution_time} ms)\n")
        
        tokens = payload.get('tokens', [])
        matrix = payload.get('matrix', {})
        flow = payload.get('flow', [])
        
        print(f"📌 TỔNG SỐ TOKEN: {len(tokens)}")
        print("-" * 100)
        
        # === 1. KIỂM TRA CÓ DỮ LIỆU KHÔNG ===
        has_data = any(f['out'] > 0 or f['in'] > 0 for f in flow)
        if not has_data:
            print("⚠️ KHÔNG CÓ DỮ LIỆU GIAO DỊCH TRONG KHOẢNG THỜI GIAN NÀY!")
            print("   Thử kiểm tra với khoảng thời gian khác hoặc bỏ trống from_date/to_date")
        
        # === 2. IN MA TRẬN DẠNG BẢNG ===
        print("\n📊 MA TRẬN CROSS-TOKEN:")
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
        
        # === 3. IN CHI TIẾT TOKEN AERO ===
        print("\n🔍 CHI TIẾT DÒNG AERO (Token Transfer Summary):")
        print("-" * 100)
        
        aero_token = next((t for t in tokens if t['symbol'] == 'AERO'), None)
        if aero_token:
            aero_cells = matrix.get(aero_token['key'], {})
            print(f"{'TOKEN':<14} | {'SENT':>15} | {'RECEIVED':>15} | {'TOTAL':>15}")
            print("-" * 100)
            
            relation_count = 0
            # In các token có quan hệ với AERO
            for col_token in tokens:
                cell = aero_cells.get(col_token['key'], {})
                if cell.get('has_relation', False):
                    relation_count += 1
                    sent = cell.get('sent', 0)
                    received = cell.get('received', 0)
                    total = sent + received
                    print(f"{col_token['symbol']:<14} | {sent:>15.4f} | {received:>15.4f} | {total:>15.4f}")
            
            print("-" * 100)
            print(f"✅ Tổng số token có quan hệ với AERO: {relation_count}")
            
            # So sánh với dữ liệu mong đợi từ ảnh (nếu có)
            print("\n📋 SO SÁNH VỚI DỮ LIỆU MONG ĐỢI (từ ảnh 08/08/2026):")
            expected = {
                'AERO': {'sent': -3862, 'received': 3301},
                'DEGEN': {'sent': 0, 'received': 1287278},
                'ETH': {'sent': -0.6205, 'received': 0},
                'KAITO': {'sent': -1970, 'received': 1973},
                'kellyclaude': {'sent': 0, 'received': 2287695},
                'USDC': {'sent': 0, 'received': 3868},
                'WETH': {'sent': -0.0177, 'received': 0.2469},
                'wstETH': {'sent': -0.0683, 'received': 0}
            }
            print(f"{'TOKEN':<14} | {'EXPECTED SENT':>15} | {'ACTUAL SENT':>15} | {'MATCH?'}")
            print("-" * 100)
            for name, exp in expected.items():
                token_obj = next((t for t in tokens if t['symbol'].upper() == name.upper()), None)
                if token_obj:
                    cell = aero_cells.get(token_obj['key'], {})
                    if cell.get('has_relation', False):
                        actual_sent = cell.get('sent', 0)
                        actual_received = cell.get('received', 0)
                        sent_match = abs(actual_sent - exp['sent']) < 0.01
                        received_match = abs(actual_received - exp['received']) < 0.01
                        match = sent_match and received_match
                        print(f"{name:<14} | {exp['sent']:>15.4f} | {actual_sent:>15.4f} | {match}")
                    else:
                        print(f"{name:<14} | {exp['sent']:>15.4f} | {'NO DATA':>15} | ❌")
                else:
                    print(f"{name:<14} | {exp['sent']:>15.4f} | {'NOT FOUND':>15} | ❌")
        else:
            print("❌ Không tìm thấy token AERO!")
        
        # === 4. IN TỔNG DÒNG TIỀN ===
        print("\n📊 TỔNG DÒNG TIỀN (OUT/IN theo từng token):")
        print("-" * 100)
        print(f"{'SYMBOL':<14} | {'OUT TOTAL':>15} | {'IN TOTAL':>15}")
        print("-" * 100)
        
        for item in flow[:15]:
            print(f"{item['symbol']:<14} | {item['out']:>15.4f} | {item['in']:>15.4f}")
        if len(flow) > 15:
            print(f"... (còn {len(flow) - 15} dòng nữa)")
        print("-" * 100)
        
        # === 5. LƯU KẾT QUẢ RA FILE JSON ===
        with open('matrix_result.json', 'w', encoding='utf-8') as f:
            json.dump(payload, f, indent=2, ensure_ascii=False, default=str)
        print("\n💾 Đã lưu kết quả chi tiết ra file: matrix_result.json")
        
        # === 6. IN THÔNG TIN TÓM TẮT ===
        print("\n📊 TÓM TẮT:")
        print("-" * 100)
        print(f"✅ Tổng số token: {len(tokens)}")
        print(f"✅ Tổng số dòng tiền: {sum(1 for f in flow if f['out'] > 0 or f['in'] > 0)}")
        total_out = sum(f['out'] for f in flow)
        total_in = sum(f['in'] for f in flow)
        print(f"✅ Tổng OUT: {total_out:,.4f}")
        print(f"✅ Tổng IN: {total_in:,.4f}")

    except Exception as e:
        print("❌ ERROR!")
        print(e)
        import traceback
        traceback.print_exc()

def check_aero_only():
    """Test nhanh chỉ lấy dữ liệu của AERO"""
    wallet = '0x88DE2AB47352779494547CaCCB31eE1A133dd334'
    chain = 'BAS'
    from_date = '2026-08-08'
    to_date = '2026-08-09'
    
    print("=" * 60)
    print("🔍 KIỂM TRA NHANH DỮ LIỆU AERO")
    print("=" * 60)
    
    result = get_pool_token_summary(wallet, chain, from_date, to_date)
    
    tokens = result.get('tokens', [])
    matrix = result.get('matrix', {})
    
    aero_token = next((t for t in tokens if t['symbol'] == 'AERO'), None)
    if aero_token:
        aero_cells = matrix.get(aero_token['key'], {})
        print(f"\n📌 AERO key: {aero_token['key']}")
        print("-" * 60)
        print(f"{'TOKEN':<14} | {'SENT':>15} | {'RECEIVED':>15}")
        print("-" * 60)
        
        for token in tokens:
            cell = aero_cells.get(token['key'], {})
            if cell.get('has_relation', False):
                print(f"{token['symbol']:<14} | {cell['sent']:>15.4f} | {cell['received']:>15.4f}")
        
        print("-" * 60)

if __name__ == '__main__':
    # Chạy test đầy đủ
    run_test()
    
    # Hoặc chạy test nhanh chỉ AERO
    # check_aero_only()